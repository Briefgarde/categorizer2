import 'dart:convert';
import 'dart:io';
import 'package:categorizer2/models/case.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
import 'word_tag.dart';
import 'package:http/http.dart' as http;

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

  Future<void> uploadIssueAsCase() async{
    // upload image to Storage
    Reference refRoot = FirebaseStorage.instance.ref();
    Reference refDirImage = refRoot.child('images');
    Reference refImage = refDirImage.child(DateTime.now().microsecondsSinceEpoch.toString());
    String urlToImage;
    try {
      await refImage.putFile(File(image!.path));
      // get download URL
      urlToImage = await refImage.getDownloadURL();
    } catch (error) {
      print(error);
      return;
    }
    // post case to backend
    await postCase(
        urlToImage, keywords!, coordinates!);
  }

  Future<void> postCase(String urlToImage, List<WordTag> keywords, LatLng coordinates) async {
    final Uri url = Uri.parse(
        'https://us-central1-categorizer-405012.cloudfunctions.net/postCase');
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
    } else {
      // Request failed, handle the error // probably no cases
      print('Request failed with status: ${response.statusCode}');
      print('Error message: ${response.body}');
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