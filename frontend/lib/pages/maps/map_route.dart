// MAP view of the location of the user

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {


  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Test coordinates
  LatLng from = LatLng(12.9756, 77.6060);
  LatLng to   = LatLng(12.9177, 77.6238);

  Future<List<LatLng>> getRoute(LatLng from, LatLng to) async {
    final url =
        "https://api.openrouteservice.org/v2/directions/driving-car"
        "?api_key=eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImQ4ZDJiMTM4"
        "NDRhMjRhMWJiZjIzZjM5MGMxMDRmMzA5IiwiaCI6Im11cm11cjY0In0="
        "&start=${from.longitude},${from.latitude}"
        "&end=${to.longitude},${to.latitude}";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Route API failed");
    }

    final data = jsonDecode(response.body);

    final coords = data["features"][0]["geometry"]["coordinates"];

    // Convert [lng, lat] ➜ LatLng(lat, lng)
    return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }
  void testRoute() async {
    LatLng from = LatLng(12.9756, 77.6060);
    LatLng to = LatLng(12.9177, 77.6238);

    List<LatLng> points = await getRoute(from, to);
    print(points); // Prints all LatLng points
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Route Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            List<LatLng> points = await getRoute(from, to);
            print(points);           // prints route points
            print(points.length);    // number of polyline points
          },
          child: const Text("Fetch Route"),
        ),
      ),
    );
  }
}
