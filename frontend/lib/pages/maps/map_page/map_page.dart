import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/pages/maps/map_page/map_top_bar.dart';
import 'package:frontend/pages/maps/map_page/map_view.dart';
import 'package:frontend/pages/maps/map_page/map_type_selector.dart';
import 'package:frontend/pages/maps/map_page/gps_button.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final ValueNotifier<MapType> _mapTypeNotifier = ValueNotifier(MapType.normal);
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
  }

  @override
  void dispose() {
    _mapTypeNotifier.dispose();
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

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(pos.latitude, pos.longitude),
              zoom: 15,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("GPS error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder<MapType>(
          valueListenable: _mapTypeNotifier,
          builder: (_, mapType, __) => MapView(
            mapType: mapType,
            onMapCreated: (controller) => _mapController = controller,
          ),
        ),
        const MapTopBar(),
        Positioned(
          top: 200,
          right: 12,
          child: MapTypeSelector(mapTypeNotifier: _mapTypeNotifier),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: GpsButton(onPressed: _setCurrentLocation),
        ),
      ],
    );
  }
}
