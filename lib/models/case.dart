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

  Future<void> updateCaseWithIssue(Issue issue) async {
    // update the case with the new issue
    // update the average coordinates
    // update the geohash
    // update the keywords
    // update the image
    // update the urlToImage
    // update the issues list
    // update the case in the backend
  }



  
}
// put createMethod here ? 