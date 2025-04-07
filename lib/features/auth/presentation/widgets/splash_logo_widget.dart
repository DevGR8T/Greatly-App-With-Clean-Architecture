import 'package:flutter/material.dart';

class SplashLogoWidget extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final Animation<double> rotationAnimation;

  const SplashLogoWidget({
    super.key,
    required this.controller,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.rotationAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value, // Apply fade-in
          child: Transform.scale(
            scale: scaleAnimation.value, // Apply scaling
            child: Transform.rotate(
              angle: rotationAnimation.value * 3.14, // Apply rotation
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        'assets/images/splashlogo.gif',
        height: 150,
        color: Colors.white,
      ),
    );
  }
}