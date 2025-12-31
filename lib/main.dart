import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/features/auth/Binding/auth_binding.dart';
import 'package:my_havenly_application/features/auth/controller/locale_controller.dart';
import 'core/locale/my_locale.dart';
import 'features/onboarding/view/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///
  await GetStorage.init();

  // Development flag: Set to true to always show onboarding during development
  // Set to false for production to use normal GetStorage-based behavior
  const bool forceShowOnboarding = false;

  ///

  runApp(MyApp(forceShowOnboarding: forceShowOnboarding));
}

class MyApp extends StatelessWidget {
  final bool forceShowOnboarding;
  const MyApp({super.key, required this.forceShowOnboarding});

  @override
  Widget build(BuildContext context) {
    final localeController = Get.put(LocaleController());
    String? savedLang = GetStorage().read<String>('lang');

    ///
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // ثيم الفاتح الأساسي
      darkTheme: ThemeData.dark(), // ثيم الداكن الأساسي
      themeMode: ThemeMode.light,
      initialBinding: AuthBinding(),
      locale: localeController.initialLang,

      translations: MyLocale(),
      home: SplashScreen(forceShowOnboarding: forceShowOnboarding),
    );
  }
}
