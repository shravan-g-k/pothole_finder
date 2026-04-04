import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthRepo {
  final GoTrueClient supabaseAuth;

  AuthRepo(this.supabaseAuth);

  Future<void> signInWithGoogle() async {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']!;
    final scopes = ['email', 'profile'];
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(serverClientId: webClientId);
    final googleUser = await googleSignIn.attemptLightweightAuthentication();
    if (googleUser == null) {
      throw AuthException('Failed to sign in with Google.');
    }

    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
            await googleUser.authorizationClient.authorizeScopes(scopes);
    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw AuthException('No ID Token found.');
    }
    await supabaseAuth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );
  }

  Future<void> signOut() async {
    await supabaseAuth.signOut();
  }

  Stream<User?> authStateChanges() async* {
    // Immediately emit current session so bloc doesn't hang on startup
    yield supabaseAuth.currentUser;
    // Then listen for future auth changes
    yield* supabaseAuth.onAuthStateChange.map((data) => data.session?.user);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_data')
          .select()
          .eq('id', userId)
          .single()
          .timeout(const Duration(seconds: 5));
      return response;
    } catch (e) {
      debugPrint('getUserProfile error: $e');
      return null;
    }
  }

  Future<void> updateHomeLocation(String userId, String location) async {
    await Supabase.instance.client
        .from('user_data')
        .update({'home_location': location})
        .eq('id', userId);
  }
}