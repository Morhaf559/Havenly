import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';
import 'package:my_havenly_application/features/auth/service/auth_api_service.dart';
import 'package:my_havenly_application/features/auth/view/screens/login_screen.dart';

class LogoutController extends GetxController {
  Future<void> logout() async {
    try {
      bool? success = await AuthApiService.logout();
      if (success!) {
        Get.offAll(() => LoginScreen());
      }
    } catch (e) {
      GetSnackBar(
        title: 'error',
        message:
            'error un expected in connection, please try again later${e.toString()}',
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
