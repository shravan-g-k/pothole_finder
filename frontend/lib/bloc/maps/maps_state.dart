part of 'maps_bloc.dart';

@immutable
sealed class MapsState {
  final LatLng? liveLocation;

  const MapsState({this.liveLocation});
}

final class MapsInitial extends MapsState {}

final class LiveLocationUpdated extends MapsState {
  const LiveLocationUpdated({super.liveLocation});
}

final class RouteLoading extends MapsState {}

final class RouteLoaded extends MapsState {
  final List<LatLng> routePoints;

  const RouteLoaded(this.routePoints);
}

final class RouteError extends MapsState {
  final String message;

  const RouteError(this.message);
}
