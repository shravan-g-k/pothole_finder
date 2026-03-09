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
  final Set<Polyline> routePoints;
  final LatLng start;
  final LatLng destination;

  const RouteLoaded(
    super.liveLocation, {
    required this.routePoints,
    required this.start,
    required this.destination,
  });
}

final class RouteError extends MapsState {
  final String message;

  const RouteError(this.message, super.liveLocation);
}
