import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/validators.dart';
import 'package:my_havenly_application/features/auth/repositories/auth_repository.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/auth/controllers/login_controller.dart';

class ResetPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmationController = TextEditingController();

  final isLoading = false.obs;
  final phoneError = Rxn<String>();
  final passwordError = Rxn<String>();
  final passwordConfirmationError = Rxn<String>();

  // Store listener functions to remove them later
  void _onPhoneChanged() => phoneError.value = null;
  void _onPasswordChanged() => passwordError.value = null;
  void _onPasswordConfirmationChanged() =>
      passwordConfirmationError.value = null;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_onPhoneChanged);
    passwordController.addListener(_onPasswordChanged);
    passwordConfirmationController.addListener(_onPasswordConfirmationChanged);
  }

  bool validateInput() {
    phoneError.value = Validators.validatePhone(phoneController.text);
    passwordError.value = Validators.validatePassword(passwordController.text);
    passwordConfirmationError.value = Validators.validatePasswordConfirmation(
      passwordConfirmationController.text,
      passwordController.text,
    );

    return phoneError.value == null &&
        passwordError.value == null &&
        passwordConfirmationError.value == null;
  }

  Future<void> resetPassword() async {
    if (!validateInput()) return;
    isLoading.value = true;

    try {
      await _authRepository.resetPassword(
        phone: phoneController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: passwordConfirmationController.text,
      );

      Get.snackbar(
        'Success'.tr,
        'Password reset successfully'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear all fields before navigation
      phoneController.clear();
      passwordController.clear();
      passwordConfirmationController.clear();
      phoneError.value = null;
      passwordError.value = null;
      passwordConfirmationError.value = null;

      await Future.delayed(const Duration(milliseconds: 600));

      // Clear login fields before navigation
      if (Get.isRegistered<LoginController>()) {
        try {
          final loginController = Get.find<LoginController>();
          loginController.clearFields();
        } catch (e) {
          // Continue even if clearing fails
        }
      }

      // Navigate to login screen
      // Use offNamed to replace current screen (reset password) with login screen
      // Since LoginController is permanent, it won't be disposed
      Get.offNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Error'.tr, e.toString(), backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Remove listeners first before disposing
    phoneController.removeListener(_onPhoneChanged);
    passwordController.removeListener(_onPasswordChanged);
    passwordConfirmationController.removeListener(
      _onPasswordConfirmationChanged,
    );

    // Clear controllers
    phoneController.clear();
    passwordController.clear();
    passwordConfirmationController.clear();

    // Dispose controllers
    phoneController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    super.onClose();
  }
}
