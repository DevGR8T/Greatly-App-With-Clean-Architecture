import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/routes/routes.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/splash_bloc.dart';
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
        
           // NavigationBloc for managing bottom navigation state
        BlocProvider(create: (context) => getIt<NavigationBloc>()),
      ],
      child: MaterialApp(
        theme: appTheme(), // Apply the app's theme
        initialRoute: AppRouter.splash, // Set the initial route to the main screen
        onGenerateRoute: AppRouter.onGenerateRoute, // Handle route generation
      ),
    );
  }
}