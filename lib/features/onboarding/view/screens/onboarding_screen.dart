import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/onboarding/controller/onboarding_controller.dart';
import 'package:my_havenly_application/features/onboarding/view/widgets/onboarding_page.dart';
import 'package:my_havenly_application/features/onboarding/view/widgets/onboarding_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return Scaffold(
      backgroundColor: const Color(0xff001733),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: const [
                  OnboardingPage(
                    image: Icons.search,
                    title: 'Find Your Dream Home',
                    description:
                        'Browse through thousands of properties and find the perfect place that matches your lifestyle and budget.',
                  ),
                  OnboardingPage(
                    image: Icons.verified_user,
                    title: 'Verified & Trusted',
                    description:
                        'All properties are verified and trusted. Get detailed information and connect with verified property owners.',
                  ),
                ],
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Obx(
                () => OnboardingIndicator(
                  currentIndex: controller.currentPage.value,
                  totalPages: 2,
                ),
              ),
            ),

            // Navigation Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff024DAA),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      controller.currentPage.value == 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

