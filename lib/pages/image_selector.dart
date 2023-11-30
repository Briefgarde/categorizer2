
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:categorizer2/models/word_tag.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../models/issue.dart';
import 'package:http/http.dart' as http;
import 'location_decider.dart';

class ImageSelector extends StatefulWidget {
  const ImageSelector({Key? key}) : super(key: key);

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select an image"),
      ),
      body: FutureBuilder<Position>(
        future: _determinePosition(), 
        builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_issue.image != null)
                    Image.file(_issue.image!),
                  Visibility(
                    visible: _selectedImage == null,
                    maintainState: false,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _takePic(false);
                          }, 
                          child: const Text("Choose picture from gallery")
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _takePic(true);
                          },  
                          child: const Text("Take a picture")
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _selectedImage != null,
                    maintainState: false,
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: (){
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => LocationDecider(issue: _issue)
                              )
                            );                         
                          }, 
                          child: const Text("Choose this picture")
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          }, 
                          child: const Text("Choose another picture")
                        )
                      ],
                    )
                  ),
                ]
              )
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator()
                ]
              )
            );
          }
        }
      )
    );
  }

  File? _selectedImage;
  final Issue _issue = Issue(null, null, null, null);

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position pos =  await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (mounted){
      setState(() {
        _issue.coordinates = LatLng(pos.latitude, pos.longitude);
        
      });
    }
    return pos;
  }

  Future _takePic(bool useCamera) async {
    final returnImage =
        await ImagePicker().pickImage(source: useCamera == true ? ImageSource.camera : ImageSource.gallery);

    if (returnImage == null) {
      return;
    } else {
      if (mounted){
        setState(() {
          _selectedImage = File(returnImage.path);
        });
      }
    }
    _makeCall();
  }
  
  _makeCall() async {
    String? sendData;
    if (_selectedImage != null) {
      Uint8List imgbytes = await _selectedImage!.readAsBytes();
      sendData = base64.encode(imgbytes);
    }

    final url = Uri.parse(
        "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyC02yw_zH30GZxEUdcSdg9CADODSGyWTuw");

    final requestBody = {
      "requests": [
        {
          "image": {"content": sendData},
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 10}
          ]
        }
      ]
    };

    final requestBodyJson = jsonEncode(requestBody);

    final headers = {
      "Content-Type": "application/json",
    };

    final response =
        await http.post(url, headers: headers, body: requestBodyJson);

    if (response.statusCode == 200) {
      List<WordTag> wordSet = [];
      Map<String, dynamic> list = jsonDecode(response.body) as Map<String, dynamic>;
      for (var keyword in list['responses'][0]['labelAnnotations']) {
        WordTag wordTag = WordTag.fromJson(keyword);
        wordSet.add(wordTag);
      }
      // Request was successful
      setState(() {
        _issue.keywords = wordSet;
        _issue.image = _selectedImage;
      });
    } else {
      // Request failed
      print("Request failed with status code: ${response.statusCode}");
    }
  }
}