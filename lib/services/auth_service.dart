import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static const String adminEmail = 'ug588424ug@gmail.com';

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<bool> isAdmin(User user) async {
    return user.email?.toLowerCase() == adminEmail;
  }

  Future<void> signOut() => _auth.signOut();
}