import 'package:flutter/material.dart';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:frontend/pages/home.dart';
import 'package:frontend/pages/on_boarding/on_boarding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClerkAuthWrapper extends StatefulWidget {
  const ClerkAuthWrapper({super.key});

  @override
  State<ClerkAuthWrapper> createState() => _ClerkAuthWrapperState();
}

class _ClerkAuthWrapperState extends State<ClerkAuthWrapper> {
  SupabaseClient? supabaseClient;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    supabaseClient = SupabaseClient(
      dotenv.env['SUPABASE_URL']!,
      dotenv.env['SUPABASE_ANON_KEY']!,
      accessToken: () async {
        final token = await ClerkAuth.of(context).sessionToken();
        return token?.jwt;
      },
    );
  }

  Future<Widget> _getDestination(String clerkUserId) async {
    // Check if user row exists
    final data = await supabaseClient!
        .from('user_data')
        .select()
        .eq('clerk_user_id', clerkUserId)
        .maybeSingle();

    if (data == null) {
      // New user — create a row
      await supabaseClient!.from('user_data').insert({
        'clerk_user_id': clerkUserId,
      });
      return OnBoardingPage( supabaseClient!);
    }

    // Existing user — check if home_location is set
    if (data['home_location'] == null) {
      return OnBoardingPage( supabaseClient!);
    }

    return Home(supabaseClient: supabaseClient!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ClerkErrorListener(
          child: ClerkAuthBuilder(
            signedInBuilder: (context, authState) {
              return FutureBuilder<Widget>(
                future: _getDestination(authState.user!.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return snapshot.data!;
                },
              );
            },
            signedOutBuilder: (context, authState) {
              return const ClerkAuthentication();
            },
          ),
        ),
      ),
    );
  }
}