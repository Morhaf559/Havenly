import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/instance_manager.dart';
import 'package:havenly/features/auth/controller/button_check_controller.dart';
import 'package:havenly/features/auth/controller/date_controller.dart';
import 'package:havenly/features/auth/controller/login_controller.dart';
import 'package:havenly/features/auth/controller/register_controller.dart';

import 'package:http/http.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(() => RegisterController());
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<DateController>(() => DateController());
    Get.lazyPut<ButtonCheckController>(() => ButtonCheckController());
  }
}
