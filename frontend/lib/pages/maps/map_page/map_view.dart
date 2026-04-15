import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/maps/maps_bloc.dart';
import 'package:frontend/utils/helpers/location_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class MapView extends StatefulWidget {
  const MapView({super.key, required this.mapType});
  final MapType mapType;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;

  static const LatLng _karnatakaCenter = LatLng(15.3173, 75.7139);

  final ValueNotifier<Set<Polyline>> polylines = ValueNotifier<Set<Polyline>>(
    {},
  );

  int _currentRouteIndex = 0;
  List<LatLng> _fullRoutePoints = [];
  MediaQueryData get _mq => MediaQuery.of(context);

  void _zoomOutOnRoute(LatLngBounds routeBounds) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(routeBounds, _mq.size.width * 0.35),
    );
  }

  void _onUserLocationUpdate(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  void _onError(String message) {
    Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error: $message")));
  }

  void _onRouteLoaded(RouteLoaded state) {
    polylines.value = Set<Polyline>.from(state.routePoints);
    _zoomOutOnRoute(state.bboxPoints);
    Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
  }

    void _startNavigation(RouteLoaded state) {
      // TODO emit proper state to start loadin segmenst
      // context.read<MapsBloc>().add(RouteLoadNextSegment(state.liveLocation, routePoints: routePoints, allSegments: allSegments, currentSegmentIndex: currentSegmentIndex, distance: distance, duration: duration, endAddress: endAddress));
      LocationUtils.getLocationStream().listen((location) {
        if (!mounted) return;

        LatLng currentPos = LatLng(location.latitude, location.longitude);

        _mapController?.animateCamera(CameraUpdate.newLatLng(currentPos));

        // Snap the polyline
        _updatePolylineProgress(currentPos);

        context.read<MapsBloc>().add(NavigationLocationUpdated(location));
      });
    }
  
  void _updatePolylineProgress(LatLng currentLocation) {
    if (_fullRoutePoints.isEmpty) return;

    double minDistance = double.infinity;
    int closestIndex = _currentRouteIndex;

    // 1. Convert the user's current Google Maps LatLng to Maps Toolkit LatLng
    final mp.LatLng mpCurrentLocation = mp.LatLng(
      currentLocation.latitude,
      currentLocation.longitude,
    );

    // Look-ahead window: Check the next 100 points
    int lookAheadLimit = math.min(
      _currentRouteIndex + 100,
      _fullRoutePoints.length,
    );

    for (int i = _currentRouteIndex; i < lookAheadLimit; i++) {
      // 2. Convert route point to Maps Toolkit LatLng
      final mp.LatLng mpRoutePoint = mp.LatLng(
        _fullRoutePoints[i].latitude,
        _fullRoutePoints[i].longitude,
      );

      // 3. Use SphericalUtil to calculate the distance (returns num, so cast to double)
      double distance =
          mp.SphericalUtil.computeDistanceBetween(
            mpCurrentLocation,
            mpRoutePoint,
          ).toDouble();

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    // 4. Update the polyline if the user has moved forward
    if (closestIndex > _currentRouteIndex) {
      _currentRouteIndex = closestIndex;

      List<LatLng> traveledRoute = _fullRoutePoints.sublist(
        0,
        _currentRouteIndex + 1,
      );
      List<LatLng> remainingRoute = _fullRoutePoints.sublist(
        _currentRouteIndex,
      );

      polylines.value = {
        Polyline(
          polylineId: const PolylineId('traveled_route'),
          color: Colors.grey, // Faded color for crossed path
          width: 5,
          points: traveledRoute,
        ),
        Polyline(
          polylineId: const PolylineId('remaining_route'),
          color: Colors.blue, // Active color for path ahead
          width: 5,
          points: remainingRoute,
        ),
      };
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapsBloc, MapsState>(
      bloc: context.read<MapsBloc>(),
      buildWhen:
          (prev, curr) =>
              curr is RouteLoaded ||
              curr is MapsRouteError ||
              curr is MapsInitial,
      listener: (context, state) {
        if (state is MapsInitial) {
          polylines.value = <Polyline>{};
        } else if (state is MapsRouteError) {
          _onError(state.message);
        } else if (state is RouteLoaded) {
          _onRouteLoaded(state);
        } else if (state is LiveLocationUpdated) {
          _onUserLocationUpdate(state.liveLocation!);
        } else if (state is NavigationStarted) {
          _fullRoutePoints = state.routePoints;
          _startNavigation(state);
        }
      },
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: polylines,
          builder: (context, value, child) {
            return GoogleMap(
              initialCameraPosition: const CameraPosition(
                target:
                    _karnatakaCenter, //TODO:relace with home or last fetched location
                zoom: 7,
              ),
              polylines: polylines.value,
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
              },
            );
          },
        );
      },
    );
  }
}
