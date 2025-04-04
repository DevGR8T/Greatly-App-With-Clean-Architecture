import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/utils/mixins/snackbar_mixin.dart'; // Import SnackBarMixin
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Social login buttons for Google and Apple.
class SocialLoginButtons extends StatelessWidget with SnackBarMixin {
  const SocialLoginButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Login Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Trigger Google login.
              context.read<AuthBloc>().add(RegisterWithGoogle());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(
              Icons.g_mobiledata,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Apple Login Button
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              // Show Apple Sign-In unavailable message using SnackBarMixin.
              showSnackBar(
                context,
                'Apple Sign-In is not available.',
                Colors.red,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(
              Icons.apple,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}