import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/config/routes/routes.dart';
import '../bloc/splash_bloc.dart';
import '../bloc/splash_event.dart';
import '../bloc/splash_state.dart';
import '../widgets/splash_logo_widget.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Total animation duration
    );

    // Define animations
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start the animation
    _controller.forward();

    // Trigger authentication check
    context.read<SplashBloc>().add(CheckAuthenticationEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) async {
          if (state is SplashAuthenticated) {
            // Add a delay before navigating
            await Future.delayed(Platform.isIOS ? const Duration(seconds: 6) : const Duration(seconds: 8));
            Navigator.pushReplacementNamed(context, AppRouter.main);
          } else if (state is SplashUnauthenticated) {
            // Add a delay before navigating
            await Future.delayed(Platform.isIOS ? const Duration(seconds: 6) : const Duration(seconds: 8));
            Navigator.pushReplacementNamed(context, AppRouter.main);
          } else if (state is SplashError) {
            // Handle error (e.g., show a snackbar)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background color
            Container(
              color: const Color(0xFF3700B3),
            ),
            // Splash logo widget
            Center(
              child: SplashLogoWidget(
                controller: _controller,
                fadeAnimation: _fadeAnimation,
                scaleAnimation: _scaleAnimation,
                rotationAnimation: _rotationAnimation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}