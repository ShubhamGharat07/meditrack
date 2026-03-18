import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  );

  // Get current logged in user
  User? get currentUser => _auth.currentUser;

  // Auth state stream — detect login/logout
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─────────────────────────────────────
  // EMAIL & PASSWORD
  // ─────────────────────────────────────

  // Login with email and password
  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Register with email and password
  Future<UserCredential> registerWithEmail(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Forgot password — send reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─────────────────────────────────────
  // GOOGLE SIGN IN
  // ─────────────────────────────────────

  // Login with Google
  Future<UserCredential?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google Sign In failed: $e');
    }
  }

  // ─────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────

  // Logout
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
