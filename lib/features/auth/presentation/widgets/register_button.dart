import 'package:flutter/material.dart';

/// A reusable button widget for the registration action.
class RegisterButton extends StatelessWidget {
  final VoidCallback? onPressed; // Function to execute when the button is pressed.
  final bool isLoading; // Indicates whether the button should show a loading spinner.

  /// Constructor for the RegisterButton.
  /// [onPressed] is the function to execute when the button is clicked.
  /// [isLoading] determines if a loading spinner should be displayed.
  const RegisterButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, // Attach the onPressed callback.
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16), // Add vertical padding.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Rounded corners for the button.
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white) // Show a loading spinner if isLoading is true.
          : const Text(
              'Register Now', // Display "Register Now" text if not loading.
              style: TextStyle(fontSize: 16),
            ),
    );
  }
}