part of 'maps_bloc.dart';

@immutable
sealed class MapsEvent {}

class GetRouteCalled extends MapsEvent {
  final LatLng start;
  final LatLng end;

  GetRouteCalled(this.start, this.end);
}