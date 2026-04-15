import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/auth/repositories/auth_repository.dart';

class OtpController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  var isLoading = false.obs;
  var otpDigits = List<String>.filled(5, "").obs;

  @override
  void onInit() {
    super.onInit();
    final String phone = Get.arguments?['phone'] ?? '';
    if (phone.isNotEmpty) {
      _authRepository.sendOtp(phone);
    }
  }

  Future<void> sendOtpAutomatically(String phone) async {
    try {
      await _authRepository.sendOtp(phone);
    } catch (e) {
      print("Error sending OTP: $e");
    }
  }

  Future<void> otpVerify(String phone) async {
    try {
      isLoading.value = true;
      String code = otpDigits.join("").trim();

      final bool isSuccess = await _authRepository.verifyOtp(
        phone: phone,
        otp: code,
      );

      if (isSuccess == true) {
        final storage = GetStorage();
        await storage.write('has_seen_onboarding', true);

        Get.snackbar(
          'Success'.tr,
          'Account verified successfully'.tr,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.snackbar(
          'Error'.tr,
          'Verification failed'.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Caught Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}