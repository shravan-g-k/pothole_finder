part of 'maps_bloc.dart';

@immutable
sealed class MapsState {}

final class MapsInitial extends MapsState {}

final class MapsRouteLoading extends MapsState {}

// final class MapsRouteLoaded extends MapsState {
//   final List<LatLng> routePoints;

//   MapsRouteLoaded(this.routePoints);
// }