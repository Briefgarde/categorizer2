// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:categorizer2/models/case.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CaseShower extends StatefulWidget {
  const CaseShower({Key? key, required this.cases, required this.image}) : super(key: key);
  final List<Case> cases;
  final File image;
  @override
  State<CaseShower> createState() => _CaseShowerState();
}

class _CaseShowerState extends State<CaseShower> {
  late List<Case> _cases;
  late File _image;

  @override
  void initState() {
    super.initState();
    _cases = widget.cases;
    _image = widget.image;
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
                  _addIssueToSelectedCase();
                }, 
                child: const Text("This is my case!")
              )
            ],
          ),
          // const Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text("Your image for reference")
          //   ],
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Image.file(_image)
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget carouselBuilder() {
    List<String> listImage =
        _cases[_index].issues.map((e) => e.urlToImage!).toList();
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

  _addIssueToSelectedCase() {
    
  }
}
