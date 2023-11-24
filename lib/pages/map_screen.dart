import 'package:categorizer2/models/issue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.issue}) : super(key: key);
  final Issue issue;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
      ),
      body: FlutterMap(
        mapController: MapController(),
        options: MapOptions(
          initialCenter: widget.issue.coordinates!,
          onTap: (tapPosition, point) => {
              setState(() {
                markerCoord = point;
              }),
            },
        ),
        children: [
          TileLayer(
            minZoom: 2,
            maxZoom: 18,
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: [
              if (markerCoord != null)
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: markerCoord!,
                  child: const Icon(
                    Icons.location_pin,
                    color: Color.fromARGB(255, 236, 0, 0),
                    size: 45.0,
                  ),
                ),
            ])
        ],
      )
    );
  }

  LatLng? markerCoord;
}