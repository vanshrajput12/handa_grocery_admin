import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._service) : super(const AuthState()) {
    _sub = _service.authStateChanges.listen(_onUserChanged);
  }

  final AuthService _service;
  late final StreamSubscription<User?> _sub;

  Future<void> _onUserChanged(User? user) async {
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    try {
      final isAdmin = await _service.isAdmin(user);
      emit(AuthState(
        status: isAdmin ? AuthStatus.authenticated : AuthStatus.unauthorized,
        email: user.email,
      ));
    } catch (_) {
      emit(AuthState(
        status: AuthStatus.unauthorized,
        email: user.email,
        errorMessage:
        'Could not verify admin access. Check your connection and try again.',
      ));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      await _service.signIn(email, password);
      // Success: _onUserChanged emits the next state.
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: _messageFor(e.code),
      ));
    } catch (_) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> signOut() => _service.signOut();

  String _messageFor(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return 'Sign-in failed. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}