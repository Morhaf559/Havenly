import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ==================== Primary Colors ====================
  /// Primary navy blue color - Main brand color
  static const Color primaryNavy = Color(0xff001733);

  /// Primary blue color
  static const Color primaryBlue = Color(0xff1C4D8D);

  /// Accent blue color
  static const Color accentBlue = Color(0xFF4988C4);

  static const Color lightBlue = Color(0xFFBDE8F5);

  // ==================== Dark Mode Colors ====================
  /// new colors for dark mode
  static const Color darkPrimaryColor = Color(0xff525252);

  /// Primary blue color
  static const Color darkSecondaryColor = Color(0xff414141);

  /// Accent blue color
  static const Color darkBlack = Color(0xFF313131);

  static const Color lightBlack = Color(0xFFEEEEEE);

  // ==================== Background Colors ====================
  /// Light background color
  static const Color backgroundLight = Color(0xFFF5F5F5);

  /// Dark background color
  static const Color backgroundDark = darkBlack;

  /// Card background light
  static const Color cardLight = Colors.white;

  /// Card background dark
  static const Color cardDark = darkSecondaryColor;

  // ==================== Text Colors ====================
  /// Primary text color (dark)
  static const Color textPrimary = Color(0xff001733);

  /// Secondary text color
  static const Color textSecondary = Color(0xFF757575);

  /// Text color for dark theme
  static const Color textDark = Colors.white;

  /// Text color for light theme
  static const Color textLight = Color(0xff001733);

  // ==================== Status Colors ====================
  /// Success color
  static const Color success = Color(0xFF4CAF50);

  /// Error/Red color
  static const Color error = Colors.red;

  /// Warning color
  static const Color warning = Color(0xFFFF9800);

  /// Info color
  static const Color info = Color(0xFF2196F3);

  // ==================== Rating Colors ====================
  /// Star/rating color
  static const Color star = Colors.amber;

  // ==================== Border Colors ====================
  /// Border color light
  static const Color borderLight = Color(0xFFE0E0E0);

  /// Border color dark
  static const Color borderDark = darkPrimaryColor;

  // ==================== Shadow Colors ====================
  /// Shadow color with opacity
  static Color shadowColor = Colors.black.withOpacity(0.05);

  /// Shadow color dark
  static Color shadowColorDark = Colors.black.withOpacity(0.3);

  // ==================== Theme-aware Getters ====================
  /// Get background color based on current theme
  static Color get backgroundColor =>
      Get.isDarkMode ? backgroundDark : backgroundLight;

  /// Get card color based on current theme
  static Color get cardColor => Get.isDarkMode ? cardDark : cardLight;

  /// Get text color based on current theme
  static Color get textColor => Get.isDarkMode ? Colors.white : textLight;

  /// Get border color based on current theme
  static Color get borderColor => Get.isDarkMode ? borderDark : borderLight;

  /// Get shadow color based on current theme
  static Color get shadow => Get.isDarkMode ? shadowColorDark : shadowColor;

  /// Get app bar background color based on current theme
  static Color get appBarColor => Get.isDarkMode ? darkPrimaryColor : primaryNavy;

  /// Get bottom navigation bar background color based on current theme
  static Color get bottomNavBarColor => Get.isDarkMode ? darkPrimaryColor : primaryNavy;

  /// Get bottom navigation bar selected item color based on current theme
  static Color get bottomNavBarSelectedColor => Get.isDarkMode ? Colors.white : accentBlue;

  /// Get bottom navigation bar unselected item color based on current theme
  static Color get bottomNavBarUnselectedColor => Get.isDarkMode ? Colors.white70 : Colors.white70;

  // ==================== Grey Shades ====================
  /// Grey shade 50
  static Color get grey50 => Colors.grey.shade50;

  /// Grey shade 100
  static Color get grey100 => Colors.grey.shade100;

  /// Grey shade 300
  static Color get grey300 => Colors.grey.shade300;

  /// Grey shade 400
  static Color get grey400 => Colors.grey.shade400;

  /// Grey shade 600
  static Color get grey600 => Colors.grey.shade600;

  /// Grey shade 700
  static Color get grey700 => Colors.grey.shade700;

  // ==================== Blue Shades ====================
  /// Blue shade 50
  static Color get blue50 => Colors.blue.shade50;

  /// Blue shade 700
  static Color get blue700 => Colors.blue.shade700;
}
