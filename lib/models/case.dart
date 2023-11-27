import 'package:latlong2/latlong.dart';

import 'issue.dart';

class Case {
  List<Issue> issues;
  LatLng averageCoordinates;
  String id;

  Case(this.issues, this.averageCoordinates, this.id);
}


// still need work
// fromJson method