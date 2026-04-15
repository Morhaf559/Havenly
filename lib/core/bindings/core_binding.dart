import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/core/controllers/locale_controller.dart';
import 'package:my_havenly_application/core/controllers/theme_controller.dart';

class CoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthStateController>(AuthStateController(), permanent: true);
    Get.put<LocaleController>(LocaleController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
  }
}
