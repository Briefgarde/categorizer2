import 'dart:convert';
import 'dart:io';

import 'package:categorizer2/models/case.dart';
import 'package:categorizer2/models/issue.dart';
import 'package:categorizer2/models/word_tag.dart';
import 'package:categorizer2/widgets/cases_shower.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class CaseReviewer extends StatefulWidget {
  const CaseReviewer({Key? key, required this.issue}) : super(key: key);
  final Issue issue;

  @override
  State<CaseReviewer> createState() => _CaseReviewerState();
}

class _CaseReviewerState extends State<CaseReviewer> {
  List<Case> _cases = [];
  late Future<List<Case>> _casesFuture;

  @override
  void initState() {
    super.initState();
    _casesFuture = getGoodCases();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Case Reviewer"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                FutureBuilder(
                  future: _casesFuture,
                  builder: (BuildContext context, AsyncSnapshot<List<Case>> snapshot) {
                    if (snapshot.hasData) {
                      _cases = snapshot.data!;
                      if (_cases.isNotEmpty) {
                        return CaseShower(cases: _cases, issue: widget.issue);
                      } else {
                        return _noCaseFound();
                      }
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    else {
                      return const LoadingWidget();
                    }
                  },
                )
                // Text(widget.issue.coordinates.toString()),
                // Image.file(widget.issue.image!),
                // Text(widget.issue.image!.path),
              ],
            ),
          ),
        ));
  }

  Widget _noCaseFound() {
    return const Text("Your case has been analyzed but no similar cases were found, so we created a new one !");
  }



  Future<void> uploadIssueAsCase() async{
    // upload image to Storage
    String urlToImage = await _postImageToBackend();
    // post case to backend
    await _postCase(
        urlToImage, widget.issue.keywords!, widget.issue.coordinates!);
  }

  Future<String> _postImageToBackend() async{
    Reference refRoot = FirebaseStorage.instance.ref();
    Reference refDirImage = refRoot.child('images');
    Reference refImage = refDirImage.child(DateTime.now().microsecondsSinceEpoch.toString());
    try {
      await refImage.putFile(File(widget.issue.image!.path));
      // get download URL
      String urlToImage = await refImage.getDownloadURL();
      print(urlToImage);
      return urlToImage;
    } catch (error) {
      print(error);
      return '';
    }
  }

  Future<void> _postCase(String urlToImage, List<WordTag> keywords, LatLng coordinates) async {
    final Uri url = Uri.parse(
        'https://us-central1-categorizer-405012.cloudfunctions.net/postCase');
    // call this function by passing the current "issue" as body

    final Map<String, dynamic> requestBody = {
      'lat': coordinates.latitude,
      'long': coordinates.longitude,
      'keywords': keywords,
      'urlToImage': urlToImage,
    };

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type':
            'application/json', // Set the content type of the request
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print('Case successfully created');
    } else {
      // Request failed, handle the error // probably no cases
      print('Request failed with status: ${response.statusCode}');
      print('Error message: ${response.body}');
    }
  }

  Future<List<Case>> getGoodCases() async {
    
    final Uri url = Uri.parse(
        'https://us-central1-categorizer-405012.cloudfunctions.net/getCases');
    // call this function by passing the current "issue" as body

    final Map<String, dynamic> requestBody = {
      'lat': widget.issue.coordinates!.latitude,
      'long': widget.issue.coordinates!.longitude,
      'keywords': widget.issue.keywords,
    };

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type':
            'application/json', // Set the content type of the request
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      List<Case> cases = [];
      for (var caseJson in jsonDecode(response.body)['result']) {
        cases.add(Case.fromJson(caseJson));
      }
      
      return cases;
    } else if (response.statusCode == 204) {
      // no cases found
      print('No cases found');
      await uploadIssueAsCase();
    } else {
      // Request failed, handle the error // probably no cases
      print('Request failed with status: ${response.statusCode}');
      print('Error message: ${response.body}');
    }
    
    return [];
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Analyzing your issue..."),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
