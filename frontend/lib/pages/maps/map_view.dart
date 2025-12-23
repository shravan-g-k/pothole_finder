import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/cupertino.dart';
import 'package:trip_routing/trip_routing.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late TextEditingController fromController;
  late TextEditingController toController;

  LatLng? fromLocation;    // Your location (typed OR GPS)
  LatLng? toLocation;      // Destination (typed)

  final LatLng karnatakaCenter = const LatLng(15.3173, 75.7139);

  @override
  void initState() {
    super.initState();
    fromController = TextEditingController();
    toController = TextEditingController();

    // Update when user stops typing (0.6 sec)
    fromController.addListener(() {
      _updateLocationFromText(fromController.text, true);
    });

    toController.addListener(() {
      _updateLocationFromText(toController.text, false);
    });
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  bool _isValidLatLng(LatLng? p) {
    if (p == null) return false;
    return p.latitude.isFinite && p.longitude.isFinite;
  }

  // ---------------------------
  // UPDATE LOCATION FROM TYPING
  // ---------------------------
  Future<void> _updateLocationFromText(String text, bool isFromField) async {
    if (text.trim().isEmpty) return;

    try {
      final results = await locationFromAddress(text);
      if (results.isEmpty) return;

      final LatLng coords =
      LatLng(results.first.latitude, results.first.longitude);

      setState(() {
        if (isFromField) {
          fromLocation = coords;
        } else {
          toLocation = coords;
        }
      });
    } catch (_) {
      // ignore incorrect names
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng safeFrom = _isValidLatLng(fromLocation) ? fromLocation! : karnatakaCenter;
    final LatLng safeTo = _isValidLatLng(toLocation)
        ? toLocation!
        : LatLng(karnatakaCenter.latitude + 1, karnatakaCenter.longitude + 1);

    final bool hasRoute =
        _isValidLatLng(fromLocation) && _isValidLatLng(toLocation);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: karnatakaCenter,
            initialZoom: 7,
            maxZoom: 19,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.pothole_finder',
            ),

            // MARKERS
            MarkerLayer(
              markers: [
                // FROM MARKER
                Marker(
                  point: safeFrom,
                  width: 80,
                  height: 80,
                  child: const Icon(Icons.electric_scooter_rounded,
                      size: 40, color: Colors.blue),
                ),

                // TO MARKER
                if (_isValidLatLng(toLocation))
                  Marker(
                    point: safeTo,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_on_outlined,
                        size: 40, color: Colors.red),
                  ),
              ],
            ),

            // POLYLINE BETWEEN FROM & TO
            if (hasRoute)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [safeFrom, safeTo],
                    color: Colors.blue,
                    strokeWidth: 4,
                  ),
                ],
              ),
          ],
        ),

        // TEXTFIELDS + BUTTON
        Positioned(
          top: 40,
          left: 20,
          right: 20,
          child: Column(
            children: [
              // FROM FIELD
              SizedBox(
                height: 50,
                child: TextField(
                  controller: fromController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.electric_scooter_rounded),
                    hintText: "Your location (type or use GPS)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                  ),
                ),
              ),

              // TO FIELD
              SizedBox(
                height: 50,
                child: TextField(
                  controller: toController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: "Destination (type address)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                  ),
                ),
              ),

              // GPS BUTTON
              Padding(
                padding: const EdgeInsets.fromLTRB(200, 550, 20, 35),
                child: ElevatedButton(
                  onPressed: _setCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Icon(CupertinoIcons.compass, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------
  // GPS + REVERSE GEOCODING
  // ---------------------------
  Future<void> _setCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          return;
        }
      }

      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final LatLng coords = LatLng(pos.latitude, pos.longitude);

      final placemarks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);
      final place = placemarks.first;

      final readable =
          "${place.subLocality}, ${place.locality}, ${place.administrativeArea}";

      setState(() {
        fromLocation = coords;
        fromController.text = readable;
      });
    } catch (e) {
      print("GPS error: $e");
    }
  }
}
