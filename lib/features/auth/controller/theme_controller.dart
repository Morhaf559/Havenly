import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController {
  // ألوان ثابتة من تصميمك
  static const Color myNavy = Color(0xff001733);
  static const Color myBlue = Color(0xff0056b3);

  // ألوان ذكية تتغير حسب الثيم (بسيطة جداً)
  static Color get bg => Get.isDarkMode ? Colors.black : myNavy;
  static Color get card =>
      Get.isDarkMode ? const Color(0xFF222222) : Colors.white;
  static Color get text => Get.isDarkMode ? Colors.white : myNavy;
}
