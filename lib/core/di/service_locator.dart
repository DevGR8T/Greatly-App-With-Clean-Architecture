import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greatly_user/core/config/env/env_config.dart';
import 'package:greatly_user/core/config/env/dev_config.dart';
import 'package:greatly_user/core/network/interceptors/auth_interceptor.dart';
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
import 'package:greatly_user/features/cart/data/datasources/local/cart_local_data_source.dart';
import 'package:greatly_user/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:greatly_user/features/cart/domain/usecases/add_to_cart_usecase.dart';
import 'package:greatly_user/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:greatly_user/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:greatly_user/features/cart/domain/usecases/remove_from_cart_usecase.dart';
import 'package:greatly_user/features/cart/domain/usecases/syncofflineaction_usecase.dart';
import 'package:greatly_user/features/cart/domain/usecases/update_cart_usecase.dart';
import 'package:greatly_user/features/cart/presentation/bloc/cart_bloc.dart';
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
import 'package:greatly_user/features/products/data/datasources/remote/category_remote_data_source.dart';
import 'package:greatly_user/features/products/data/repository/product_repository_impl.dart';
import 'package:greatly_user/features/products/data/repository/category_repository_implentation.dart';
import 'package:greatly_user/features/products/domain/repository/category_repository.dart';
import 'package:greatly_user/features/products/domain/repository/product_repository.dart';
import 'package:greatly_user/features/products/domain/usecases/get_categories_usecase.dart';
import 'package:greatly_user/features/products/domain/usecases/get_product_by_id_usecase.dart';
import 'package:greatly_user/features/products/domain/usecases/get_products_usecase.dart';
import 'package:greatly_user/features/products/presentation/bloc/category_bloc.dart';
import 'package:greatly_user/features/products/presentation/bloc/product_bloc.dart';
import 'package:greatly_user/features/reviews/data/datasources/remote/review_remote_data_source.dart';
import 'package:greatly_user/features/reviews/domain/usecases/get_product_average_rating_usecase.dart';
import 'package:greatly_user/features/reviews/domain/usecases/get_product_reviews_usecase.dart';
import 'package:greatly_user/features/reviews/domain/usecases/has_user_review_product_usecase.dart';
import 'package:greatly_user/features/reviews/domain/usecases/submit_review_usecase.dart';
import 'package:greatly_user/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/usecases/auth_service.dart';
import '../../features/auth/domain/usecases/check_email_verfication_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/register_with_email_usecase.dart';
import '../../features/auth/presentation/bloc/splash_bloc.dart';
import '../../features/cart/data/datasources/remote/cart_remote_data_source.dart';
import '../../features/cart/domain/repository/cart_repository.dart';
import '../../features/checkout/data/datasources/remote/checkout_remote_datasource.dart';
import '../../features/checkout/data/repository/check_out_repository_impl.dart';
import '../../features/checkout/domain/repository/check_out_repository.dart';
import '../../features/checkout/domain/usecases/add_payment_method.dart';
import '../../features/checkout/domain/usecases/cancel_order.dart';
import '../../features/checkout/domain/usecases/confirm_payment.dart';
import '../../features/checkout/domain/usecases/create_order.dart';
import '../../features/checkout/domain/usecases/create_stripe_portal_session.dart';
import '../../features/checkout/domain/usecases/delete_address.dart';
import '../../features/checkout/domain/usecases/delete_payment_method.dart';
import '../../features/checkout/domain/usecases/get_order_by_id.dart';
import '../../features/checkout/domain/usecases/get_saved_addresses.dart';
import '../../features/checkout/domain/usecases/get_saved_payment_methods.dart';
import '../../features/checkout/domain/usecases/get_user_orders.dart';
import '../../features/checkout/domain/usecases/initialize_payment.dart';
import '../../features/checkout/domain/usecases/save_address.dart';
import '../../features/checkout/presentation/bloc/checkout_bloc.dart';
import '../../features/home/data/datasources/remote/banner_remote_data_source.dart';
import '../../features/home/data/datasources/remote/featured_remote_data_source.dart';
import '../../features/home/domain/repositories/featured_product_repository.dart';
import '../../features/onboarding/domain/usecases/is_onboarding_completed_usecase.dart';
import '../../features/products/data/datasources/remote/product_remote_data_source.dart';
import '../../features/profile/data/datasources/local/profile_local_data_source.dart';
import '../../features/profile/data/datasources/remote/profile_remote_datasources.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repositories.dart';
import '../../features/profile/domain/usecases/delete_profile_picture_usecase.dart';
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/logout_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_profile_picture_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/reviews/data/repositories/review_repository_impl.dart';
import '../../features/reviews/domain/repositories/review_repository.dart';
import '../config/env/prod_config.dart';
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
  getIt.registerLazySingleton<EnvConfig>(
      () => ProdConfig()); // Changed from DevConfig() to ProdConfig() for development
}

