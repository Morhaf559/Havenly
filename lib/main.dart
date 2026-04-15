import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/core/locale/my_locale.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/utils/screen_util_init.dart';
import 'package:my_havenly_application/core/bindings/core_binding.dart';
import 'package:my_havenly_application/core/controllers/theme_controller.dart';
import 'package:my_havenly_application/core/controllers/locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  CoreBinding().dependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localeController = Get.find<LocaleController>();

    return AppScreenUtilInit(
      child: Obx(
        () => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeController.lightTheme,
          darkTheme: themeController.darkTheme,
          themeMode: themeController.themeMode,
          locale: localeController.currentLocale,
          fallbackLocale: LocaleController.defaultLocale,
          supportedLocales: LocaleController.supportedLocales,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          translations: MyLocale(),
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.getPages,
        ),
      ),
    );
  }
}
