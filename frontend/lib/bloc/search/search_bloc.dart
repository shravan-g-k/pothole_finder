import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/models/place_model/place_model.dart';
import 'package:frontend/models/route_point_model/route_segment_model.dart';
import 'package:frontend/repo/maps_repo.dart';
import 'package:frontend/utils/exceptions/location_exception.dart';
import 'package:frontend/utils/helpers/location_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final MapsRepo _mapsRepo;
  SearchBloc(this._mapsRepo) : super(SearchInitial()) {
    on<SearchQueryChanged>((event, emit) async {
      emit(SearchLoading());

      try {
        final suggestions = await _fetchSearchSuggestions(event.query);
        emit(SearchSuccess(suggestions));
      } catch (e) {
        debugPrint(e.toString());
        emit(SearchFailure(e.toString()));
      }
    });

    on<SearchLocationSubmitted>((event, emit) async {
      emit(SearchRouteLoading());
      try {
        final liveLocation = await LocationUtils.getCurrentLocation();
        final response = await _mapsRepo.getRoute(liveLocation, event.end);

        final String encodedPolyline = response['polyline'];
        final String compressedSegments = response['segments'];

        final routePoints = _mapsRepo.decodeRoutePolyline(encodedPolyline);
        final dynamicRawSegments = _mapsRepo.decompressSegments(
          compressedSegments,
        );

        // ORS returns a list of segments, each with overall distance/duration and a list of steps.
        // For a 2-point route, we typically care about the first segment.
        final firstSegment = dynamicRawSegments[0] as Map<String, dynamic>;
        final rawDistance = firstSegment['distance'] as num;
        final rawDuration = firstSegment['duration'] as num;

        final String distanceStr =
            rawDistance >= 1000
                ? "${(rawDistance / 1000).toStringAsFixed(1)} km"
                : "${rawDistance.toInt()} m";

        final int mins = (rawDuration / 60).toInt();
        final String durationStr =
            mins >= 60 ? "${mins ~/ 60} h ${mins % 60} min" : "$mins min";

        final List<RouteSegmentModel> segments =
            (firstSegment['steps'] as List<dynamic>)
                .map(
                  (s) => RouteSegmentModel.fromJson(s as Map<String, dynamic>),
                )
                .toList();

        emit(
          SearchRouteLoaded(
            points: routePoints,
            routePoints: _mapsRepo.createPolylines(routePoints),
            start: liveLocation,
            destination: event.end,
            startAddress: "",
            endAddress: event.endAddress,
            segments: segments,
            distance: distanceStr,
            duration: durationStr,
          ),
        );
      } on LocationPermissionDeniedException catch (e) {
        emit(SearchRouteLocationError(e.cause));
      } catch (e) {
        emit(SearchRouteError(e.toString()));
      }
    });
  }

  Future<List<PlaceModel>> _fetchSearchSuggestions(String query) async {
    return await _mapsRepo.getTextSearchResults(query);
  }
}
