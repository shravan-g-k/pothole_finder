part of 'search_bloc.dart';

@immutable
sealed class SearchState {}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchSuccess extends SearchState {
  final List<PlaceModel> suggestions;

  SearchSuccess(this.suggestions);
}

final class SearchFailure extends SearchState {
  final String error;

  SearchFailure(this.error);
}

final class SearchRouteLoading extends SearchState {}

final class SearchRouteLoaded extends SearchState {
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

  SearchRouteLoaded({
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

final class SearchRouteError extends SearchState {
  final String error;

  SearchRouteError(this.error);
}

final class SearchRouteLocationError extends SearchState {
  final String error;

  SearchRouteLocationError(this.error);
}
