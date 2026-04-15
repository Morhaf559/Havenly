import 'package:get/get.dart';
import 'package:my_havenly_application/features/auth/controllers/button_check_controller.dart';
import 'package:my_havenly_application/features/auth/controllers/date_controller.dart';
import 'package:my_havenly_application/features/auth/controllers/login_controller.dart';
import 'package:my_havenly_application/features/auth/controllers/logout_controller.dart';
import 'package:my_havenly_application/features/auth/controllers/otp_controller.dart';
import 'package:my_havenly_application/features/auth/controllers/register_controller.dart';
import 'package:my_havenly_application/features/auth/controllers/reset_password_controller.dart';
import 'package:my_havenly_application/features/auth/repositories/auth_repository.dart';
import 'package:my_havenly_application/features/media/bindings/media_binding.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    MediaBinding().dependencies();

    Get.lazyPut<AuthRepository>(() => AuthRepository());

    // LoginController should be permanent to prevent disposal when navigating to reset password
    if (!Get.isRegistered<LoginController>()) {
      Get.put<LoginController>(LoginController(), permanent: true);
    }
    Get.lazyPut<RegisterController>(() => RegisterController());
    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController());
    Get.lazyPut<LogoutController>(() => LogoutController());
    Get.lazyPut<DateController>(() => DateController());
    Get.lazyPut<ButtonCheckController>(() => ButtonCheckController());
    Get.lazyPut<OtpController>(() => OtpController());
  }
}
// todo: save token in get storage