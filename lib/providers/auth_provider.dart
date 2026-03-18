import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/firebase/firestore_service.dart';
import '../core/errors/failures.dart';

class AuthProvider extends ChangeNotifier {
  final AuthViewModel _authViewModel = AuthViewModel();
  final FirestoreService _firestoreService = FirestoreService();

  // ─────────────────────────────────────
  // STATES
  // ─────────────────────────────────────

  bool _isLoading = false;
  bool _isLoggedIn = false;
  UserModel? _currentUser;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;

  // ─────────────────────────────────────
  // LOGIN WITH EMAIL
  // ─────────────────────────────────────

  Future<bool> loginWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      _clearError();

      _currentUser = await _authViewModel.loginWithEmail(email, password);
      _isLoggedIn = true;
      return true;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // REGISTER WITH EMAIL
  // ─────────────────────────────────────

  Future<bool> registerWithEmail(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      _currentUser = await _authViewModel.registerWithEmail(
        name,
        email,
        password,
        confirmPassword,
      );
      _isLoggedIn = true;
      return true;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // LOGIN WITH GOOGLE
  // ─────────────────────────────────────

  Future<bool> loginWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      _currentUser = await _authViewModel.loginWithGoogle();
      _isLoggedIn = true;
      return true;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────

  Future<bool> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _authViewModel.forgotPassword(email);
      return true;
    } on AuthFailure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong!';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────

  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authViewModel.logout();
      _isLoggedIn = false;
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'Logout failed!';
    } finally {
      _setLoading(false);
    }
  }

  // ─────────────────────────────────────
  // CHECK IF LOGGED IN
  //
  // FIX 1: Firebase currentUser check — SharedPreferences token nahi
  // FIX 2: Firestore se FULL user fetch karo — warna email/password
  //        users ka naam "User" dikhta tha app restart pe
  //
  // Reason: Firebase Auth ka currentUser.displayName email/password
  //         register pe null hota hai — humne sirf Firestore mein
  //         naam save kiya tha, Firebase Auth profile update nahi kiya
  //         Google login ka displayName milta hai — email wala nahi
  // ─────────────────────────────────────

  Future<bool> checkIfLoggedIn() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        _isLoggedIn = false;
        _currentUser = null;
        return false;
      }

      // Firebase session valid hai — ab Firestore se full user fetch karo
      // Isse naam, photoUrl sab properly aayega — "User" nahi dikhega
      final firestoreUser = await _firestoreService.getUser(firebaseUser.uid);

      if (firestoreUser != null) {
        // Firestore se complete data mila — use karo
        _currentUser = firestoreUser;
      } else {
        // Firestore mein nahi mila (edge case) — Firebase se fallback
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
      }

      _isLoggedIn = true;
      return true;
    } catch (e) {
      // Network error pe bhi logged in rakho — Firebase session valid hai
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _isLoggedIn = true;
        // Fallback — Firebase Auth data use karo
        _currentUser ??= UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
        );
        return true;
      }
      _isLoggedIn = false;
      return false;
    }
  }

  // ─────────────────────────────────────
  // UPDATE CURRENT USER — Profile update ke baad call karo
  // ─────────────────────────────────────

  void updateCurrentUser(UserModel updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // ─────────────────────────────────────
  // FIRST TIME CHECK
  // ─────────────────────────────────────

  Future<bool> isFirstTime() async {
    return await _authViewModel.isFirstTime();
  }

  Future<void> setFirstTimeDone() async {
    await _authViewModel.setFirstTimeDone();
  }

  // ─────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
  }
}
