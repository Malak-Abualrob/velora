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
            backgroundColor: const Color(0xFFFAF7F8),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // =========================
                    // TOP BAR
                    // =========================
                    SizedBox(
                      height: 45,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => finish(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // =========================
                    // PAGES
                    // =========================
                    Expanded(
                      child: PageView.builder(
                        controller: controller.pageController,
                        itemCount: OnboardingModel.onboardingList.length,
                        onPageChanged: controller.onPageChanged,
                        itemBuilder: (context, index) {
                          final item = OnboardingModel.onboardingList[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image Container
                                Container(
                                  width: double.infinity,
                                  height: 300,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5EEF0),
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  child: Image.asset(
                                    item.image,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 60,
                                        color: AppColors.grey,
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 42),

                                // Title
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.dark,
                                    letterSpacing: -0.3,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Description
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // =========================
                    // PAGE INDICATORS
                    // =========================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isActive = controller.currentIndex == index;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : const Color(0xFFE5D9DD),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 28),

                    // =========================
                    // NEXT / GET STARTED
                    // =========================
                    BeautyButton(
                      text: controller.isLastPage ? 'Get Started' : 'Next',
                      onPressed: () async {
                        if (controller.isLastPage) {
                          await finish(context);
                        } else {
                          await controller.nextPage();
                        }
                      },
                    ),

                    const SizedBox(height: 10),
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
