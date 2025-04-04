import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/routes/routes.dart';
import '../../../../core/utils/mixins/form_validation_mixin.dart';
import '../../../../core/constants/strings.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'social_login_buttons.dart';
import 'login_button.dart';

/// A form widget for user login.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with FormValidationMixin {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Key to validate the form.
  final TextEditingController _emailController =
      TextEditingController(); // Controller for email input.
  final TextEditingController _passwordController =
      TextEditingController(); // Controller for password input.
  bool _isPasswordVisible = false; // Toggles password visibility.

  

  @override
  void dispose() {
    // Dispose controllers to free up resources.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the login button press.
  void _onLoginPressed(BuildContext context) {
  if (_formKey.currentState?.validate() ?? false) {
    // Dispatch login event with email and password using named arguments.
    context.read<AuthBloc>().add(
          LoginWithEmail(
            email: _emailController.text.trim(), // Named argument
            password: _passwordController.text.trim(), // Named argument
          ),
        );
  }
}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0), // Add padding around the form.
            child: SingleChildScrollView(
              child: Form(
                key: _formKey, // Attach the form key.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Title
                    const Text(
                      Strings.welcomeBack,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Subtitle
                    Text(
                      Strings.signInToAccount,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: Strings.emailLabel,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail, // Validate email input.
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: Strings.passwordLabel,
                      obscureText:
                          !_isPasswordVisible, // Toggle password visibility.
                      validator: validatePassword, // Validate password input.
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      textInputAction: TextInputAction.done,
                    ),

                    //forgot password button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to the Password Reset Page
                          Navigator.pushNamed(context, AppRouter.passwordReset);
                          
                        },
                        child: const Text(Strings.forgotPassword),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Login Button
                    LoginButton(
                      onPressed: state is AuthLoading
                          ? null // Disable button if loading.
                          : () => _onLoginPressed(context),
                      isLoading: state
                          is AuthLoading, // Show loading spinner if loading.
                    ),
                    const SizedBox(height: 20),
                    // Divider with "Or Continue With"
                    Row(
                      children: [
                        const Expanded(child: Divider()), // Left divider.
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            Strings.orContinueWith,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const Expanded(child: Divider()), // Right divider.
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Social Login Buttons
                    const SocialLoginButtons(),
                    const SizedBox(height: 40),
                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Strings.notAMember,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to the sign-up screen.
                            Navigator.pushNamed(context, Strings.signupRoute);
                          },
                          child: const Text(
                            Strings.joinNow,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
