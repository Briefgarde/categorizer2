import 'package:categorizer2/models/issue.dart';
import 'package:flutter/material.dart';

class CaseReviewer extends StatefulWidget{
  const CaseReviewer({Key? key, required this.issue}) : super(key: key);
  final Issue issue;

  @override
  State<CaseReviewer> createState() => _CaseReviewerState();
}

class _CaseReviewerState extends State<CaseReviewer>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Case Reviewer"),
      ),
      body: Column(
        children: [
          Text(widget.issue.coordinates.toString()),
          Text(widget.issue.address.toString()),
          Image.file(widget.issue.image!),
        ],
      )
    );
  }
}