part of 'maps_bloc.dart';

@immutable
sealed class MapsEvent {}



class ResetMap extends MapsEvent {}

class MapsRouteLoadedEvent extends MapsEvent {
  final List<LatLng> points;
  final Set<Polyline> routePoints;
  final LatLng start;
  final LatLng destination;
  final String startAddress;
  final String endAddress;
  final String distance;
  final String duration;
  final List<RouteSegmentModel> segments;
  MapsRouteLoadedEvent({
    required this.points,
    required this.routePoints,
    required this.start,
    required this.destination,
    required this.startAddress,
    required this.endAddress,
    required this.segments,
    required this.distance,
    required this.duration,
  });
}

class StartNavigation extends MapsEvent {
  final List<LatLng> routePoints;
  final List<RouteSegmentModel> routeSegments;
  final String distance;
  final String duration;
  final String endAddress;

  StartNavigation(
    this.routePoints,
    this.routeSegments,
    this.distance,
    this.duration,
    this.endAddress,
  );
}

class StopNavigation extends MapsEvent {}

class GetLiveLocation extends MapsEvent {}