import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greatly_user/features/auth/domain/repositories/auth_repository.dart';
import 'package:greatly_user/features/auth/domain/usecases/logout_usecase.dart';
import 'package:greatly_user/features/auth/domain/usecases/login_with_email_usecase.dart';
import 'package:greatly_user/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:greatly_user/features/auth/domain/usecases/login_with_apple_usecase.dart';
import 'package:greatly_user/features/auth/domain/usecases/register_with_google_usecase.dart';
import 'package:greatly_user/features/auth/domain/usecases/register_with_apple_usecase.dart';
import 'package:greatly_user/features/auth/domain/usecases/send_password_reset_email_usecase.dart';
import 'package:greatly_user/features/auth/domain/usecases/send_email_verification_usecase.dart';
import 'package:greatly_user/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:greatly_user/features/auth/data/datasources/remote/auth_firestore_data_source.dart';
import 'package:greatly_user/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:greatly_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:greatly_user/features/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:greatly_user/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:greatly_user/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:greatly_user/features/onboarding/domain/usecases/get_onboarding_items_usecase.dart';
import 'package:greatly_user/features/onboarding/domain/usecases/set_onboarding_completed_usecase.dart';
import 'package:greatly_user/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/usecases/auth_service.dart';
import '../../features/auth/domain/usecases/check_email_verfication_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/register_with_email_usecase.dart';
import '../../features/auth/presentation/bloc/splash_bloc.dart';
import 'service_locator.config.dart';

/// Global instance of GetIt for dependency injection
final GetIt getIt = GetIt.instance;

/// Main initialization function to be called at app startup
Future<void> initDependencies() async {
  // First call configureDependencies for injectable
  configureDependencies();
  
  // Then register repositories (which contains async code)
  await registerRepositories();
  
  // Finally register use cases and blocs
  registerUseCases();
  registerBlocs();
}

/// Initializes dependencies using Injectable
@InjectableInit()
void configureDependencies() => getIt.init();

/// Registers repositories and their dependencies
Future<void> registerRepositories() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Data Sources
  getIt.registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(FirebaseAuth.instance, GoogleSignIn()));
  getIt.registerFactory<AuthFirestoreDataSource>(
      () => AuthFirestoreDataSource(FirebaseFirestore.instance));

  // Register Repository
  getIt.registerFactory<AuthRepository>(() => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<AuthFirestoreDataSource>(),
      ));

  // Onboarding Feature
  getIt.registerFactory<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSource(getIt<SharedPreferences>()));
  getIt.registerFactory<OnboardingRepository>(
      () => OnboardingRepositoryImpl(getIt<OnboardingLocalDataSource>()));
}

/// Registers use cases for dependency injection
void registerUseCases() {
  getIt.registerFactory(() => LoginWithEmailUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegisterWithEmailUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LoginWithGoogleUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LoginWithAppleUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegisterWithGoogleUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => RegisterWithAppleUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => SendPasswordResetEmailUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => SendEmailVerificationUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => CheckEmailVerificationStatusUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetCurrentUserUseCase(getIt<AuthRepository>()));

  // Onboarding Use Cases
  getIt.registerFactory(() => GetOnboardingItemsUseCase(getIt<OnboardingRepository>()));
  getIt.registerFactory(() => SetOnboardingCompletedUseCase(getIt<OnboardingRepository>()));

  // Register AuthService usecases for dependency injection
  getIt.registerFactory(() => AuthService(
        loginWithEmailUseCase: getIt<LoginWithEmailUseCase>(),
        registerWithEmailUseCase: getIt<RegisterWithEmailUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
        loginWithGoogleUseCase: getIt<LoginWithGoogleUseCase>(),
        loginWithAppleUseCase: getIt<LoginWithAppleUseCase>(),
        registerWithGoogleUseCase: getIt<RegisterWithGoogleUseCase>(),
        registerWithAppleUseCase: getIt<RegisterWithAppleUseCase>(),
        sendPasswordResetEmailUseCase: getIt<SendPasswordResetEmailUseCase>(),
        sendEmailVerificationUseCase: getIt<SendEmailVerificationUseCase>(),
        checkEmailVerificationStatusUseCase: getIt<CheckEmailVerificationStatusUseCase>(),
        getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(), 
      ));
}

/// Registers Blocs for dependency injection
void registerBlocs() {
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
        authService: getIt<AuthService>(), // Use AuthService
      ));
      //splash bloc
  getIt.registerFactory(() => SplashBloc(getIt()));

  // Onboarding Bloc
  getIt.registerFactory(() => OnboardingBloc(
        getOnboardingItemsUseCase: getIt<GetOnboardingItemsUseCase>(),
        setOnboardingCompletedUseCase: getIt<SetOnboardingCompletedUseCase>(),
      ));
}