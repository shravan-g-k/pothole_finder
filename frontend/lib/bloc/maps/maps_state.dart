part of 'maps_bloc.dart';

@immutable
sealed class MapsState {}

final class MapsInitial extends MapsState {}

final class RouteLoading extends MapsState {}

final class RouteLoaded extends MapsState {
  final List<LatLng> routePoints;

  RouteLoaded(this.routePoints);
}

final class RouteError extends MapsState {
  final String message;

  RouteError(this.message);
}