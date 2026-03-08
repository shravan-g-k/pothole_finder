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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoaded) {
          return const Home();
        } else if (state is AuthUnauthenticated) {
          return const UserInfoFieldsPage();
        }
        return const SplashScreen();
      },
    );
  }
}
