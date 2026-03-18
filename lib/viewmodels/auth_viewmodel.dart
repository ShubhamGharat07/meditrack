import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../core/errors/failures.dart';

class AuthViewModel {
  final AuthRepository _authRepository = AuthRepository();

  // ─────────────────────────────────────
  // LOGIN WITH EMAIL
  // ─────────────────────────────────────

  Future<UserModel> loginWithEmail(String email, String password) async {
    // Validate fields
    if (email.isEmpty) throw AuthFailure('Email is required!');
    if (password.isEmpty) throw AuthFailure('Password is required!');
    if (password.length < 6) {
      throw AuthFailure('Password must be at least 6 characters!');
    }

    return await _authRepository.loginWithEmail(email, password);
  }

  // ─────────────────────────────────────
  // REGISTER WITH EMAIL
  // ─────────────────────────────────────

  Future<UserModel> registerWithEmail(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    // Validate fields
    if (name.isEmpty) throw AuthFailure('Name is required!');
    if (email.isEmpty) throw AuthFailure('Email is required!');
    if (password.isEmpty) throw AuthFailure('Password is required!');
    if (password.length < 6) {
      throw AuthFailure('Password must be at least 6 characters!');
    }
    if (password != confirmPassword) {
      throw AuthFailure('Passwords do not match!');
    }

    return await _authRepository.registerWithEmail(name, email, password);
  }

  // ─────────────────────────────────────
  // LOGIN WITH GOOGLE
  // ─────────────────────────────────────

  Future<UserModel> loginWithGoogle() async {
    return await _authRepository.loginWithGoogle();
  }

  // ─────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────

  Future<void> forgotPassword(String email) async {
    if (email.isEmpty) throw AuthFailure('Email is required!');
    await _authRepository.forgotPassword(email);
  }

  // ─────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────

  Future<void> logout() async {
    await _authRepository.logout();
  }

  // ─────────────────────────────────────
  // CHECK IF LOGGED IN
  // ─────────────────────────────────────

  Future<bool> isLoggedIn() async {
    return await _authRepository.isLoggedIn();
  }

  // ─────────────────────────────────────
  // CHECK IF FIRST TIME
  // ─────────────────────────────────────

  Future<bool> isFirstTime() async {
    return await _authRepository.isFirstTime();
  }

  // Set first time done
  Future<void> setFirstTimeDone() async {
    await _authRepository.setFirstTimeDone();
  }
}
