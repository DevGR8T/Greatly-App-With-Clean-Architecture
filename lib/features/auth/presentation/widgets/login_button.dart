import 'package:flutter/material.dart';

/// Login button widget.
class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed; // Button action.
  final bool isLoading; // Loading state.

  /// Constructor.
  const LoginButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Execute action.
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners.
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white) // Show spinner.
          : const Text(
              'Login', // Show text.
              style: TextStyle(fontSize: 16),
            ),
    );
  }
}