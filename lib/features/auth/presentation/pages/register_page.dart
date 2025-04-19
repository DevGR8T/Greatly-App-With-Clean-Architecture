import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/constants/strings.dart';
import 'package:greatly_user/core/utils/mixins/snackbar_mixin.dart'; // Import SnackBarMixin
import '../../../../shared/dialogs/email_verification_dialog.dart'; // Import reusable dialog
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/register_form.dart';

class RegisterPage extends StatelessWidget with SnackBarMixin {
  const RegisterPage({super.key});

  /// Helper method to dismiss the keyboard.
  void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapping outside of a TextField
        dismissKeyboard(context);
      },
      child: Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            dismissKeyboard(
                context); // Dismiss the keyboard on any state change
            if (state is AuthRegistered) {
              // Show success message
              showSnackBar(
                context,
                Strings.welcomeAccountCreated,
                Colors.green,
              );

              //if email verification is required
              if (!state.user.emailVerified) {
                // Trigger email verification
                context.read<AuthBloc>().add(SendEmailVerification());
                // Show email verification dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return EmailVerificationDialog(
                      email: state.user.email,
                      onOk: () {
                        Navigator.of(context).pop(); // Close the dialog
                        dismissKeyboard(context); // Dismiss the keyboard
                        Navigator.of(context).pushReplacementNamed(
                            '/login'); // Redirect to Login Page
                      },
                      onResend: () {
                        final navigator =
                            Navigator.of(context); // Capture before pop()

                        navigator.pop(); // Close the dialog first
                        dismissKeyboard(context);

                        // Show snackbar
                        showSnackBar(
                          context,
                          Strings.emailVerificationResent,
                          Colors.blue,
                        );
                        Future.delayed(Duration(seconds: 1), () {
                          // Trigger the resend event
                          context.read<AuthBloc>().add(SendEmailVerification());
                        });

                        // Delay navigation
                        Future.delayed(const Duration(seconds: 5), () {
                          navigator.pushReplacementNamed(
                              '/login'); // Use the stored navigator
                        });
                      },
                    );
                  },
                );
              } else {
                // If email verification is not required, go to appropriate page
                Navigator.of(context).pushReplacementNamed(
                    state.hasCompletedOnboarding
                        ? Strings.mainRoute
                        : Strings.onboardingRoute);
              }
            } else if (state is AuthError) {
              // Clear any existing SnackBars
              ScaffoldMessenger.of(context).clearSnackBars();
              // Show error message
              showSnackBar(
                context,
                state.message,
                Colors.red,
              );
            }
          },
          child: const RegisterForm(),
        ),
      ),
    );
  }
}
