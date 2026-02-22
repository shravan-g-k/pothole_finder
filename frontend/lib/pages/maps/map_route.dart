import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRoute extends StatefulWidget {
  const MapRoute({super.key});

  @override
  State<MapRoute> createState() => _MapRouteState();
}

class _MapRouteState extends State<MapRoute> {
  GoogleMapController? _mapController;
  MapType _currentMapType = MapType.normal;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(15.3173, 75.7139),
    zoom: 7,
  );

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            compassEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
          ),

          // Map type toggle — top right
          Positioned(
            top: 40,
            right: 12,
            child: Column(
              children: [
                _mapTypeButton("r_normal", Icons.map_outlined, MapType.normal),
                const SizedBox(height: 8),
                _mapTypeButton("r_satellite", Icons.satellite_alt, MapType.satellite),
                const SizedBox(height: 8),
                _mapTypeButton("r_terrain", Icons.landscape_outlined, MapType.terrain),
                const SizedBox(height: 8),
                _mapTypeButton("r_hybrid", Icons.layers_outlined, MapType.hybrid),
              ],
            ),
          ),
        ],
      ),
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