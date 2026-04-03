import 'package:bloc/bloc.dart';
import 'package:frontend/models/route_point_model/route_segment_model.dart';
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
        final dynamicRawSegments = mapsRepo.decompressSegments(
          compressedSegments,
        );
        
        // ORS returns a list of segments, each with overall distance/duration and a list of steps.
        // For a 2-point route, we typically care about the first segment.
        final firstSegment = dynamicRawSegments[0] as Map<String, dynamic>;
        final rawDistance = firstSegment['distance'] as num;
        final rawDuration = firstSegment['duration'] as num;
        
        final String distanceStr = rawDistance >= 1000 
            ? "${(rawDistance / 1000).toStringAsFixed(1)} km" 
            : "${rawDistance.toInt()} m";
            
        final int mins = (rawDuration / 60).toInt();
        final String durationStr = mins >= 60 
            ? "${mins ~/ 60} h ${mins % 60} min" 
            : "$mins min";

        final List<RouteSegmentModel> segments =
            (firstSegment['steps'] as List<dynamic>)
                .map(
                  (s) => RouteSegmentModel.fromJson(s as Map<String, dynamic>),
                )
                .toList();

        emit(
          RouteLoaded(
            state.liveLocation,
            points: routePoints,
            routePoints: mapsRepo.createPolylines(routePoints),
            start: event.start,
            destination: event.end,
            startAddress: event.startAddress,
            endAddress: event.endAddress,
            segments: segments,
            distance: distanceStr,
            duration: durationStr,
          ),
        );
      } catch (e, s) {
        print(e);
        print(s);
        emit(RouteError(e.toString(), null));
      }
    });
    on<SetLiveLocation>((event, emit) {
      emit(LiveLocationUpdated(event.liveLocation));
    });
    on<ResetMap>((event, emit) {
      emit(MapsInitial(state.liveLocation));
    });
    on<StartNavigation>((event, emit) {
      emit(
        RouteNavigationStarted(
          state.liveLocation,
          routePoints: event.routePoints,
          segments: event.routeSegments,
        ),
      );
    });
    on<StopNavigation>((event, emit) {
      emit(MapsInitial(state.liveLocation));
    });
  }
}
