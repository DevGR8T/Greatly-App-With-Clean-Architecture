import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/core/config/routes/routes.dart';
import 'package:greatly_user/core/utils/mixins/snackbar_mixin.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/mixins/form_validation_mixin.dart';
import '../../../../core/constants/strings.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/auth_event.dart';
import '../../presentation/bloc/auth_state.dart';
import '../../../../core/di/service_locator.dart'; // Dependency injection

/// A page for resetting the user's password.
class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage>
    with FormValidationMixin, SnackBarMixin {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose of the controller to avoid memory leaks
    _emailController.dispose();
    super.dispose();
  }

  /// Handles the reset password action.
  void _onResetPasswordPressed(BuildContext context) {
    final email = _emailController.text.trim();

    if (_formKey.currentState?.validate() ?? false) {
      // Dispatch the ForgotPassword event with the email as a named argument.
      context.read<AuthBloc>().add(
            ForgotPassword(email: email),
          );
    }
  }

  /// Handles state changes in the BlocConsumer listener.
  void _handleState(BuildContext context, AuthState state) {
    if (state is AuthPasswordResetEmailSent) {
      showSnackBar(context, Strings.passwordResetEmailSent, Colors.green);
      // Clear the email field and navigate back after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        _emailController.clear();
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
        Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route)=>false); // Navigate back to the login page
      });
    } else if (state is AuthError) {
      showSnackBar(context, state.message, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(), // Inject AuthBloc using GetIt
      child: GestureDetector(
        onTap: () {
          // Dismiss the keyboard when tapping outside of a TextField
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Platform.isIOS
                    ? Icons.arrow_back_ios
                    : Icons.arrow_back, // Platform-specific icon
                color: AppColors.primary,
              ),
              onPressed: () {
                
            Navigator.of(context).pop();
            FocusScope.of(context).unfocus(); // Dismiss the keyboard
              }
            ),
          ),
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) => _handleState(context, state),
            builder: (context, state) {
              final isLoading =
                  state is AuthLoading; // Derive loading state from AuthBloc

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          Strings.forgotPasswordText,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          Strings.enterEmailForReset,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email label
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.email,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Strings.emailLabel.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Email input field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              hintText: 'DevGreat@example.com',
                              hintStyle: TextStyle(color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              border: InputBorder.none,
                            ),
                            validator:
                                validateEmail, // Use the mixin's validation method
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Send email link button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null // Disable button while loading
                                : () {
                                    FocusScope.of(context)
                                        .unfocus(); // Dismiss the keyboard
                                    _onResetPasswordPressed(context);
                                    
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    Strings.send,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
