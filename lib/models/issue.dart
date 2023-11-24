import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'word_tag.dart';

class Issue {
  File? image;
  List<WordTag>? keywords;
  LatLng? coordinates;
  String? address;

  Issue(this.image, this.keywords, this.coordinates, this.address);
}