import 'package:latlong2/latlong.dart';

import 'issue.dart';

class Case {
  List<Issue> issues;
  LatLng averageCoordinates;
  int geoHash;
  

  Case(this.issues, this.averageCoordinates, this.geoHash);

  factory Case.fromJson(Map<String, dynamic> json) {

    final averageLong = json['averageLong'];
    final averageLat = json['averageLat'];
    final geoHash = json['coordHash'];


    List<Issue> issues = [];
    for (var issue in json['issues']) {
      issues.add(Issue.fromJson(issue));
    }
    return Case(issues, LatLng(averageLat, averageLong), geoHash);
  }

  
}


// still need work
// fromJson method