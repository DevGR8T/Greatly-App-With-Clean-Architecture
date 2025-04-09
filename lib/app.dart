import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/routes/routes.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/splash_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AuthBloc>()), // Global AuthBloc
        BlocProvider(create: (context) => getIt<SplashBloc>()), // SplashBloc for SplashPage
        BlocProvider(create: (context) => getIt<OnboardingBloc>()), // OnboardingBloc for OnboardingPage
      ],
      child: MaterialApp(
        theme: appTheme(),
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}