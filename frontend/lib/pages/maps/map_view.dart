import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;

  static const LatLng _karnatakaCenter = LatLng(15.3173, 75.7139);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _setCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(pos.latitude, pos.longitude),
          14,
        ),
      );
    } catch (e) {
      debugPrint("GPS error: $e");
    }
  }

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  void onTap() {
    
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: _karnatakaCenter,
            zoom: 7,
          ),
          mapType: _currentMapType,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          compassEnabled: true,
          onMapCreated: (controller) => _mapController = controller,
        ),

        // Map type toggle buttons — top right
        Positioned(
          top: 40,
          right: 12,
          child: Column(
            children: [
              _mapTypeButton("Normal", Icons.map_outlined, MapType.normal),
              const SizedBox(height: 8),
              _mapTypeButton("Satellite", Icons.satellite_alt, MapType.satellite),
              const SizedBox(height: 8),
              _mapTypeButton("Terrain", Icons.landscape_outlined, MapType.terrain),
              const SizedBox(height: 8),
              _mapTypeButton("Hybrid", Icons.layers_outlined, MapType.hybrid),
            ],
          ),
        ),

        // GPS/compass button — bottom right
        Positioned(
          bottom: 30,
          right: 20,
          child: FloatingActionButton(
            heroTag: "gps",
            onPressed: _setCurrentLocation,
            child: const Icon(CupertinoIcons.compass),
          ),
        ),
      ],
    );
  }

  Widget _mapTypeButton(String tag, IconData icon, MapType type) {
    final bool isActive = _currentMapType == type;
    return FloatingActionButton.small(
      heroTag: tag,
      backgroundColor: isActive ? Colors.blue : Colors.white,
      foregroundColor: isActive ? Colors.white : Colors.black87,
      elevation: isActive ? 4 : 2,
      onPressed: () {
        if (!isActive) setState(() => _currentMapType = type);
      },
      child: Icon(icon),
    );
  }
}