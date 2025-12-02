import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
// ignore: unused_import
import 'package:frontend/pages/auth/user_info_fields_page.dart';
import 'package:frontend/pages/wrapper.dart';
import 'package:frontend/repo/auth_repo.dart';
import 'package:frontend/utils/helpers/instance_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepo>(
          create: (_) => AuthRepo(InstanceProviders.supabaseClient.auth),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(context.read<AuthRepo>())),
        ],
        child: MaterialApp(
          title: 'Pothole Finder',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}
