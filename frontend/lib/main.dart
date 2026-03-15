import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:frontend/pages/auth/clerk_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClerkAuth(
      config: ClerkAuthConfig(
        publishableKey: dotenv.env['CLERK_PUBLISHABLE_KEY'] ?? '',
      ),
      child: MaterialApp(
        title: 'Pothole Finder',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: ClerkAuthWrapper(),
      ),
    );
  }
}