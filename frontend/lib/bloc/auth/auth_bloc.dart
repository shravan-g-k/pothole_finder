import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repo/auth_repo.dart';
import 'package:meta/meta.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepo authRepo;
  AuthBloc(this.authRepo) : super(AuthInitial()) {
    on<BasicInfoFormSubmitted>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepo.signInWithGoogle();
        emit(AuthLoaded());
      } catch (error) {
        emit(AuthError(error.toString()));
      }
    });
  }
}
