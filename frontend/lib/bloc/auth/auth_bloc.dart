import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repo/auth_repo.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
part 'auth_event.dart';
part 'auth_state.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo authRepo;
  AuthBloc(this.authRepo) : super(AuthInitial()) {
    on<AuthCheck>((event, emit) async {
      emit(AuthLoading());
      await for (final user in authRepo.authStateChanges()) {
        if (user != null) {
          emit(AuthLoaded(user));
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
  }
}
