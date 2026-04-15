import 'package:bloc/bloc.dart';
import 'package:frontend/models/route_point_model/route_segment_model.dart';
import 'package:frontend/repo/maps_repo.dart';
import 'package:frontend/utils/helpers/permission_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';

part 'maps_event.dart';
part 'maps_state.dart';

class MapsBloc extends Bloc<MapsEvent, MapsState> {
  final MapsRepo mapsRepo;
  MapsBloc(this.mapsRepo) : super(MapsInitial(null)) {
    on<GetLiveLocation>((event, emit) async {
      final hasPermission = await PermissionUtils.handleLocationPermission();
      if (hasPermission) {
        final position = await Geolocator.getCurrentPosition();
        emit(
          LiveLocationUpdated(LatLng(position.latitude, position.longitude)),
        );
      }
    });
    on<ResetMap>((event, emit) {
      emit(MapsInitial(state.liveLocation));
    });

    on<MapsRouteLoadedEvent>((event, emit) {
      emit(
        RouteLoaded(
          state.liveLocation,
          points: event.points,
          routePoints: event.routePoints,
          start: event.start,
          destination: event.destination,
          startAddress: event.startAddress,
          endAddress: event.endAddress,
          segments: event.segments,
          distance: event.distance,
          duration: event.duration,
          bboxPoints: event.bboxPoints,
        ),
      );
    });

    on<StartNavigation>((event, emit) {
      emit(
        MapsNavigationStarted(
          state.liveLocation,
          routePoints: event.routePoints,
          allSegments: event.routeSegments,
          distance: event.distance,
          duration: event.duration,
          endAddress: event.endAddress,
        ),
      );
      emit(
        RouteLoadNextSegment(
          state.liveLocation,
          routePoints: event.routePoints,
          allSegments: event.routeSegments,
          currentSegmentIndex: 0,
          distance: event.distance,
          duration: event.duration,
          endAddress: event.endAddress,
        ),
      );
    });

    on<NavigationLocationUpdated>((event, emit) {
      if (state is RouteLoadNextSegment) {
        final currentState = state as RouteLoadNextSegment;
        final currentPosition = event.position;
        final currentSegment = currentState.segment;

        final endWaypointIndex = currentSegment.waypoints.last;
        final targetLatLng = currentState.routePoints[endWaypointIndex];

        final distanceToTurn = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          targetLatLng.latitude,
          targetLatLng.longitude,
        );

        if (distanceToTurn < 15.0) {
          if (currentState.currentSegmentIndex + 1 <
              currentState.allSegments.length) {
            emit(
              currentState.copyWith(
                liveLocation: LatLng(
                  currentPosition.latitude,
                  currentPosition.longitude,
                ),
                currentSegmentIndex: currentState.currentSegmentIndex + 1,
              ),
            );
          } else {
            emit(
              MapsInitial(
                LatLng(currentPosition.latitude, currentPosition.longitude),
              ),
            );
          }
        } else {
          emit(
            currentState.copyWith(
              liveLocation: LatLng(
                currentPosition.latitude,
                currentPosition.longitude,
              ),
            ),
          );
        }
      }
    });
    on<StopNavigation>((event, emit) {
      emit(MapsInitial(state.liveLocation));
    });
  }
}
