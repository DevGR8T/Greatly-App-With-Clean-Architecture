import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/constants/strings.dart';
import 'package:greatly_user/core/utils/mixins/snackbar_mixin.dart';
import '../../../../shared/dialogs/email_not_verified_dialog.dart';// Import the new dialog widget
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';


class LoginPage extends StatefulWidget with SnackBarMixin {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SnackBarMixin {
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
          dismissKeyboard(context); // Dismiss the keyboard on any state change
         _handleState(context, state);
          },
          child: LoginForm(), // Your login form widget
        ),
      ),
    );
  }

  /// Handles state changes from the AuthBloc.
  void _handleState(BuildContext context, AuthState state) {
    dismissKeyboard(context); // Dismiss the keyboard

    if (state is AuthNewUser) {
      _showSnackBar(context, Strings.welcomeAccountCreated, Colors.green);
      _navigateToHome(context);
    } else if (state is AuthExistingUser || state is AuthLoggedIn) {
      _showSnackBar(context, Strings.loggedIn, Colors.green);
      _navigateToHome(context);
    } else if (state is AuthEmailNotVerified) {
      _showEmailNotVerifiedDialog(context);
    } else if (state is AuthEmailVerificationSent) {
      _showSnackBar(
        context,
        Strings.verificationEmailSent,
        Colors.green,
      );
    } else if (state is AuthError) {
      _showSnackBar(context, state.message, Colors.red);
    }
  }

  /// Shows a SnackBar.
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    showSnackBar(context, message, color);
  }

  /// Navigates to the home screen.
  void _navigateToHome(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, Strings.homeRoute);
    });
  }

  /// Shows a dialog for unverified email.
  void _showEmailNotVerifiedDialog(BuildContext context) {
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      showDialog(
        context: context,
        builder: (context) => EmailNotVerifiedDialog(
          onResend: () {
            context.read<AuthBloc>().add(SendEmailVerification());
            Navigator.pop(context);
            dismissKeyboard(context); // Dismiss the keyboard
          },
        ),
      );
    }
  }
}