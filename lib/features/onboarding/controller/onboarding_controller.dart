import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/services/navigation_service.dart';
import 'package:my_havenly_application/features/auth/view/screens/login_screen.dart';
import 'package:my_havenly_application/features/auth/bindings/auth_binding.dart';

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
    if (currentPage.value < 2) {
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

  void completeOnboarding() async {
    try {
      await storage.write('has_seen_onboarding', true);
      
      final authStateController = Get.find<AuthStateController>();
      await authStateController.ensureAuthStateLoaded();
      
      if (authStateController.isLoggedIn) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        final navigationSuccess = NavigationService.offAll(
          () => LoginScreen(),
          binding: AuthBinding(),
          fallback: AppRoutes.login,
        );

        if (!navigationSuccess) {
          NavigationService.offAllNamed(AppRoutes.login);
        }
      }
    } catch (e) {
      debugPrint('OnboardingController: Error completing onboarding: $e');
      await storage.write('has_seen_onboarding', true);
      NavigationService.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
