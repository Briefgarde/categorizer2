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
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Text("Some cases may have more than one picture, be sure to check them all !"))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Case ${_index + 1}"),
              Text(" of "), // we do +1 because otherwise it starts at 0
              Text((_cases.length).toString()),
            ],
          ),
          Visibility(
            visible: _cases.length > 1,
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
                  _updateCase();
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

  _updateCase() async {
    bool worked = await _cases[_index].updateCaseWithIssue(_issue);
    print(worked);
  }
}
