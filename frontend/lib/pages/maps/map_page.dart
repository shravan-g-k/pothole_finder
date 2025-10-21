import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LatLng KarnatakaCenter = LatLng(15.3173, 75.7139);



    final LatLngBounds indiaBounds = LatLngBounds(
      // South-West Corner (Min Latitude, Min Longitude)
      LatLng(6.55, 68.11),

      // North-East Corner (Max Latitude, Max Longitude)
      LatLng(35.67, 97.40),
    );

    // final LatLngBounds karnatakaBounds = LatLngBounds(
    //   // South-West Corner (Min Lat, Min Long)
    //   LatLng(11.48, 73.64),
    //
    //   // North-East Corner (Max Lat, Max Long)
    //   LatLng(18.53, 78.62),
    // );


    return FlutterMap(options:  MapOptions(
      interactionOptions: const InteractionOptions(
        flags: InteractiveFlag.all & ~InteractiveFlag.rotate, // Removes the rotate flag
      ),
      initialCenter: KarnatakaCenter ,
      initialZoom: 5,
        maxZoom: 19,
      cameraConstraint: CameraConstraint.contain(bounds:indiaBounds ),
      crs:  Epsg3857(),

      
    ),
        children: [
         TileLayer(
           urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
           userAgentPackageName: 'com.example.pothole_finder',     //comes under legal constraints to be followed
         ),





          CircleLayer(circles: [CircleMarker(
          point: KarnatakaCenter,
    radius: 400000, // in meters (50 km)
    useRadiusInMeter: true,
    color: Color.fromRGBO(127, 166, 162, 0.2901960784313726),
    borderColor: Colors.red,
    borderStrokeWidth: 2,
    )])
    ]);
  }
}

//map rotations have to be set up