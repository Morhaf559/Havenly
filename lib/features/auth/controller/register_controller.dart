import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/auth/Binding/auth_binding.dart';
import 'package:my_havenly_application/features/auth/service/auth_api_service.dart';
import 'package:my_havenly_application/features/home/view/screens/home_screen.dart';

import 'date_controller.dart';

/// RegisterController handles registration business logic using GetX
class RegisterController extends GetxController {
  // Loading state
  final isLoading = false.obs;

  // Terms agreement state
  final agreedToTerms = false.obs;

  // Image paths
  final idImagePath = Rxn<String>();
  final personalPhotoPath = Rxn<String>();

  // Form controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmedPasswordController = TextEditingController();

  // Date controller dependency
  final DateController dateController = Get.find<DateController>();

  /// Toggle terms agreement
  void toggleTerms(bool? value) {
    if (value != null) {
      agreedToTerms.value = value;
    }
  }

  /// Validate all input fields
  bool validateInput() {
    if (firstNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error'.tr,
        'First name is required'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error'.tr,
        'Last name is required'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error'.tr,
        'Phone number is required'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error'.tr,
        'Username is required'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error'.tr,
        'Password is required'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (confirmedPasswordController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error'.tr,
        'Password confirmation is required'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (passwordController.text != confirmedPasswordController.text) {
      Get.snackbar(
        'Validation Error'.tr,
        'Passwords do not match'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (idImagePath.value == null || personalPhotoPath.value == null) {
      Get.snackbar(
        'Validation Error'.tr,
        'Please upload both ID photo and personal photo'.tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    return true;
  }

  /// Register a new user
  /// Handles loading, success, and error states
  Future<void> registerUser() async {
    if (!validateInput()) {
      return;
    }

    isLoading.value = true;

    try {
      final result = await AuthApiService.register(
        phone: phoneController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        username: usernameController.text,
        password: passwordController.text,
        passwordConfirmation: confirmedPasswordController.text,
        dateOfBirth: dateController.selectedDate.value
            .toIso8601String()
            .split('T')
            .first,
        idPhoto: File(idImagePath.value!),
        personalPhoto: File(personalPhotoPath.value!),
      );

      // Print registration result to console
      print('Token: ${result.token}');
      print('User: ${result.user?.toJson()}');
      print('Full Result: ${result.toString()}');

      if (result.token != null && result.user != null) {
        Get.snackbar(
          'Congratulations!'.tr,
          'The account has been created successfully'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to home screen after a short delay to show success message
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAll(() => const HomeScreen(), binding: AuthBinding());
      } else {
        Get.snackbar(
          'Registration failed'.tr,
          'Invalid response from server'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      Get.snackbar(
        'Registration failed'.tr,
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmedPasswordController.dispose();
    super.onClose();
  }
}
