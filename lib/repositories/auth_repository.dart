// import '../models/user_model.dart';
// import '../services/firebase/auth_service.dart';
// import '../services/firebase/firestore_service.dart';
// import '../services/local/shared_pref_service.dart';
// import '../core/errors/failures.dart';

// class AuthRepository {
//   final AuthService _authService = AuthService();
//   final FirestoreService _firestoreService = FirestoreService();
//   final SharedPrefService _sharedPrefService = SharedPrefService();

//   // ─────────────────────────────────────
//   // LOGIN WITH EMAIL
//   // ─────────────────────────────────────

//   Future<UserModel> loginWithEmail(String email, String password) async {
//     try {
//       // Login with Firebase Auth
//       final credential = await _authService.loginWithEmail(email, password);

//       // Get user from Firestore
//       final user = await _firestoreService.getUser(credential.user!.uid);

//       if (user == null) throw AuthFailure('User not found!');

//       // Save token to SharedPreferences
//       await _sharedPrefService.saveToken(credential.user!.uid);

//       // Save user info to SharedPreferences
//       await _sharedPrefService.saveUserInfo(user.name, user.email);

//       return user;
//     } on AuthFailure {
//       rethrow;
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // REGISTER WITH EMAIL
//   // ─────────────────────────────────────

//   Future<UserModel> registerWithEmail(
//     String name,
//     String email,
//     String password,
//   ) async {
//     try {
//       // Register with Firebase Auth
//       final credential = await _authService.registerWithEmail(email, password);

//       // Create user model
//       final user = UserModel(
//         uid: credential.user!.uid,
//         name: name,
//         email: email,
//         createdAt: DateTime.now(),
//       );

//       // Save user to Firestore
//       await _firestoreService.saveUser(user);

//       // Save token to SharedPreferences
//       await _sharedPrefService.saveToken(credential.user!.uid);

//       // Save user info to SharedPreferences
//       await _sharedPrefService.saveUserInfo(name, email);

//       return user;
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // LOGIN WITH GOOGLE
//   // ─────────────────────────────────────

//   Future<UserModel> loginWithGoogle() async {
//     try {
//       // Login with Google
//       final credential = await _authService.loginWithGoogle();
//       if (credential == null) throw AuthFailure('Google Sign In cancelled!');

//       // Check if user exists in Firestore
//       UserModel? user = await _firestoreService.getUser(credential.user!.uid);

//       // If new user — save to Firestore
//       if (user == null) {
//         user = UserModel(
//           uid: credential.user!.uid,
//           name: credential.user!.displayName ?? 'User',
//           email: credential.user!.email ?? '',
//           photoUrl: credential.user!.photoURL,
//           createdAt: DateTime.now(),
//         );
//         await _firestoreService.saveUser(user);
//       }

//       // Save token to SharedPreferences
//       await _sharedPrefService.saveToken(credential.user!.uid);

//       // Save user info to SharedPreferences
//       await _sharedPrefService.saveUserInfo(user.name, user.email);

//       return user;
//     } on AuthFailure {
//       rethrow;
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // FORGOT PASSWORD
//   // ─────────────────────────────────────

//   Future<void> forgotPassword(String email) async {
//     try {
//       await _authService.sendPasswordResetEmail(email);
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // LOGOUT
//   // ─────────────────────────────────────

//   Future<void> logout() async {
//     try {
//       await _authService.logout();
//       await _sharedPrefService.clearAll();
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // CHECK IF LOGGED IN
//   // ─────────────────────────────────────

//   Future<bool> isLoggedIn() async {
//     final token = await _sharedPrefService.getToken();
//     return token != null;
//   }

//   // ─────────────────────────────────────
//   // CHECK IF FIRST TIME
//   // ─────────────────────────────────────

//   Future<bool> isFirstTime() async {
//     return await _sharedPrefService.isFirstTime();
//   }

//   // Set first time done
//   Future<void> setFirstTimeDone() async {
//     await _sharedPrefService.setFirstTimeDone();
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import '../models/user_model.dart';
// import '../services/firebase/auth_service.dart';
// import '../services/firebase/firestore_service.dart';
// import '../services/local/shared_pref_service.dart';
// import '../core/errors/failures.dart';

// class AuthRepository {
//   final AuthService _authService = AuthService();
//   final FirestoreService _firestoreService = FirestoreService();
//   final SharedPrefService _sharedPrefService = SharedPrefService();

//   // ─────────────────────────────────────
//   // LOGIN WITH EMAIL
//   // ─────────────────────────────────────

//   Future<UserModel> loginWithEmail(String email, String password) async {
//     try {
//       final credential = await _authService.loginWithEmail(email, password);
//       final user = await _firestoreService.getUser(credential.user!.uid);
//       if (user == null) throw AuthFailure('User not found!');

//       // User info cache karo — optional, Firebase se milta hai
//       await _sharedPrefService.saveUserInfo(user.name, user.email);

//       return user;
//     } on AuthFailure {
//       rethrow;
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // REGISTER WITH EMAIL
//   // ─────────────────────────────────────

//   Future<UserModel> registerWithEmail(
//     String name,
//     String email,
//     String password,
//   ) async {
//     try {
//       final credential = await _authService.registerWithEmail(email, password);

//       final user = UserModel(
//         uid: credential.user!.uid,
//         name: name,
//         email: email,
//         createdAt: DateTime.now(),
//       );

