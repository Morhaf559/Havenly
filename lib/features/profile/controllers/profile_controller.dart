// Controller: Profile Controller using GetX - جميع منطق الأزرار والتفاعلات
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/property.dart';

class ProfileController extends GetxController {
  // Reactive variables using GetX
  RxInt selectedTab = 0.obs; // 0 = Properties, 1 = Archive
  RxInt selectedBottomNav = 3.obs; // 3 = Reserved (selected by default)

  // Profile Data
  final String profileName = 'Salloum';
  final String profileRole = 'Costumer';
  final String profileImageUrl = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200';
  final double nameFontSize = 30;
  final double roleFontSize = 20;
  final Color nameColor = const Color(0xFF000000);
  final Color roleColor = const Color(0xFF303030);

  // Properties list
  final List<Property> properties = [
    Property(
      name: 'Julia House',
      location: 'Damascus, Syria',
      imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=400',
    ),
    Property(
      name: 'Fulla House',
      location: 'Damascus, Syria',
      imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=400',
    ),
  ];

  // Navigation Methods
  void setSelectedTab(int index) {
    selectedTab.value = index;
  }

  void setSelectedBottomNav(int index) {
    selectedBottomNav.value = index;
  }

  // Button Actions
  void onChatPressed(Property property) {
    debugPrint('Chat pressed for: ${property.name}');

  }

  void onMoreOptionsPressed(Property property) {
    debugPrint('More options pressed for: ${property.name}');

  }

  void onEditPressed() {
    debugPrint('Edit pressed');

  }

  void onBackPressed() {
    debugPrint('Back button pressed');
    // Navigation logic using GetX
    Get.back();
    // Add any additional logic here (e.g., save data, show confirmation dialog, etc.)
  }

  // Bottom Navigation Bar Actions
  void onHomePressed() {
    debugPrint('Home button pressed');
    setSelectedBottomNav(0);
    // Add your home navigation logic here
    // Example: Navigate to home screen, reset state, etc.
  }

  void onExplorePressed() {
    debugPrint('Explore button pressed');
    setSelectedBottomNav(1);
    // Add your explore navigation logic here
    // Example: Navigate to explore screen, search, etc.
  }

  void onFavoritePressed() {
    debugPrint('Favorite button pressed');
    setSelectedBottomNav(2);
    // Add your favorite navigation logic here
    // Example: Navigate to favorites screen, show saved items, etc.
  }

  void onReservedPressed() {
    debugPrint('Reserved button pressed');
    setSelectedBottomNav(3);
    // Add your reserved navigation logic here
    // Example: Navigate to reserved screen, show reserved items, etc.
  }
}