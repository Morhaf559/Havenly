// Controller: Main Navigation Controller using GetX - للتحكم في التنقل بين الصفحات الرئيسية
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../profile/views/profile_ui.dart';
import '../view/screens/home_screen.dart';

class MainNavigationController extends GetxController {
  // Reactive variable for selected bottom navigation index
  RxInt selectedBottomNav = 0.obs; // 0 = Home (default)

  @override
  void onInit() {
    super.onInit();
    // Ensure home is selected by default
    selectedBottomNav.value = 0;
  }

  // Navigation Methods
  void setSelectedBottomNav(int index) {
    selectedBottomNav.value = index;
  }

  // Bottom Navigation Bar Actions
  void onHomePressed() {
    debugPrint('Home button pressed');
    setSelectedBottomNav(0);
    // Navigate to home screen using GetX
    Get.offAll(() => const HomeScreen());
  }

  void onExplorePressed() {
    debugPrint('Explore button pressed');
    setSelectedBottomNav(1);
    // TODO: Navigate to explore screen when implemented
    // Get.offAll(() => const ExploreScreen());
  }

  void onFavoritePressed() {
    debugPrint('Favorite button pressed');
    setSelectedBottomNav(2);
    // TODO: Navigate to favorite screen when implemented
    // Get.offAll(() => const FavoriteScreen());
  }

  void onProfilePressed() {
    debugPrint('Profile button pressed');
    setSelectedBottomNav(3);
    // Navigate to profile screen using GetX
    Get.offAll(() => const ProfileScreen());
  }
}

