import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/onboarding/controller/onboarding_controller.dart';
import 'package:my_havenly_application/features/onboarding/view/widgets/onboarding_page.dart';
import 'package:my_havenly_application/features/onboarding/view/widgets/onboarding_indicator.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    OnboardingController controller;
    if (Get.isRegistered<OnboardingController>()) {
      try {
        controller = Get.find<OnboardingController>();
      } catch (e) {
        controller = Get.put(OnboardingController());
      }
    } else {
      controller = Get.put(OnboardingController());
    }

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  child: Text(
                    'Skip'.tr,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [
                  OnboardingPage(
                    image: Icons.home_work_outlined,
                    title: 'Explore Amazing Properties'.tr,
                    description:
                        'Browse through thousands of verified properties. Find apartments, villas, and houses that match your preferences and budget.'.tr,
                  ),
                  OnboardingPage(
                    image: Icons.calendar_today_outlined,
                    title: 'Easy Reservations'.tr,
                    description:
                        'Book your favorite property with ease. Manage your reservations, track requests, and modify bookings all in one place.'.tr,
                  ),
                  OnboardingPage(
                    image: Icons.favorite_outline,
                    title: 'Save & Organize'.tr,
                    description:
                        'Save your favorite properties, receive notifications about updates, manage your profile, and keep everything organized.'.tr,
                  ),
                ],
              ),
            ),

            // Page Indicator
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Obx(
                () => OnboardingIndicator(
                  currentIndex: controller.currentPage.value,
                  totalPages: 3,
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      controller.currentPage.value == 2
                          ? 'Get Started'.tr
                          : 'Next'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
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
