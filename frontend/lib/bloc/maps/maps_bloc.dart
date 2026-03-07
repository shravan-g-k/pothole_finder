import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:frontend/repo/maps_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'maps_event.dart';
part 'maps_state.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  final MapsRepo mapsRepo;
  MapsBloc(this.mapsRepo) : super(MapsInitial()) {
    on<GetRouteCalled>((event, emit) async {
      emit(RouteLoading());
      try {
        final route = await mapsRepo.getRoute([event.start, event.end]);
        final decodeJSON = (jsonDecode(route)['polyline']['coordinates'] as List<dynamic>).map(
          (coord) => List<double>.from(coord),
        ).toList();
        //deocde string to json then get polyline and cocordinates
        final routePoints = mapsRepo.changeGeoJsonToLatLng(
          decodeJSON,
        );
        emit(RouteLoaded(routePoints));
      } catch (e) {
        emit(RouteError(e.toString()));
      }
    });
  }
}
