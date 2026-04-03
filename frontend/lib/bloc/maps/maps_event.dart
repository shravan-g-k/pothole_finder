part of 'maps_bloc.dart';

@immutable
sealed class MapsEvent {}

class GetRouteCalled extends MapsEvent {
  final LatLng start;
  final String startAddress;
  final LatLng end;
  final String endAddress;

  GetRouteCalled(this.start, this.end, this.startAddress, this.endAddress);
}


class ResetMap extends MapsEvent {}

class SetLiveLocation extends MapsEvent {
  final LatLng liveLocation;

  SetLiveLocation(this.liveLocation);
}

class StartNavigation extends MapsEvent {
  final List<LatLng> routePoints;
  final List<RouteSegmentModel> routeSegments;

  StartNavigation(this.routePoints, this.routeSegments);
}

class StopNavigation extends MapsEvent {}