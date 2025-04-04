import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greatly_user/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:greatly_user/features/auth/presentation/bloc/auth_event.dart';
import 'package:greatly_user/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/constants/auth_strings.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/mixins/form_validation_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'register_button.dart';
import 'social_login_buttons.dart';

/// A form widget for user registration.
class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> with FormValidationMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for form fields.
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    // Dispose controllers to free up resources.
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the register button press.
 void _onRegisterPressed(BuildContext context) {
  final email = _emailController.text.trim().toLowerCase();
  final username = _usernameController.text.trim();
  final phone = _phoneController.text.trim();
  final password = _passwordController.text.trim();

  if (_formKey.currentState?.validate() ?? false) {
    // Dispatch register event with user details using named arguments.
    context.read<AuthBloc>().add(
          RegisterWithEmail(
            email: email, // Named argument
            password: password, // Named argument
            username: username, // Named argument
            phone: phone, // Named argument
          ),
        );
  }
}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Title
                    const Text(
                      AuthStrings.signUp,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    // Subtitle
                    Text(
                      AuthStrings.createAccountSubtitle,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 15),
                    // Username Field
                    CustomTextField(
                      controller: _usernameController,
                      labelText: AuthStrings.usernameLabel,
                      validator: validateUsername,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    // Phone Number Field
                    CustomTextField(
                      controller: _phoneController,
                      labelText: AuthStrings.phoneLabel,
                      keyboardType: TextInputType.phone,
                      validator: validatePhoneNumber,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: AuthStrings.emailLabel,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      labelText: AuthStrings.passwordLabel,
                      obscureText: _obscurePassword,
                      validator: validatePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    // Register Button
                    RegisterButton(
                      onPressed: isLoading ? null : () => _onRegisterPressed(context),
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 20),
                    // Social Login Buttons
                    const SocialLoginButtons(),
                    const SizedBox(height: 25),
                    // Already Have an Account? Log In
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AuthStrings.alreadyHaveAccount,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pushReplacementNamed(context, Strings.loginRoute);
                                },
                          child: const Text(
                            'Log In',
                            style: TextStyle(fontWeight: FontWeight.bold),
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