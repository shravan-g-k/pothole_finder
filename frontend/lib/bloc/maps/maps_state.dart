part of 'maps_bloc.dart';

@immutable
sealed class MapsState {
  final LatLng? liveLocation;

  const MapsState(this.liveLocation);
}

final class MapsInitial extends MapsState {
  const MapsInitial(super.liveLocation);
}

final class LiveLocationUpdated extends MapsState {
  const LiveLocationUpdated(super.liveLocation);
}

final class RouteLoading extends MapsState {
  const RouteLoading(super.liveLocation);
}

final class RouteLoaded extends MapsState {
  final List<LatLng> points;
  final Set<Polyline> routePoints;
  final LatLng start;
  final LatLng destination;
  final String startAddress;
  final String endAddress;
  final String distance;
  final String duration;
  final List<RouteSegmentModel> segments;

  const RouteLoaded(
    super.liveLocation, {
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

final class RouteLoadNextSegment extends MapsState {
  final List<LatLng> routePoints;
  final RouteSegmentModel segment;
  final RouteSegmentModel? nextSegment;
  final String distance;
  final String duration;
  final String endAddress;

  const RouteLoadNextSegment(
    super.liveLocation, {
    required this.routePoints,
    required this.segment,
    required this.nextSegment,
    required this.distance,
    required this.duration,
    required this.endAddress,
  });
}

final class RouteError extends MapsState {
  final String message;

  const RouteError(this.message, super.liveLocation);
}
