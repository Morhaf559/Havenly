import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/core/utils/validators.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/auth/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final isLoading = false.obs;
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final phoneError = Rxn<String>();
  final passwordError = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(_onPhoneChanged);
    passwordController.addListener(_onPasswordChanged);
  }

  void _onPhoneChanged() => phoneError.value = null;
  void _onPasswordChanged() => passwordError.value = null;

  void clearFields() {
    phoneController.clear();
    passwordController.clear();
    phoneError.value = null;
    passwordError.value = null;
  }

  bool validateInput() {
    phoneError.value = Validators.validatePhone(phoneController.text);
    passwordError.value = Validators.validatePassword(passwordController.text);
    return phoneError.value == null && passwordError.value == null;
  }

  Future<void> loginUser() async {
    if (!validateInput()) return;
    isLoading.value = true;

    try {
      await _authRepository.login(
        phone: phoneController.text,
        password: passwordController.text,
      );

      final storage = GetStorage();
      await storage.write('has_seen_onboarding', true);

      Get.snackbar(
        'Welcome Back !'.tr,
        'Login successful'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(AppRoutes.main);
    } catch (e) {
      Get.snackbar(
        'Login failed'.tr,
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.removeListener(_onPhoneChanged);
    passwordController.removeListener(_onPasswordChanged);
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
