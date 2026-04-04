import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  const MapView({super.key, required this.mapType, this.onMapCreated});
  final MapType mapType;
  final void Function(GoogleMapController)? onMapCreated;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;

  static const LatLng _karnatakaCenter = LatLng(15.3173, 75.7139);

  final Set<Polyline> polylines = {};
  MediaQueryData get _mq => MediaQuery.of(context);

  void _zoomOutOnRoute(LatLng start, LatLng end) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, _mq.size.width * 0.3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapsBloc, MapsState>(
      bloc: context.read<MapsBloc>(),
      buildWhen:
          (prev, curr) =>
              curr is RouteLoaded || curr is RouteError || curr is MapsInitial,
      listener: (context, state) {
        if (state is MapsInitial) {
          polylines.clear();
        } else if (state is RouteError) {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading route: ${state.message}")),
          );
        } else if (state is RouteLoaded) {
          polylines.addAll(state.routePoints);
          _zoomOutOnRoute(state.start, state.destination);
          Navigator.of(
            context,
            rootNavigator: true,
          ).pop(); // Close loading dialog
        } else if (state is RouteLoading) {
          showDialog(
            context: context,
            builder: (context) {
              return const Center(child: CircularProgressIndicator());
            },
          );
        }
      },
      builder: (context, state) {
        return GoogleMap(
          initialCameraPosition: const CameraPosition(
            target:
                _karnatakaCenter, //TODO:relace with home or last fetched location
            zoom: 7,
          ),
          polylines: polylines,
          markers:
              state is RouteLoaded
                  ? {
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: state.destination,
                      infoWindow: const InfoWindow(title: 'Destination'),
                    ),
                  }
                  : {},
          mapType: widget.mapType,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: true,
          compassEnabled: true,
          onMapCreated: (controller) {
            _mapController = controller;
            widget.onMapCreated?.call(controller);
          },
        );
      },
    );
  }
}
