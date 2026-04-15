import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/main/controllers/main_navigation_controller.dart';
import 'package:my_havenly_application/features/owner/controllers/owner_dashboard_controller.dart';
import 'package:my_havenly_application/features/owner/controllers/owner_properties_controller.dart';
import 'package:my_havenly_application/features/profile/controllers/profile_controller.dart';

class DataRefreshService {
  static void refreshApartmentData() {
    try {
      if (Get.isRegistered<OwnerDashboardController>()) {
        try {
          final dashboardController = Get.find<OwnerDashboardController>();
          dashboardController.refresh();
        } catch (e) {
          debugPrint('DataRefreshService: Error refreshing dashboard: $e');
        }
      }
      if (Get.isRegistered<OwnerPropertiesController>()) {
        try {
          final propertiesController = Get.find<OwnerPropertiesController>();
          propertiesController.refresh();
        } catch (e) {
          debugPrint(
            'DataRefreshService: Error refreshing properties list: $e',
          );
        }
      }
    } catch (e) {
      debugPrint('DataRefreshService: Error refreshing apartment data: $e');
    }
  }

  static bool navigateToDashboard({bool animate = false}) {
    try {
      if (Get.currentRoute != '/main') {
        Get.offAllNamed('/main', arguments: {'targetTab': 'dashboard'});
        return true;
      }
      if (Get.isRegistered<MainNavigationController>()) {
        try {
          final navController = Get.find<MainNavigationController>();
          navController.navigateToTab('dashboard', animate: animate);
          return true;
        } catch (e) {
          debugPrint('DataRefreshService: Error navigating to dashboard: $e');
          return false;
        }
      } else {
        debugPrint(
          'DataRefreshService: MainNavigationController not registered',
        );
        return false;
      }
    } catch (e) {
      debugPrint('DataRefreshService: Unexpected error in navigation: $e');
      return false;
    }
  }

  static void navigateToDashboardAndRefresh({bool animate = false}) {
    final navigationSuccess = navigateToDashboard(animate: animate);
    Future.delayed(const Duration(milliseconds: 400), () {
      refreshApartmentData();
    });

    if (!navigationSuccess) {
      _navigateToMainScreen();
      Future.delayed(const Duration(milliseconds: 400), () {
        refreshApartmentData();
      });
    }
  }

  static void _navigateToMainScreen() {
    try {
      Get.offAllNamed('/main');
    } catch (e) {
      debugPrint('DataRefreshService: Error navigating to main screen: $e');
    }
  }

  static bool navigateToProfile({bool animate = false}) {
    try {
      if (Get.currentRoute != '/main') {
        Get.offAllNamed('/main', arguments: {'targetTab': 'profile'});
        return true;
      }
      if (Get.isRegistered<MainNavigationController>()) {
        try {
          final navController = Get.find<MainNavigationController>();
          navController.navigateToTab('profile', animate: animate);
          return true;
        } catch (e) {
          debugPrint('DataRefreshService: Error navigating to profile: $e');
          return false;
        }
      } else {
        debugPrint(
          'DataRefreshService: MainNavigationController not registered',
        );
        return false;
      }
    } catch (e) {
      debugPrint('DataRefreshService: Unexpected error in navigation: $e');
      return false;
    }
  }

  static void navigateToProfileAndRefresh({bool animate = false}) {
    final navigationSuccess = navigateToProfile(animate: animate);
    Future.delayed(const Duration(milliseconds: 400), () {
      // Refresh profile data if ProfileController is available
      try {
        if (Get.isRegistered<ProfileController>()) {
          final profileController = Get.find<ProfileController>();
          profileController.refreshProfile();
        }
      } catch (e) {
        debugPrint('DataRefreshService: Error refreshing profile: $e');
      }
    });

    if (!navigationSuccess) {
      _navigateToMainScreen();
      Future.delayed(const Duration(milliseconds: 400), () {
        try {
          if (Get.isRegistered<ProfileController>()) {
            final profileController = Get.find<ProfileController>();
            profileController.refreshProfile();
          }
        } catch (e) {
          debugPrint('DataRefreshService: Error refreshing profile: $e');
        }
      });
    }
  }
}
