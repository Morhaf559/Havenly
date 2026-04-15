import 'package:get/get.dart';

import 'package:http/http.dart';
import 'package:my_havenly_application/features/auth/controller/locale_controller.dart';
import 'package:my_havenly_application/features/auth/controller/logout_controller.dart';
import 'package:my_havenly_application/features/auth/controller/otp_controller.dart';
import 'package:my_havenly_application/features/auth/controller/register_controller.dart';
import '../controller/button_check_controller.dart';
import '../controller/date_controller.dart';
import '../controller/login_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<DateController>(() => DateController());
    Get.lazyPut<ButtonCheckController>(() => ButtonCheckController());
    // Get.lazyPut<LocaleController>(() => LocaleController());
    Get.lazyPut<LogoutController>(() => LogoutController());
    // Get.put<LogoutController>(LogoutController(), permanent: true);
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
