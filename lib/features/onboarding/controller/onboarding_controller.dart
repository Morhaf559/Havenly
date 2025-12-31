import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/features/auth/view/screens/login_screen.dart';
import 'package:my_havenly_application/features/auth/Binding/auth_binding.dart';
import 'package:my_havenly_application/features/home/view/screens/home_screen.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final currentPage = 0.obs;
  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void completeOnboarding() {
    // Temporarily disabled for development/testing - allows onboarding to show every app launch
    // TODO: Uncomment the line below when ready for production to enable one-time onboarding
    storage.write('has_seen_onboarding', true);
    String? token = storage.read('token');
    if (token != null && token.isNotEmpty) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => LoginScreen(), binding: AuthBinding());
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
