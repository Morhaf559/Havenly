import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/features/auth/Binding/auth_binding.dart';
import 'package:my_havenly_application/features/auth/service/auth_api_service.dart';
import 'package:my_havenly_application/features/home/view/screens/home_screen.dart';

/// LoginController handles login business logic using GetX
class LoginController extends GetxController {
  // Loading state
  final isLoading = false.obs;

  // Form controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  /// Validate input fields
  bool validateInput() {
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'The phone field is empty,\nPlease try again'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Error'.tr,
        'The password field is empty,\nPlease try again'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  /// Login user with phone and password
  /// Handles loading, success, and error states
  Future<void> loginUser() async {
    if (!validateInput()) {
      return;
    }

    isLoading.value = true;

    try {
      final result = await AuthApiService.login(
        phone: phoneController.text,
        password: passwordController.text,
      );

      // Print login result to console
      print('Token: ${result.token}');
      print('User: ${result.user?.toJson()}');
      print('Full Result: ${result.toString()}');

      if (result.token != null && result.user != null) {
        GetStorage().write('token', result.token);
        Get.snackbar(
          'Welcome Back !'.tr,
          'Login successful'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // Navigate to home screen after a short delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAll(() => const HomeScreen(), binding: AuthBinding());
      } else {
        Get.snackbar(
          'Verification failed'.tr,
          'Invalid response from server'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      Get.snackbar(
        'Login failed'.tr,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
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
