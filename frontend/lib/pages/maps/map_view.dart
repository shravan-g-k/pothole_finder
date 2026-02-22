import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  void onTap() {
    
  }
  @override
  Widget build(BuildContext context) {
    final LatLng karnatakaCenter = LatLng(15.3173, 75.7139);

    final LatLngBounds indiaBounds = LatLngBounds(
      // South-West Corner (Min Latitude, Min Longitude)
      LatLng(6.55, 68.11),

      // North-East Corner (Max Latitude, Max Longitude)
      LatLng(35.67, 97.40),
    );
    return FlutterMap(
      options: MapOptions(
        interactionOptions: const InteractionOptions(
          flags:
              InteractiveFlag.all &
              ~InteractiveFlag.rotate, // Removes the rotate flag
        ),
        initialCenter: karnatakaCenter,
        initialZoom: 5,
        maxZoom: 19,
        cameraConstraint: CameraConstraint.contain(bounds: indiaBounds),
        crs: Epsg3857(),
      ),
      children: [
       
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName:
              'com.example.pothole_finder', //comes under legal constraints to be followed
        ),
      ],
    );
  }
}

//map rotations have to be set up
