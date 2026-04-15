import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController {
  // دالة مساعدة لمعرفة هل نحن في الوضع الداكن أم لا
  static bool get isDark => Get.isDarkMode;

  // تعريف ألوان الصفحات (فاتح : داكن)
  static Color get loginBg => isDark ? Color(0xff121212) : Color(0xff001733);
  static Color get homeBg => isDark ? Color(0xff1e1e1e) : Colors.white;
  static Color get settingsBg => isDark ? Color(0xff8E918F) : Colors.grey[200]!;

  // الثيمات الأساسية التي توضع في main.dart
  static final lightTheme = ThemeData(brightness: Brightness.light);
  static final darkTheme = ThemeData(brightness: Brightness.dark);

  static Color getHomeBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Color(0xff1e1e1e) // لون الداكن
        : Colors.white;
  }
}


/* import 'package:flutter/material.dart';
class ThemeController {
  // تعريف الألوان كمتغيرات ثابتة لاستخدامها في ThemeData
  static const Color lightScaffold = Color(
    0xff001733,
  ); // اللون الأزرق الذي تستخدمه في الخلفية
  static const Color lightCard = Colors.white;

  static const Color darkScaffold = Color(0xff121212);
  static const Color darkCard = Color(0xff1E1E1E);

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightScaffold,
    cardColor: lightCard,

    // أي تنسيقات أخرى
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkScaffold,
    cardColor: darkCard,
  );
}
 */