// Register DioClient with AuthInterceptor
Dio provideDio(EnvConfig envConfig) {
  final dio = Dio();
  dio.interceptors.add(AuthInterceptor());
  return dio;
}

DioClient provideDioClient(Dio dio, EnvConfig envConfig) {
  return DioClient(dio, envConfig);
}

/// Registers repositories and their dependencies
Future<void> registerRepositories() async {
  // SharedPreferences instance
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

//Register Firebase instances
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

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

  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(
      getIt(),
    ),
  );

  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      getIt<DioClient>(),
      getIt<ReviewRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(
      getIt(),
    ),
  );

  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(dioClient: getIt()),
  );

  getIt.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(
      sharedPreferences: getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      dioClient: getIt<DioClient>(),
      firebaseAuth: getIt<FirebaseAuth>(),
      envConfig: getIt<EnvConfig>(),
    ),
  );

  // Repositories(DATA)
  getIt.registerFactory<AuthRepository>(() => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<AuthFirestoreDataSource>(),
      ));

  getIt.registerLazySingleton<BannerRepository>(() => BannerRepositoryImpl(
        remoteDataSource: getIt(),
        networkInfo: getIt(),
      ));

  getIt.registerLazySingleton<FeaturedProductsRepository>(
      () => FeaturedProductsRepositoryImpl(
            remoteDataSource: getIt(),
            networkInfo: getIt(),
          ));

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(
      remoteDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Register CartLocalDataSource
  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(sharedPreferences: getIt()),
  );

