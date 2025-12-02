import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepo {
  final GoTrueClient supabaseAuth;

  AuthRepo(this.supabaseAuth);

  Future<void> signInWithGoogle() async {
    const webClientId = '573519985252-c39qr1om3tjst8dtm15a3ie6ge078eil.apps.googleusercontent.com';
    final scopes = ['email', 'profile'];
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(serverClientId: webClientId);
    final googleUser = await googleSignIn.attemptLightweightAuthentication();
    if (googleUser == null) {
      throw AuthException('Failed to sign in with Google.');
    }

    /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
    /// while also granting permission to access user information.
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

   Stream<User?> authStateChanges() {
    return supabaseAuth.onAuthStateChange.map((data) => data.session?.user);  
  }
}
