import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/core/components/costum_textfield_widget.dart';
import 'package:story_app/core/static/register.dart';
import 'package:story_app/core/validator/validator.dart';
import 'package:story_app/provider/auth/register_provider.dart';
import '../../../core/routes/router.dart';
import '../../core/components/loading_widget.dart';
import '../../data/model/requests/register_request_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 80.0,
                        height: 80.0,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Create Account',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Start your journey with us!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32.0),

                // Name
                CustomTextField(
                  controller: _fullNameController,
                  labelText: 'Full Name',
                  validator: validateName,
                  onChanged: (_) => _formKey.currentState?.validate(),
                  borderRadius: BorderRadius.circular(12.0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                const SizedBox(height: 20.0),

                // Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  validator: validateEmail,
                  onChanged: (_) => _formKey.currentState?.validate(),
                  keyboardType: TextInputType.emailAddress,
                  borderRadius: BorderRadius.circular(12.0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                const SizedBox(height: 20.0),

                // Password
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  validator: validatePassword,
                  obscureText: true,
                  onChanged: (_) => _formKey.currentState?.validate(),
                  borderRadius: BorderRadius.circular(12.0),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                const SizedBox(height: 32.0),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: Consumer<RegisterProvider>(
                    builder: (context, provider, _) {
                      if (provider.resultState is RegisterLoadingState) {
                        return const LoadingButton(text: 'Creating...');
                      }

                      if (provider.resultState is RegisterLoadedState) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final message =
                              (provider.resultState as RegisterLoadedState)
                                      .data
                                      .message ??
                                  'Register success!';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(message),
                            ),
                          );
                          provider.resetState();
                          context.go(Routes.login);
                        });
                      }

                      if (provider.resultState is RegisterErrorState) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final error =
                              (provider.resultState as RegisterErrorState)
                                  .error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: theme.colorScheme.error,
                              content: Text(error),
                            ),
                          );
                        });
                      }

                      return FilledButton(
                        onPressed: () {
                          final registerModel = RegisterRequestModel(
                            name: _fullNameController.text.trim(),
                            email: _emailController.text.trim(),
                            password: _passwordController.text.trim(),
                          );
                          if (_formKey.currentState?.validate() ?? false) {
                            provider.register(registerModel);
                          }
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Register'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24.0),

                // Already have account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => context.go(Routes.login),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1.0,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
