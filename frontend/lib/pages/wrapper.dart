import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
import 'package:frontend/pages/auth/user_info_fields_page.dart';
import 'package:frontend/pages/home/home_page.dart';
import 'package:frontend/utils/helpers/instance_providers.dart';
import 'package:frontend/utils/widgets/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
      
      },
      child: SplashScreen(),
    );
  }
}
