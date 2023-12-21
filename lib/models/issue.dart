import 'dart:convert';
import 'dart:io';
import 'package:categorizer2/models/case.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'word_tag.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

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



  Future<String?> getAdressFromCoordinates() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates!.latitude, coordinates!.longitude);
    return '${placemarks[0].street}, ${placemarks[0].postalCode} ${placemarks[0].locality}';
  }

  /// Returns a [Widget] that displays the address of an issue.
  ///
  /// The [style] parameter allows you to specify the text style of the address.
  /// If not provided, the default text style is used.
  ///
  /// The [before] and [after] parameters allow you to specify text to display
  /// before and after the address. If not provided, no extra text is displayed.
  Widget getAddress({TextStyle? style, String? before, String? after}){
    before ??= "";
    after ??= "";
    return FutureBuilder(
      future: getAdressFromCoordinates(), 
      builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
        if (snapshot.hasData) {
          return Text("$before ${snapshot.data!} $after", style: style);
        }
        else {
          return const SizedBox.shrink();
        }
      }
    );
  }

  Future<bool> uploadIssueAsCase() async{
    // upload image to Storage
    String urlToImage = await postImageToBackend();
    // post case to backend
    bool worked = await _postCase(
        urlToImage, keywords!, coordinates!);
    return worked;
  }

  Future<String> postImageToBackend() async{
    Reference refRoot = FirebaseStorage.instance.ref();
    Reference refDirImage = refRoot.child('images');
    Reference refImage = refDirImage.child(DateTime.now().microsecondsSinceEpoch.toString());
    try {
      final UploadTask uploadTask = refImage.putFile(File(image!.path));
      await uploadTask.whenComplete(() => null);
      String urlToImage = await refImage.getDownloadURL();
      return urlToImage;
    } catch (error) {
      print(error);
      return '';
    }
  }

  Future<bool> _postCase(String urlToImage, List<WordTag> keywords, LatLng coordinates) async {
    final Uri url = Uri.parse(
        'https://us-central1-categorizer-405012.cloudfunctions.net/createCase');
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
      return true;
    } else {
      // Request failed, handle the error // probably no cases
      print('Request failed with status: ${response.statusCode}');
      print('Error message: ${response.body}');
      return false;
    }
  }

  Future<List<Case>> getGoodCases() async {
    
    final Uri url = Uri.parse(
        'https://us-central1-categorizer-405012.cloudfunctions.net/getCases');
    // call this function by passing the current "issue" as body

    final Map<String, dynamic> requestBody = {
      'lat': coordinates!.latitude,
      'long': coordinates!.longitude,
      'keywords': keywords,
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
      List<Case> cases = [];
      for (var caseJson in jsonDecode(response.body)['result']) {
        cases.add(Case.fromJson(caseJson));
      }
      
      return cases;
    } else if (response.statusCode == 204) {
      // no cases found
      print('No cases found');
      await uploadIssueAsCase();
    } else {
      // Request failed, handle the error // probably no cases
      print('Request failed with status: ${response.statusCode}');
      print('Error message: ${response.body}');
    }
    
    return [];
  } 
}