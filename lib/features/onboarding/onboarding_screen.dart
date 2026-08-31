import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/onboarding_controller.dart';
import '../../models/onboarding_model.dart';
import '../../services/preferences_service.dart';
import '../auth/login_screen.dart';
import '../../widgets/beauty_button.dart';
import '../../core/constants/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> finish(BuildContext context) async {
    await PreferencesService.setOnboardingCompleted();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Consumer<OnboardingController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Skip button
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () => finish(context),
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: AppColors.grey, fontSize: 16),
                        ),
                      ),
                    ),

                    // Pages
                    Expanded(
                      child: PageView.builder(
                        controller: controller.pageController,
                        itemCount: OnboardingModel.onboardingList.length,
                        onPageChanged: controller.onPageChanged,
                        itemBuilder: (context, index) {
                          final item = OnboardingModel.onboardingList[index];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Image.asset(
                                item.image,
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                item.description,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: controller.currentIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: controller.currentIndex == index
                                ? AppColors.primary
                                : AppColors.lightPink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 30),

                    // Next / Get Started
                    BeautyButton(
                      text: controller.isLastPage ? 'Get Started 🌸' : 'Next',
                      onPressed: () async {
                        if (controller.isLastPage) {
                          await finish(context);
                        } else {
                          await controller.nextPage();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
