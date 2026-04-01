import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/repo/auth_repo.dart';
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
          //if(function call to user repo){
              //if user exists 
              // emit(AuthLoaded(user));
          // }else{
          // emit(AuthDetailsMissing());
          // }
          // call the function check if the user not null 
          // if user is not null then emit AuthLoaded(user) else emit AuthUnauthenticated()
          
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
        print(error);
        emit(AuthError(error.toString()));
      }
    });
  }
}
