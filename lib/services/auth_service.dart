import 'package:firebase_auth/firebase_auth.dart';

/// Thin wrapper around FirebaseAuth. The admin check reads the custom claim
/// `admin: true`, which can only be set by a trusted server-side process.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Forces a token refresh so a newly granted claim is picked up.
  Future<bool> isAdmin(User user) async {
    final result = await user.getIdTokenResult(true);
    return result.claims?['admin'] == true;
  }

  Future<void> signOut() => _auth.signOut();
}