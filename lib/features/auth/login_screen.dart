import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velora/auth_gate.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/beauty_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('🟢 LoginScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🟢 LoginScreen build called');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),

                      // Velora Logo
                      Text(
                        'VELORA',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 7,
                          color: AppColors.dark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Small elegant line
                      Container(
                        width: 42,
                        height: 1,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'Welcome to VELORA',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Your beauty space is waiting for you',
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppColors.grey,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  CustomTextField(
                    controller: emailController,
                    hint: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  Consumer<AuthController>(
                    builder: (context, controller, child) {
                      return BeautyButton(
                        text: 'Login',
                        loading: controller.isLoading,
                        onPressed: () async {
                          debugPrint('🔵 Login button pressed');
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();

                          if (email.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill all fields'),
                              ),
                            );
                            return;
                          }

                          final success = await controller.login(
                            email: email,
                            password: password,
                          );

                          if (!context.mounted) return;

                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  controller.errorMessage ?? 'Login failed',
                                ),
                              ),
                            );
                          } else {
                            debugPrint('✅ Login successful!');
                            // ✅ نروح لـ AuthGate مباشرة
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AuthGate(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
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
