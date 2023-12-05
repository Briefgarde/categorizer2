import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'issue.dart';

class Case {
  List<Issue> issues;
  LatLng averageCoordinates;
  int geoHash;
  String? id;

  

  Case(this.issues, this.averageCoordinates, this.geoHash, this.id);

  factory Case.fromJson(Map<String, dynamic> json) {

    final averageLong = json['averageLong'];
    final averageLat = json['averageLat'];
    final geoHash = json['coordHash'];
    final id = json['id'];


    List<Issue> issues = [];
    for (var issue in json['issues']) {
      issues.add(Issue.fromJson(issue));
    }
    return Case(issues, LatLng(averageLat, averageLong), geoHash, id);
  }

  Future<bool> updateCaseWithIssue(Issue issue) async {
    // identify the case : the getCases gfunction include the id in what it returns.
    //upload the image of the issue to storage
    String urlImage = await issue.postImageToBackend();
    //call POST on updateCase with the data of the new issue
    final Uri url = Uri.parse(
        'https://us-central1-categorizer-405012.cloudfunctions.net/updateCase');
    final Map<String, dynamic> requestBody = {
      'lat': issue.coordinates!.latitude,
      'long': issue.coordinates!.longitude,
      'keywords': issue.keywords,
      'urlToImage': urlImage,
      'docID': id, // this is the caseid, not the id of the issue. 
    };

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type':
            'application/json', // Set the content type of the request
      },
      body: jsonEncode(requestBody),
    );
    //check of result for return
    if (response.statusCode == 200){
      return true;
    }
    else {
      return false;
    }
  } 
}