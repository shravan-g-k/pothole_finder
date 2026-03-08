import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/pages/maps/map_top_bar.dart';
import 'package:frontend/utils/constants/routes/routes.dart';
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
  final List<LatLng> routePoints = [];

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
            permission != LocationPermission.whileInUse) {
          return;
        }
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        context.read<MapsBloc>().add(
          SetLiveLocation(LatLng(pos.latitude, pos.longitude)),
        );
      }
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 14),
      );
    } catch (e) {
      debugPrint("GPS error: $e");
    }
  }

  void onTap() {
    Navigator.pushNamed(context, Routes.searchPage);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BlocConsumer<MapsBloc, MapsState>(
          bloc: context.read<MapsBloc>(),
          buildWhen: (prev, curr) => curr is RouteLoaded || curr is RouteError,
          listener: (context, state) {
            if (state is RouteError) {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(); // Close loading dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error loading route: ${state.message}"),
                ),
              );
            }
            if (state is RouteLoading) {
              showDialog(
                context: context,
                builder: (context) {
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }
          },
          builder: (context, state) {
            if (state is RouteLoaded) {
              routePoints.addAll(state.routePoints);
              Navigator.of(
                context,
                rootNavigator: true,
              ).pop(); // Close loading dialog
            }
            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _karnatakaCenter,
                zoom: 7,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId("route"),
                  color: Colors.blue,
                  width: 5,
                  points: routePoints,
                ),
              },
              mapType: _currentMapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              compassEnabled: true,
              onMapCreated: (controller) => _mapController = controller,
            );
          },
        ),
        MapTopBar(),
        // Map type toggle buttons — top right
        Positioned(
          top: 200,
          right: 12,
          child: Column(
            children: [
              _mapTypeButton("Normal", Icons.map_outlined, MapType.normal),
              const SizedBox(height: 8),
              _mapTypeButton(
                "Satellite",
                Icons.satellite_alt,
                MapType.satellite,
              ),
              const SizedBox(height: 8),
              _mapTypeButton(
                "Terrain",
                Icons.landscape_outlined,
                MapType.terrain,
              ),
              const SizedBox(height: 8),
              _mapTypeButton("Hybrid", Icons.layers_outlined, MapType.hybrid),
            ],
          ),
        ),

        // GPS/compass button — bottom right
        Positioned(
          bottom: 100,
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
