import 'dart:io';
import 'package:latlong2/latlong.dart';
import 'word_tag.dart';

class Issue {
  File? image;
  List<WordTag>? keywords;
  LatLng? coordinates;
  String? urlToImage;
  

  Issue(this.image, this.keywords, this.coordinates, this.urlToImage);

  factory Issue.fromJson(Map<String, dynamic> json) {
    final image = json['urlToImage'];
    final lat = json['lat'];
    final long = json['long'];
    List<WordTag> keywords = [];
    for (var keyword in json['keywords']) {
      keywords.add(WordTag.fromJson(keyword));
    } // in the fromJson method, the Issue doesn't have a File image, but only an URL
    // when originally created, the Issue has a File image, but no URL


    return Issue(null, keywords, LatLng(lat, long), image);
  }
}