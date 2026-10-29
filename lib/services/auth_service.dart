import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
<<<<<<< HEAD
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

=======
  AuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const String adminEmail = 'ug588424ug@gmail.com';

>>>>>>> origin/main
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

<<<<<<< HEAD
  /// True only if the account carries the `admin` custom claim, which is the
  /// same condition the Firestore rules check.
  Future<bool> isAdmin(User user) async {
    final result = await user.getIdTokenResult(true);
    return result.claims?['admin'] == true;
  }

  Future<void> signOut() => _auth.signOut();
}
=======
  Future<bool> isAdmin(User user) async {
    return user.email?.toLowerCase() == adminEmail;
  }

  Future<void> signOut() => _auth.signOut();
}
>>>>>>> origin/main
