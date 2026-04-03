import 'package:bloc/bloc.dart';
import 'package:frontend/repo/maps_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

part 'maps_event.dart';
part 'maps_state.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  final MapsRepo mapsRepo;
  MapsBloc(this.mapsRepo) : super(MapsInitial(null)) {
    on<GetRouteCalled>((event, emit) async {
      emit(RouteLoading(state.liveLocation));
      try {
        final response = await mapsRepo.getRoute(event.start, event.end);
        
        final String encodedPolyline = response['polyline'];
        final String compressedSegments = response['segments'];

        final routePoints = mapsRepo.decodeRoutePolyline(encodedPolyline);
        final segments = mapsRepo.decompressSegments(compressedSegments);

        emit(
          RouteLoaded(
            state.liveLocation,
            routePoints: mapsRepo.createPolylines(routePoints),
            start: event.start,
            destination: event.end,
            startAddress: event.startAddress,
            endAddress: event.endAddress,
            segments: segments,
          ),
        );
      } catch (e) {
        emit(RouteError(e.toString(), null));
      }
    });
    on<SetLiveLocation>((event, emit) {
      emit(LiveLocationUpdated(event.liveLocation));
    });
    on<ResetMap>((event, emit) {
      emit(MapsInitial(state.liveLocation));
    });
  }
}
