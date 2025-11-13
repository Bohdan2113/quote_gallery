import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_strings.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  /// Слухач змін стану авторизації
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateProfile({required String displayName}) async {
    try {
      await currentUser?.updateDisplayName(displayName);
      await currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    String message;

    switch (e.code) {
      case 'weak-password':
        message = AppStrings.errorWeakPassword;
        break;
      case 'email-already-in-use':
        message = AppStrings.errorEmailAlreadyInUse;
        break;
      case 'invalid-email':
        message = AppStrings.errorInvalidEmail;
        break;
      case 'user-not-found':
        message = AppStrings.errorUserNotFound;
        break;
      case 'wrong-password':
        message = AppStrings.errorWrongPassword;
        break;
      default:
        message = e.message ?? AppStrings.errorUnknown;
    }

    return FirebaseAuthException(code: e.code, message: message);
  }
}
