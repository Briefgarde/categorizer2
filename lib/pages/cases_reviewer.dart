import 'dart:convert';
import 'dart:io';

import 'package:categorizer2/models/case.dart';
import 'package:categorizer2/models/issue.dart';
import 'package:categorizer2/models/word_tag.dart';
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
                // Text(widget.issue.coordinates.toString()),
                // Text(widget.issue.address.toString()),
                // Image.file(widget.issue.image!),
                // Text(widget.issue.image!.path),
                ElevatedButton(
                  child: Text("Submit pic"),
                  onPressed: () {
                    _createCase();
                  },
                )
              ],
            ),
          ),
        ));
  }

  // Future<Case> _getGoodCases () async {

  //   // call GET getCases
  //   // if status:204 => POST createCase
  //   // if status:200 => display case
  //   // user go through the case
  //   // if one case selected : add issue to selected case
  //   // if no case selected : POST createCase

  // }

  _createCase() async {
    String uniqueNameOfPic = DateTime.now().microsecondsSinceEpoch.toString();
    // upload image to Storage
    Reference refRoot = FirebaseStorage.instance.ref();
    Reference refDirImage = refRoot.child('images');
    Reference refImage = refDirImage.child(uniqueNameOfPic);
    String urlToImage;
    try {
      await refImage.putFile(File(widget.issue.image!.path));
      // get download URL
      urlToImage = await refImage.getDownloadURL();
    } catch (error) {
      print(error);
      return;
    }

    // either call function and pass the coor, keyword and URL as body/query
    // or directly push into firestore
    await _postCase(urlToImage, widget.issue.keywords!, widget.issue.coordinates!);
  }

  Future<void> _postCase(String urlToImage, List<WordTag> keywords, LatLng coordinates) async {
    //10.0.2.2 est une address loopback que l'émulateur Android utilise pour se connecter à l'hôte local
    final Uri url = Uri.parse('http://10.0.2.2:5001/categorizer-405012/us-central1/createCase');

    final Map<String, dynamic> requestBody = {
      'lat': coordinates.latitude,
      'long': coordinates.longitude,
      'keywords': keywords,
      'urlToImage': urlToImage,
    };
    
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type':'application/json', // Set the content type of the request
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      // Request was successful, you can handle the response data here
      print('Response data: ${response.body}');
    } else {
      // Request failed, handle the error
      print('Request failed with status: ${response.statusCode}');
      print('Error message: ${response.body}');
    }
  }
}
