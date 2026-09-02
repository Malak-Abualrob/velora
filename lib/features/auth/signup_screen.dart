import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/beauty_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/profile_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  String selectedRole = 'user';

  Future<void> signup() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showMessage('Please fill all fields');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showMessage('Passwords do not match');
      return;
    }

    final controller = context.read<AuthController>();

    final success = await controller.signup(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    if (!success) {
      showMessage(controller.errorMessage ?? 'Signup failed');
      return;
    }

    final uid = controller.currentUser!.uid;

    await ProfileService().createProfile(
      uid: uid,
      name: nameController.text.trim(),
      role: selectedRole,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 25),

              // =========================
              // VELORA BRANDING
              // =========================
              Column(
                children: [
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
                    'Create your account',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Where elegance meets beauty.',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: AppColors.grey,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 38),

              // =========================
              // NAME
              // =========================
              CustomTextField(
                controller: nameController,
                hint: 'Name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 15),

              // =========================
              // EMAIL
              // =========================
              CustomTextField(
                controller: emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 15),

              // =========================
              // PASSWORD
              // =========================
              CustomTextField(
                controller: passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 15),

              // =========================
              // CONFIRM PASSWORD
              // =========================
              CustomTextField(
                controller: confirmPasswordController,
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 25),

              // =========================
              // ROLE
              // =========================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE8DEE2)),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.person_outline, color: AppColors.primary),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 25),

              // =========================
              // CREATE ACCOUNT
              // =========================
              Consumer<AuthController>(
                builder: (context, controller, _) {
                  return BeautyButton(
                    text: 'Create Account',
                    loading: controller.isLoading,
                    onPressed: signup,
                  );
                },
              ),

              const SizedBox(height: 15),

              // =========================
              // LOGIN
              // =========================
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
