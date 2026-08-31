import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/splash/app_start_screen.dart';
import 'core/constants/app_colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const VeloraApp());
}

class VeloraApp extends StatelessWidget {
  const VeloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VELORA',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          foregroundColor: AppColors.dark,
        ),
      ),
      home: const AppStartScreen(),
    );
  }
}