// Register CheckoutRemoteDataSource and CheckoutRepository
  getIt.registerLazySingleton<CheckoutRemoteDataSource>(
    () => CheckoutRemoteDataSourceImpl(
      dioClient: getIt<DioClient>(),
      firebaseAuth: FirebaseAuth.instance,
    ),
  );

  getIt.registerLazySingleton<CheckoutRepository>(
    () => CheckoutRepositoryImpl(
      remoteDataSource: getIt<CheckoutRemoteDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: getIt<ProfileRemoteDataSource>(),
      localDataSource: getIt<ProfileLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(), // if you have NetworkInfo
    ),
  );

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
  getIt
      .registerFactory(() => RegisterWithEmailUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LogoutUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LoginWithGoogleUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => LoginWithAppleUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(
      () => RegisterWithGoogleUseCase(getIt<AuthRepository>()));
  getIt
      .registerFactory(() => RegisterWithAppleUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(
      () => SendPasswordResetEmailUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(
      () => SendEmailVerificationUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(
      () => CheckEmailVerificationStatusUseCase(getIt<AuthRepository>()));
  getIt.registerFactory(() => GetCurrentUserUseCase(getIt<AuthRepository>()));

  // onboarding use cases
  getIt.registerFactory(
      () => IsOnboardingCompletedUseCase(getIt<OnboardingRepository>()));

  // Onboarding use cases
  getIt.registerFactory(
      () => GetOnboardingItemsUseCase(getIt<OnboardingRepository>()));
  getIt.registerFactory(
      () => SetOnboardingCompletedUseCase(getIt<OnboardingRepository>()));

  // Home feature use cases
  getIt.registerLazySingleton(() => GetBanners(getIt()));
  getIt.registerLazySingleton(() => GetFeaturedProducts(getIt()));

  // Category use case
  getIt.registerLazySingleton(() => GetCategoriesUseCase(getIt()));

// Product use cases
  getIt.registerLazySingleton(() => GetProductsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductByIdUseCase(getIt()));

  // Review use cases
  getIt.registerLazySingleton(() => GetProductReviewsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetProductAverageRatingUseCase(getIt()));
  getIt.registerLazySingleton(() => SubmitReviewUseCase(getIt()));
  getIt.registerLazySingleton(() => HasUserReviewedProductUseCase(getIt()));

  // Cart UseCases
  getIt.registerLazySingleton(() => AddToCartUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => GetCartUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => UpdateCartItemUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => RemoveFromCartUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => ClearCartUseCase(repository: getIt()));
  getIt.registerLazySingleton(() => SyncOfflineCartActionsUseCase(getIt()));

  //checkout use cases
  getIt.registerLazySingleton(() => SaveAddress(getIt()));
  getIt.registerLazySingleton(() => GetSavedAddresses(getIt()));
  getIt.registerLazySingleton(() => DeleteAddress(getIt()));
  getIt.registerLazySingleton(() => GetSavedPaymentMethods(getIt()));
  getIt.registerLazySingleton(() => CreateOrder(getIt()));
  getIt.registerLazySingleton(() => InitializePayment(getIt()));
  getIt.registerLazySingleton(() => ConfirmPayment(getIt()));
  getIt.registerLazySingleton(() => CancelOrder(getIt()));
  getIt.registerLazySingleton(() => GetOrderById(getIt()));
  getIt.registerLazySingleton(() => GetUserOrders(getIt()));
  getIt.registerLazySingleton(() => AddPaymentMethod(getIt()));
  getIt.registerLazySingleton(() => DeletePaymentMethod(getIt()));

  getIt.registerLazySingleton<GetProfileUsecase>(
    () => GetProfileUsecase(getIt<ProfileRepository>()),
  );

  getIt.registerLazySingleton<UpdateProfileUsecase>(
    () => UpdateProfileUsecase(getIt<ProfileRepository>()),
  );

  getIt.registerLazySingleton<UploadProfilePictureUsecase>(
    () => UploadProfilePictureUsecase(getIt<ProfileRepository>()),
  );

  getIt.registerLazySingleton<DeleteProfilePictureUsecase>(
    () => DeleteProfilePictureUsecase(getIt<ProfileRepository>()),
  );

  getIt.registerLazySingleton<LogoutUsecase>(
    () => LogoutUsecase(getIt<ProfileRepository>()),
  );

  // Stripe use case
  getIt.registerLazySingleton(() => CreateStripePortalSession(getIt()));

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
        checkEmailVerificationStatusUseCase:
            getIt<CheckEmailVerificationStatusUseCase>(),
        getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      ));
}

/// Registers BLoCs for dependency injection
void registerBlocs() {
  // Authentication BLoC
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
      authService: getIt<AuthService>(),
      isOnboardingCompletedUseCase: getIt<IsOnboardingCompletedUseCase>()));

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

  // Category BLoC
  getIt.registerFactory(() => CategoryBloc(getCategoriesUseCase: getIt()));

  //  product BLoC
  getIt.registerFactory(() => ProductBloc(
        getProductsUseCase: getIt(),
        getProductByIdUseCase: getIt(),
      ));

  // Review BLoC
  getIt.registerFactory(() => ReviewBloc(
        getProductReviews: getIt(),
        getProductAverageRating: getIt(),
        hasUserReviewedProduct: getIt(),
        submitReview: getIt(),
      ));

  //Cart BLoC
  getIt.registerFactory(() => CartBloc(
        getCartUseCase: getIt(),
        addToCartUseCase: getIt(),
        removeFromCartUseCase: getIt(),
        updateCartItemUseCase: getIt(),
        clearCartUseCase: getIt(),
        syncOfflineCartActionsUseCase: getIt(),
      ));

  // Checkout BLoC
  getIt.registerFactory(() => CheckoutBloc(
        saveAddress: getIt(),
        getSavedAddresses: getIt(),
        deleteAddress: getIt(),
        getSavedPaymentMethods: getIt(),
        createOrder: getIt(),
        initializePayment: getIt(),
        confirmPayment: getIt(),
        cancelOrder: getIt(),
        getOrderById: getIt(),
        getUserOrders: getIt(),
        addPaymentMethod: getIt(),
        deletePaymentMethod: getIt(),
        createStripePortalSession: getIt(),
      ));

  getIt.registerFactory(() => ProfileBloc(
        getProfileUsecase: getIt(),
        updateProfileUsecase: getIt(),
        uploadProfilePictureUsecase: getIt(),
        deleteProfilePictureUsecase: getIt(),
        logoutUsecase: getIt(),
      ));

  // Navigation BLoC
  getIt.registerFactory(() => NavigationBloc());
}
