// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:categorizer2/models/case.dart';
import 'package:categorizer2/models/issue.dart';
import 'package:categorizer2/models/word_tag.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class CaseShower extends StatefulWidget {
  const CaseShower({Key? key, required this.cases, required this.issue}) : super(key: key);
  final List<Case> cases;
  final Issue issue;
  @override
  State<CaseShower> createState() => _CaseShowerState();
}

class _CaseShowerState extends State<CaseShower> {
  late List<Case> _cases;
  late File _image;
  late Issue _issue;

  @override
  void initState() {
    super.initState();
    _cases = widget.cases;
    _issue = widget.issue;
  }

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            children: [
              carouselBuilder(),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text((_index + 1).toString()),
              Text(" / "),
              Text(_cases[_index].issues.length.toString()),
            ],
          ),
          Visibility(
            visible: _cases[_index].issues.length > 1,
            maintainState: false,
            // those are buttons to switch between CASES, not pictures in the carousel, which represent ISSUES in ONE CASE
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      if (_index > 0) {
                        _index--;
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      if (_index < _cases.length - 1) {
                        _index++;
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  null;
                }, 
                child: const Text("This is my case!")
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: (){
                  _createNewCase();
                }, 
                child: const Text("None of these cases match mine")
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget carouselBuilder() {
    List<String> listImage =
        _cases[_index].issues.map((e) => e.urlToImage!).toList();
    List<String> listKeywords = _cases[_index].issues.map((e) => e.keywords!.map((e) => e.description).join(', ')).toList();
    for (var words in listKeywords) {
      print(words);
    }
    return Expanded(
      child: CarouselSlider.builder(
          itemCount: listImage.length,
          itemBuilder: (context, index, realIndex) {
            final imageURL = listImage[index];
            return buildImage(imageURL, index);
          },
          options: CarouselOptions(
            height: 400,
            enableInfiniteScroll: false,
          )),
    );
  }

  Widget buildImage(String urlToImage, int index) => Container(
        margin: EdgeInsets.symmetric(horizontal: 12),
        color: Colors.grey,
        child: Image.network(urlToImage, fit: BoxFit.cover),
      );

  _createNewCase() async {
    await _issue.uploadIssueAsCase();
    // after this, we might push to another succes page or something
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
}
