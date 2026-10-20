import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, unauthenticated, authenticated, unauthorized }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.isSubmitting = false,
    this.email,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isSubmitting;
  final String? email;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      email: email,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, isSubmitting, email, errorMessage];
}