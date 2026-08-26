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
      role: selectedRole, // save role to firestore
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Image.asset('assets/images/logo.jpg', height: 100),

              const SizedBox(height: 20),

              const Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),

              const SizedBox(height: 30),

              CustomTextField(
                controller: nameController,
                hint: 'Name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 15),

              CustomTextField(
                controller: confirmPasswordController,
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.admin_panel_settings_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('👤 User')),
                    DropdownMenuItem(value: 'admin', child: Text('🛡️ Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
                ),
              ),

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

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
