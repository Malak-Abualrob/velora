import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'features/auth/login_screen.dart';
import 'features/admin/admin_main_screen.dart';
import 'features/user/user_main_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'services/profile_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print('🟢 StreamBuilder: ${snapshot.connectionState}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ إذا ما في مستخدم
        if (!snapshot.hasData) {
          print('❌ No user -> Going to Onboarding');
          // ✅ نستخدم WidgetsBinding عشان نضمن إن الـ Context جاهز
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            }
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ إذا في مستخدم
        print('✅ User found: ${snapshot.data!.uid}');

        // ✅ نستخدم WidgetsBinding عشان نضمن إن الـ Context جاهز
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _navigateToRoleScreen(context, snapshot.data!.uid);
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Future<void> _navigateToRoleScreen(BuildContext context, String uid) async {
    try {
      final role = await ProfileService().getUserRole(uid);
      print('✅ Role: $role');

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserMainScreen()),
        );
      }
    } catch (e) {
      print('❌ Error getting role: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }
}
