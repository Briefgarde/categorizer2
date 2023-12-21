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

class _ImageSelectorState extends State<ImageSelector> {
  late Future<Position> pos;
  @override
  void initState() {
    super.initState();
    pos = _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Select an image"),
        ),
        body: FutureBuilder<Position>(
            future: pos,
            builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
              if (snapshot.hasData) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      if (_issue.image != null)
                        Expanded(
                          child: Image.file(_issue.image!, fit: BoxFit.cover),
                        ),
                      Visibility(
                          visible: _selectedImage == null,
                          maintainState: false,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(child: _issue.getAddress(before: "Your current position :"))
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        _takePic(false);
                                      },
                                      child: const Text(
                                          "Choose picture from gallery")),
                                  ElevatedButton(
                                      onPressed: () {
                                        _takePic(true);
                                      },
                                      child: const Text("Take a picture"))
                                ],
                              ),
                            ],
                          )),
                      // let's be very clear :
                      // this is positively an *horrible* way of handling the situation.
                      // I did this right when starting with Flutter, and now, I cringe just looking at this.
                      // Because it is just a POC, I am not going to refactor anything
                      // but I agree that this is crap.
                      Visibility(
                          visible: _selectedImage != null,
                          maintainState: false,
                          child: _issue.keywords == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    Text('Loading keywords...'),
                                  ],
                                )
                              : Column(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          children: [
                                            _issue.getAddress(),
                                            Text(
                                              'Keywords: ${_issue.keywords!.map((e) => e.description).join(', ')}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        )),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          LocationDecider(
                                                              issue: _issue)));
                                            },
                                            child: const Text(
                                                "Choose this picture")),
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _issue.image = null;
                                                _selectedImage = null;
                                              });
                                            },
                                            child: const Text(
                                                "Choose another picture"))
                                      ],
                                    )
                                  ],
                                )),
                    ]));
              } else {
                return const Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      CircularProgressIndicator(),
                      Text(
                          "We're trying to get your location, please wait a moment...")
                    ]));
              }
            }));
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
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _issue.coordinates = LatLng(pos.latitude, pos.longitude);
    });
    return pos;
  }

  Future _takePic(bool useCamera) async {
    final returnImage = await ImagePicker().pickImage(
        source: useCamera ? ImageSource.camera : ImageSource.gallery);

    if (returnImage == null) {
      return;
    } else {
      if (mounted) {
        setState(() {
          _selectedImage = File(returnImage.path);
        });
      }
    }
    await _makeCall();
  }

  _makeCall() async {
    String? sendData;
    if (_selectedImage != null) {
      Uint8List imgbytes = await _selectedImage!.readAsBytes();
      sendData = base64.encode(imgbytes);
    }

    // I fully know that putting the API Key in full in the code is not good practice
    // and can lead to security issue, or having my key stolen.
    // For the record, this key is only allowed to call the vision API
    // which heavily limit the power it has. 
    // While having the key like this isn't optimal, it is acceptable for the POC. 
    final url = Uri.parse(
        "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyC02yw_zH30GZxEUdcSdg9CADODSGyWTuw");

    final requestBody = {
      "requests": [
        {
          "image": {"content": sendData},
          "features": [
            {"type": "LABEL_DETECTION", "maxResults": 20}
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
      Map<String, dynamic> list =
          jsonDecode(response.body) as Map<String, dynamic>;
      for (var keyword in list['responses'][0]['labelAnnotations']) {
        WordTag wordTag = WordTag.fromJson(keyword);
        wordSet.add(wordTag);
      }
      print(wordSet.map((e) => e.description).toList().toString());
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