//       // Firestore mein save karo
//       await _firestoreService.saveUser(user);

//       // User info cache karo
//       await _sharedPrefService.saveUserInfo(name, email);

//       return user;
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // LOGIN WITH GOOGLE
//   // ─────────────────────────────────────

//   Future<UserModel> loginWithGoogle() async {
//     try {
//       final credential = await _authService.loginWithGoogle();
//       if (credential == null) throw AuthFailure('Google Sign In cancelled!');

//       UserModel? user = await _firestoreService.getUser(credential.user!.uid);

//       if (user == null) {
//         user = UserModel(
//           uid: credential.user!.uid,
//           name: credential.user!.displayName ?? 'User',
//           email: credential.user!.email ?? '',
//           photoUrl: credential.user!.photoURL,
//           createdAt: DateTime.now(),
//         );
//         await _firestoreService.saveUser(user);
//       }

//       // User info cache karo
//       await _sharedPrefService.saveUserInfo(user.name, user.email);

//       return user;
//     } on AuthFailure {
//       rethrow;
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // FORGOT PASSWORD
//   // ─────────────────────────────────────

//   Future<void> forgotPassword(String email) async {
//     try {
//       await _authService.sendPasswordResetEmail(email);
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // LOGOUT
//   // ─────────────────────────────────────

//   Future<void> logout() async {
//     try {
//       await _authService.logout();
//       await _sharedPrefService.clearAll();
//     } catch (e) {
//       throw AuthFailure(e.toString());
//     }
//   }

//   // ─────────────────────────────────────
//   // CHECK IF LOGGED IN
//   // FIX: SharedPreferences token hataya — Firebase use karo
//   // Firebase automatically session persist karta hai app restart pe bhi
//   // Token save karne ki zaroorat nahi thi — yahi session loss ka bug tha
//   // ─────────────────────────────────────

//   Future<bool> isLoggedIn() async {
//     // Firebase currentUser — app restart ke baad bhi available
//     return FirebaseAuth.instance.currentUser != null;
//   }

//   // ─────────────────────────────────────
//   // FIRST TIME CHECK
//   // ─────────────────────────────────────

//   Future<bool> isFirstTime() async {
//     return await _sharedPrefService.isFirstTime();
//   }

//   Future<void> setFirstTimeDone() async {
//     await _sharedPrefService.setFirstTimeDone();
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_service.dart';
import '../services/local/shared_pref_service.dart';
import '../core/errors/failures.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // ─────────────────────────────────────
  // LOGIN WITH EMAIL
  // ─────────────────────────────────────

  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await _authService.loginWithEmail(email, password);
      final user = await _firestoreService.getUser(credential.user!.uid);
      if (user == null) throw AuthFailure('User not found!');

      // Token save karne ki zaroorat nahi —
      // Firebase automatically session persist karta hai
      // await _sharedPrefService.saveToken(credential.user!.uid);

      // Optional: User info cache
      await _sharedPrefService.saveUserInfo(user.name, user.email);

      return user;
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  // ─────────────────────────────────────
  // REGISTER WITH EMAIL
  // ─────────────────────────────────────

  Future<UserModel> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await _authService.registerWithEmail(email, password);

      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      // Firestore mein save karo
      await _firestoreService.saveUser(user);

      // Token save karne ki zaroorat nahi —
      // Firebase automatically session persist karta hai
      // await _sharedPrefService.saveToken(credential.user!.uid);

      // Optional: User info cache
      await _sharedPrefService.saveUserInfo(name, email);

      return user;
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  // ─────────────────────────────────────
  // LOGIN WITH GOOGLE
  // ─────────────────────────────────────

  Future<UserModel> loginWithGoogle() async {
    try {
      final credential = await _authService.loginWithGoogle();
      if (credential == null) throw AuthFailure('Google Sign In cancelled!');

      UserModel? user = await _firestoreService.getUser(credential.user!.uid);

      if (user == null) {
        user = UserModel(
          uid: credential.user!.uid,
          name: credential.user!.displayName ?? 'User',
          email: credential.user!.email ?? '',
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestoreService.saveUser(user);
      }

      // Token save karne ki zaroorat nahi —
      // Firebase automatically session persist karta hai
      // await _sharedPrefService.saveToken(credential.user!.uid);

      // Optional: User info cache
      await _sharedPrefService.saveUserInfo(user.name, user.email);

      return user;
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  // ─────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────

  Future<void> forgotPassword(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  // ─────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────

  Future<void> logout() async {
    try {
      await _authService.logout();
      await _sharedPrefService.clearAll();
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  // ─────────────────────────────────────
  // CHECK IF LOGGED IN
  // FIX: Firebase currentUser check — SharedPreferences token nahi
  // App restart ke baad bhi Firebase session available hota hai
  // ─────────────────────────────────────

  Future<bool> isLoggedIn() async {
    // Token check hataya — Firebase directly check karo
    // final token = await _sharedPrefService.getToken();
    // return token != null;

    return FirebaseAuth.instance.currentUser != null;
  }

  // ─────────────────────────────────────
  // FIRST TIME CHECK
  // ─────────────────────────────────────

  Future<bool> isFirstTime() async {
    return await _sharedPrefService.isFirstTime();
  }

  Future<void> setFirstTimeDone() async {
    await _sharedPrefService.setFirstTimeDone();
  }
}
