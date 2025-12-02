import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/auth/auth_bloc.dart';
// ignore: unused_import
import 'package:frontend/pages/auth/user_info_fields_page.dart';
import 'package:frontend/pages/wrapper.dart';
import 'package:frontend/repo/auth_repo.dart';
import 'package:frontend/utils/helpers/instance_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: "lib/.env");

  // final supabaseUrl = dotenv.env['SUPABASE_URL']!;
  // final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  await Supabase.initialize(
    url: "https://rpwdsjjhgiicqvrzojog.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJwd2RzampoZ2lpY3F2cnpvam9nIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MTM0NTQsImV4cCI6MjA4MDA4OTQ1NH0.juADVYShWJQnRPcZNJ_Z7bSDxEcGV8HBx7ERT0jLUgw",
  );
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
