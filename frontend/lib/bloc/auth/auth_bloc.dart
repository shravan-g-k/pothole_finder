import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repo/auth_repo.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo authRepo;

  AuthBloc(this.authRepo) : super(AuthInitial()) {

    on<AuthCheck>((event, emit) async {
      emit(AuthLoading());
      await for (final user in authRepo.authStateChanges()) {
        if (user != null) {
          final profile = await authRepo.getUserProfile(user.id);
          if (profile == null || profile['home_location'] == null) {
            emit(AuthLocationMissing(user));
          } else {
            emit(AuthLoaded(user));
          }
        } else {
          emit(AuthUnauthenticated());
        }
      }
    });

    add(AuthCheck());

    on<BasicInfoFormSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signInWithGoogle();
      } catch (error) {
        emit(AuthError(error.toString()));
      }
    });

    on<AuthSignOutRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signOut();
        emit(AuthUnauthenticated());
      } catch (error) {
        emit(AuthError(error.toString()));
      }
    });

    on<AuthLocationSaveRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.always &&
              permission != LocationPermission.whileInUse) {
            emit(AuthError('Location permission denied.'));
            return;
          }
        }

        final Position pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        final locationString = '${pos.latitude},${pos.longitude}';
        await authRepo.updateHomeLocation(event.userId, locationString);

        final user = authRepo.supabaseAuth.currentUser;
        if (user != null) emit(AuthLoaded(user));
      } catch (error) {
        emit(AuthError(error.toString()));
      }
    });
  }
}