import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/utils/error_utils.dart';
import '../../../onboarding/domain/usecases/is_onboarding_completed_usecase.dart';
import '../../domain/usecases/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'dart:developer' as developer;

/// Bloc to handle authentication-related events and states.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService; // Aggregated service for use cases
  final IsOnboardingCompletedUseCase isOnboardingCompletedUseCase;
  AuthBloc({
    required this.authService,
    required this.isOnboardingCompletedUseCase,
  }) : super(AuthInitial()) {
    on<LoginWithEmail>(_onLoginWithEmail);
    on<RegisterWithEmail>(_onRegisterWithEmail);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<LoginWithApple>(_onLoginWithApple);
    on<RegisterWithGoogle>(_onRegisterWithGoogle);
    on<RegisterWithApple>(_onRegisterWithApple);
    on<SignOut>(_onSignOut);
    on<ForgotPassword>(_onForgotPassword);
    on<SendEmailVerification>(_onSendEmailVerification);
    on<CheckEmailVerificationStatus>(_onCheckEmailVerificationStatus);
  }

  /// Helper function for logging errors.
  void _logError(String methodName, dynamic error) {
    developer.log('Error in $methodName', error: error);
  }

  /// Handles login with email and password.
Future<void> _onLoginWithEmail(
    LoginWithEmail event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final result = await authService.loginWithEmail(event.email, event.password);
    await result.fold(
      (failure) async => emit(AuthError(ErrorUtils.cleanErrorMessage(failure.message))),
      (user) async {
        if (!user.emailVerified) {
          emit(AuthEmailNotVerified());
        } else {
          // Check if onboarding has been completed
          final hasCompletedOnboarding = isOnboardingCompletedUseCase();
          
          // Make sure to await this!
          final isFirstLoginAfterVerification = await authService.isFirstLoginAfterVerification(user.id);
          
          // If it's first login after verification, we want to show onboarding
          final needsOnboarding = isFirstLoginAfterVerification || !hasCompletedOnboarding;
          
          if (!emit.isDone) {  // Check if the emitter is still active
            emit(AuthLoggedIn(user: user, hasCompletedOnboarding: !needsOnboarding));
          }
        }
      },
    );
  } catch (e) {
    _logError('_onLoginWithEmail', e);
    if (!emit.isDone) {  // Check if the emitter is still active
      emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
    }
  }
}

  /// Handles registration with email and password.
  Future<void> _onRegisterWithEmail(
      RegisterWithEmail event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authService.registerWithEmail(
        event.email,
        event.password,
        username: event.username,
        phone: event.phone,
      );
      result.fold(
        (failure) => emit(AuthError(ErrorUtils.cleanErrorMessage(failure.message))),
        (user) => emit(AuthRegistered(user: user, hasCompletedOnboarding: false)), // New users always need onboarding
      );
    } catch (e) {
      _logError('_onRegisterWithEmail', e);
      emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
    }
  }

  /// Handles login with Google.
  Future<void> _onLoginWithGoogle(
      LoginWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authService.loginWithGoogle();
      result.fold(
        (failure) => emit(AuthError(ErrorUtils.cleanErrorMessage(failure.message))),
        (user) {   // Check if onboarding has been completed
        final hasCompletedOnboarding = isOnboardingCompletedUseCase();
          emit(AuthLoggedIn(user: user, hasCompletedOnboarding: hasCompletedOnboarding));}
      );
    } catch (e) {
      _logError('_onLoginWithGoogle', e);
      emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
    }
  }

  /// Handles login with Apple.
  Future<void> _onLoginWithApple(
      LoginWithApple event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authService.loginWithApple();
      result.fold(
        (failure) => emit(AuthError(ErrorUtils.cleanErrorMessage(failure.message))),
        (user) { 
             // Check if onboarding has been completed
        final hasCompletedOnboarding = isOnboardingCompletedUseCase();
          emit(AuthLoggedIn(user: user, hasCompletedOnboarding: hasCompletedOnboarding));},
      );
    } catch (e) {
      _logError('_onLoginWithApple', e);
      emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
    }
  }

  /// Handles registration with Google.
 Future<void> _onRegisterWithGoogle(RegisterWithGoogle event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final result = await authService.registerWithGoogle();
    result.fold(
      (failure) => emit(AuthError(ErrorUtils.cleanErrorMessage(failure.message))),
      (user) {
        final hasCompletedOnboarding = isOnboardingCompletedUseCase();
        
        if (user.isNewUser) {
          emit(AuthNewUser(user: user, hasCompletedOnboarding: false)); // New users always need onboarding
        } else {
          emit(AuthExistingUser(user: user, hasCompletedOnboarding: hasCompletedOnboarding));
        }
      },
    );
  } catch (e) {
    _logError('_onRegisterWithGoogle', e);
    emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
  }
}

  /// Handles registration with Apple.
Future<void> _onRegisterWithApple(RegisterWithApple event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  try {
    final result = await authService.registerWithApple();
    result.fold(
      (failure) => emit(AuthError(ErrorUtils.cleanErrorMessage(failure.message))),
      (user) {
        final hasCompletedOnboarding = isOnboardingCompletedUseCase();
        
        if (user.isNewUser) {
          emit(AuthNewUser(user: user, hasCompletedOnboarding: false)); // New users always need onboarding
        } else {
          emit(AuthExistingUser(user: user, hasCompletedOnboarding: hasCompletedOnboarding));
        }
      },
    );
  } catch (e) {
    _logError('_onRegisterWithApple', e);
    emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
  }
}

  /// Handles user sign-out.
  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authService.logout();  
      emit(AuthInitial());
    } catch (e) {
      _logError('_onSignOut', e);
      emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
    }
  }

  /// Handles sending a password reset email.
  Future<void> _onForgotPassword(
      ForgotPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authService.sendPasswordResetEmail(event.email);
      result.fold(
        (failure) => emit(AuthError(ErrorUtils.cleanErrorMessage(failure.message))),
        (_) => emit(AuthPasswordResetEmailSent()),
      );
    } catch (e) {
      _logError('_onForgotPassword', e);
      emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
    }
  }

  /// Handles sending email verification.
  Future<void> _onSendEmailVerification(
      SendEmailVerification event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authService.sendEmailVerification();
      emit(AuthEmailVerificationSent());
    } catch (e) {
      _logError('_onSendEmailVerification', e);
      emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
    }
  }

  /// Handles checking email verification status.
  Future<void> _onCheckEmailVerificationStatus(
      CheckEmailVerificationStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await authService.checkEmailVerificationStatus();
      result.fold(
        (failure) => emit(AuthError(ErrorUtils.cleanErrorMessage(failure.message))),
        (isVerified) {
          if (isVerified) {
            emit(AuthEmailVerified());
          } else {
            emit(AuthEmailNotVerified());
          }
        },
      );
    } catch (e) {
      _logError('_onCheckEmailVerificationStatus', e);
      emit(AuthError(ErrorUtils.cleanErrorMessage(e.toString())));
    }
  }
  
}