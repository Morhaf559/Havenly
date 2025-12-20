import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havenly/features/auth/service/auth_login_service.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool validateInput() {
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'The phone field is empty,\nPlease try again');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar('Error', 'THe password field is empty,\nPlease try again');
      return false;
    }

    return true;
  }

  Future<void> loginUser() async {
    if (!validateInput()) return;

    isLoading.value = true;

    try {
      final result = await AuthLoginService().Login(
        phoneController.text,
        passwordController.text,
      );
      if (result != null) {
        Get.snackbar(
          'Welcome Back!',
          'Login successful',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        //Get.offAll(page);             صفحة ال home
      } else {
        Get.snackbar(
          'Verification failed',
          'Incorrect password or phone number',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Unexpected error',
        'Technical error $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
