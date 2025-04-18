import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greatly_user/core/config/env/env_config.dart';
import 'package:greatly_user/core/config/env/dev_config.dart';
import 'package:greatly_user/core/network/network_info_impl.dart';
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
import 'package:greatly_user/features/home/data/repositories/banner_repository_impl.dart';
import 'package:greatly_user/features/home/data/repositories/featured_products_repository_impl.dart';
import 'package:greatly_user/features/home/domain/repositories/banner_repository.dart';
import 'package:greatly_user/features/home/domain/usecases/get_banners.dart';
import 'package:greatly_user/features/home/domain/usecases/get_featured_products.dart';
import 'package:greatly_user/features/home/presentation/bloc/home_bloc.dart';
import 'package:greatly_user/features/main/presentation/bloc/navigation_bloc.dart';
import 'package:greatly_user/features/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:greatly_user/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:greatly_user/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:greatly_user/features/onboarding/domain/usecases/get_onboarding_items_usecase.dart';
import 'package:greatly_user/features/onboarding/domain/usecases/set_onboarding_completed_usecase.dart';
import 'package:greatly_user/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/usecases/auth_service.dart';
import '../../features/auth/domain/usecases/check_email_verfication_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/register_with_email_usecase.dart';
import '../../features/auth/presentation/bloc/splash_bloc.dart';
import '../../features/home/data/datasources/remote/banner_remote_data_source.dart';
import '../../features/home/data/datasources/remote/featured_remote_data_source.dart';
import '../../features/home/domain/repositories/featured_product_repository.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import 'service_locator.config.dart';

/// Global instance of GetIt for dependency injection
final GetIt getIt = GetIt.instance;

/// Initializes all dependencies for the application
Future<void> initDependencies() async {
  registerEnvConfig(); // Register environment configuration
  configureDependencies(); // Initialize Injectable dependencies
  await registerRepositories(); // Register repositories and their dependencies
  registerUseCases(); // Register use cases
  registerBlocs(); // Register BLoCs
}

/// Configures dependencies using Injectable
@InjectableInit()
void configureDependencies() => getIt.init();

/// Registers environment configuration
void registerEnvConfig() {
  getIt.registerLazySingleton<EnvConfig>(() => DevConfig()); // Use DevConfig for development
}

/// Registers repositories and their dependencies
Future<void> registerRepositories() async {
  // SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register DioClient
  getIt.registerLazySingleton<DioClient>(() => DioClient(Dio(), getIt()));

    // Register NetworkInfo
  getIt.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(InternetConnectionChecker()));


  // Data sources
  getIt.registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(FirebaseAuth.instance, GoogleSignIn()));
  getIt.registerFactory<AuthFirestoreDataSource>(
      () => AuthFirestoreDataSource(FirebaseFirestore.instance));
  getIt.registerLazySingleton<BannerRemoteDataSource>(
      () => BannerRemoteDataSourceImpl(getIt()));
  getIt.registerLazySingleton<FeaturedProductsRemoteDataSource>(
      () => FeaturedProductsRemoteDataSourceImpl(getIt()));

  // Repositories
  getIt.registerFactory<AuthRepository>(() => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<AuthFirestoreDataSource>(),
      ));
  getIt.registerLazySingleton<BannerRepository>(
      () => BannerRepositoryImpl(
            remoteDataSource: getIt(),
            networkInfo: getIt(),
          ));
  getIt.registerLazySingleton<FeaturedProductsRepository>(
      () => FeaturedProductsRepositoryImpl(
            remoteDataSource: getIt(),
            networkInfo: getIt(),
          ));

  // Register dependencies for the Onboarding feature
  getIt.registerFactory<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSource(getIt<SharedPreferences>()));
  getIt.registerFactory<OnboardingRepository>(
      () => OnboardingRepositoryImpl(getIt<OnboardingLocalDataSource>()));
}

/// Registers use cases for dependency injection
void registerUseCases() {
  // Authentication use cases
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

  // Onboarding use cases
  getIt.registerFactory(() => GetOnboardingItemsUseCase(getIt<OnboardingRepository>()));
  getIt.registerFactory(() => SetOnboardingCompletedUseCase(getIt<OnboardingRepository>()));

  // Home feature use cases
  getIt.registerLazySingleton(() => GetBanners(getIt()));
  getIt.registerLazySingleton(() => GetFeaturedProducts(getIt()));

  // AuthService
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

/// Registers BLoCs for dependency injection
void registerBlocs() {
  // Authentication BLoC
  getIt.registerFactory<AuthBloc>(() => AuthBloc(authService: getIt<AuthService>()));

  // Splash BLoC
  getIt.registerFactory(() => SplashBloc(getIt()));

  // Onboarding BLoC
  getIt.registerFactory(() => OnboardingBloc(
        getOnboardingItemsUseCase: getIt<GetOnboardingItemsUseCase>(),
        setOnboardingCompletedUseCase: getIt<SetOnboardingCompletedUseCase>(),
      ));

  // Home BLoC
  getIt.registerFactory(() => HomeBloc(
        getBanners: getIt<GetBanners>(),
        getFeaturedProducts: getIt<GetFeaturedProducts>(),
      ));

       // Navigation BLoC
  getIt.registerFactory(() => NavigationBloc());
}