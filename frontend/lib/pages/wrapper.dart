import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/pages/auth/user_info_fields_page.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/utils/widgets/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLocationMissing) {
          context.read<AuthBloc>().add(
            AuthLocationSaveRequested(state.user.id),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoaded) {
          return const Home();
        }
        if (state is AuthUnauthenticated) {
          return const UserInfoFieldsPage();
        }
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // AuthInitial, AuthLocationMissing, AuthError
        return const SplashScreen();
      },
    );
  }
}