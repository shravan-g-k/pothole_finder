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
  final LatLngBounds bboxPoints;

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
    required this.bboxPoints,
  });
}

final class RouteLoadNextSegment extends MapsState {
  final List<LatLng> routePoints;
  final List<RouteSegmentModel> allSegments;
  final int currentSegmentIndex;
  final String distance;
  final String duration;
  final String endAddress;

  const RouteLoadNextSegment(
    super.liveLocation, {
    required this.routePoints,
    required this.allSegments,
    required this.currentSegmentIndex,
    required this.distance,
    required this.duration,
    required this.endAddress,
  });

  RouteSegmentModel get segment => allSegments[currentSegmentIndex];

  RouteSegmentModel? get nextSegment =>
      (currentSegmentIndex + 1 < allSegments.length)
          ? allSegments[currentSegmentIndex + 1]
          : null;

  RouteLoadNextSegment copyWith({
    LatLng? liveLocation,
    int? currentSegmentIndex,
  }) {
    return RouteLoadNextSegment(
      liveLocation ?? this.liveLocation,
      routePoints: routePoints,
      allSegments: allSegments,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
      distance: distance,
      duration: duration,
      endAddress: endAddress,
    );
  }
}

final class MapsNavigationStarted extends MapsState {
  final List<LatLng> routePoints;
  final List<RouteSegmentModel> allSegments;
  final String distance;
  final String duration;
  final String endAddress;

  const MapsNavigationStarted(
    super.liveLocation, {
    required this.routePoints,
    required this.allSegments,
    required this.distance,
    required this.duration,
    required this.endAddress,
  });
}

final class MapsRouteError extends MapsState {
  final String message;

  const MapsRouteError(this.message, super.liveLocation);
}
