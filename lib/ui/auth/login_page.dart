import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:story_app/core/components/loading_widget.dart';
import 'package:story_app/data/preferences/token.dart';
import 'package:story_app/provider/auth/login_provider.dart';
import '../../../core/routes/router.dart';
import '../../../core/static/login.dart';
import '../../core/components/costum_textfield_widget.dart';
import '../../core/validator/validator.dart';
import '../../data/model/requests/login_request_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    final isLoggedIn = await TokenPreference().isUserLoggedIn();
    if (isLoggedIn) {
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 80.0,
                    height: 80.0,
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(
                    height: 40.0,
                  ),
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                    validator: validatePassword,
                    onChanged: (value) => _formKey.currentState?.validate(),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Consumer<LoginProvider>(
                      builder: (context, provider, child) {
                        if (provider.resultState is LoginLoadingState) {
                          return const LoadingButton(
                            text: 'Loading..',
                          );
                        }
                        if (provider.resultState is LoginLoadedState) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            context.go(Routes.home);
                          });
                        }
                        if (provider.resultState is LoginErrorState) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  content: Text(
                                      (provider.resultState as LoginErrorState)
                                          .error),
                                ),
                              );
                            },
                          );
                        }

                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            final loginRequestModel = LoginRequestModel(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );

                            if (_formKey.currentState?.validate() ?? false) {
                              provider.login(loginRequestModel);
                            }
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Don\'t have an account?'),
                      GestureDetector(
                        onTap: () {
                          context.push(Routes.register);
                        },
                        child: Text(
                          ' Register',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Divider(
                    thickness: 1.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
