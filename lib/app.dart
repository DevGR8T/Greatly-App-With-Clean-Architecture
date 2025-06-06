import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:greatly_user/features/products/presentation/bloc/category_bloc.dart';
import 'package:greatly_user/features/products/presentation/bloc/product_bloc.dart';
import 'package:greatly_user/features/reviews/presentation/bloc/review_bloc.dart';
import 'core/config/routes/routes.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/splash_bloc.dart';
import 'features/checkout/presentation/bloc/checkout_bloc.dart';
import 'features/main/presentation/bloc/navigation_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'features/home/presentation/bloc/home_bloc.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Global AuthBloc for authentication-related state management
        BlocProvider(create: (context) => getIt<AuthBloc>()),

        // SplashBloc for managing the splash screen state
        BlocProvider(create: (context) => getIt<SplashBloc>()),

        // OnboardingBloc for managing onboarding flow state
        BlocProvider(create: (context) => getIt<OnboardingBloc>()),

        // HomeBloc for managing home page state
        BlocProvider(create: (context) => getIt<HomeBloc>()),

        //ProductBloc(categoryBloc) for managing category-related state
        BlocProvider(create: (context) => getIt<CategoryBloc>()),

        //ProductBloc for managing product-related state
        BlocProvider(create: (context) => getIt<ProductBloc>()),

        //ReviewBloc for managing review-related state
        BlocProvider(create: (context) => getIt<ReviewBloc>()),
        
       //cartBloc for managing cart-related state
       BlocProvider(create: (context) => getIt<CartBloc>()),

       // CheckoutBloc for managing checkout-related state
        BlocProvider(create: (context) => getIt<CheckoutBloc>()),

           // NavigationBloc for managing bottom navigation state
        BlocProvider(create: (context) => getIt<NavigationBloc>()),

        BlocProvider(create: (context) => getIt<ReviewBloc>()),
      ],
      child: MaterialApp(
        theme: appTheme(), // Apply the app's theme
        initialRoute: AppRouter.login, // Set the initial route to the main screen
        onGenerateRoute: AppRouter.onGenerateRoute, // Handle route generation
      ),
    );
  }
}