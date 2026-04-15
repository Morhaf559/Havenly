import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/validators.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/auth/repositories/auth_repository.dart';
import 'package:my_havenly_application/features/auth/view/screens/otp_screen.dart';
import 'date_controller.dart';

class RegisterController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final isLoading = false.obs;

  final agreedToTerms = false.obs;

  final idImagePath = Rxn<String>();
  final personalPhotoPath = Rxn<String>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmedPasswordController = TextEditingController();

  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();
  final usernameError = Rxn<String>();
  final phoneError = Rxn<String>();
  final passwordError = Rxn<String>();
  final confirmedPasswordError = Rxn<String>();
  final idImageError = Rxn<String>();
  final personalPhotoError = Rxn<String>();

  final DateController dateController = Get.find<DateController>();

  @override
  void onInit() {
    super.onInit();
    firstNameController.addListener(_onFirstNameChanged);
    lastNameController.addListener(_onLastNameChanged);
    usernameController.addListener(_onUsernameChanged);
    phoneController.addListener(_onPhoneChanged);
    passwordController.addListener(_onPasswordChanged);
    confirmedPasswordController.addListener(_onConfirmedPasswordChanged);
  }

  void _onFirstNameChanged() {
    if (firstNameError.value != null) {
      firstNameError.value = null;
    }
  }

  void _onLastNameChanged() {
    if (lastNameError.value != null) {
      lastNameError.value = null;
    }
  }

  void _onUsernameChanged() {
    if (usernameError.value != null) {
      usernameError.value = null;
    }
  }

  void _onPhoneChanged() {
    if (phoneError.value != null) {
      phoneError.value = null;
    }
  }

  void _onPasswordChanged() {
    if (passwordError.value != null) {
      passwordError.value = null;
    }
    if (confirmedPasswordError.value != null &&
        confirmedPasswordController.text.isNotEmpty) {
      confirmedPasswordError.value = null;
    }
  }

  void _onConfirmedPasswordChanged() {
    if (confirmedPasswordError.value != null) {
      confirmedPasswordError.value = null;
    }
  }

  void toggleTerms(bool? value) {
    if (value != null) {
      agreedToTerms.value = value;
    }
  }

  bool validateInput() {
    bool isValid = true;

    final firstNameValidationError = Validators.validateFirstName(
      firstNameController.text,
    );
    firstNameError.value = firstNameValidationError;
    if (firstNameValidationError != null) {
      isValid = false;
    }

    final lastNameValidationError = Validators.validateLastName(
      lastNameController.text,
    );
    lastNameError.value = lastNameValidationError;
    if (lastNameValidationError != null) {
      isValid = false;
    }

    final usernameValidationError = Validators.validateUsername(
      usernameController.text,
    );
    usernameError.value = usernameValidationError;
    if (usernameValidationError != null) {
      isValid = false;
    }

    final phoneValidationError = Validators.validatePhone(phoneController.text);
    phoneError.value = phoneValidationError;
    if (phoneValidationError != null) {
      isValid = false;
    }

    final passwordValidationError = Validators.validatePassword(
      passwordController.text,
    );
    passwordError.value = passwordValidationError;
    if (passwordValidationError != null) {
      isValid = false;
    }

    final confirmedPasswordValidationError =
        Validators.validatePasswordConfirmation(
          confirmedPasswordController.text,
          passwordController.text,
        );
    confirmedPasswordError.value = confirmedPasswordValidationError;
    if (confirmedPasswordValidationError != null) {
      isValid = false;
    }

    final idImageValidationError = Validators.validateImage(
      idImagePath.value,
      fieldName: 'ID photo',
    );
    idImageError.value = idImageValidationError;
    if (idImageValidationError != null) {
      isValid = false;
    }

    final personalPhotoValidationError = Validators.validateImage(
      personalPhotoPath.value,
      fieldName: 'personal photo',
    );
    personalPhotoError.value = personalPhotoValidationError;
    if (personalPhotoValidationError != null) {
      isValid = false;
    }

    if (dateController.selectedDate.value == null) {
      isValid = false;
    }

    return isValid;
  }

  Future<void> registerUser() async {
    if (!validateInput()) {
      return;
    }

    if (idImagePath.value == null || personalPhotoPath.value == null) {
      Get.snackbar(
        'Validation Error'.tr,
        'Please upload both ID photo and personal photo'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (dateController.selectedDate.value == null) {
      Get.snackbar(
        'Validation Error'.tr,
        'Date of birth is required'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    try {
      final idPhotoFile = File(idImagePath.value!);
      final personalPhotoFile = File(personalPhotoPath.value!);

      await _authRepository.register(
        phone: phoneController.text,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        username: usernameController.text,
        password: passwordController.text,
        passwordConfirmation: confirmedPasswordController.text,
        dateOfBirth: dateController.selectedDate.value!.toIso8601String().split(
          'T',
        )[0],
        idPhoto: idPhotoFile,
        personalPhoto: personalPhotoFile,
      );

      Get.snackbar(
        'Congratulations!'.tr,
        'The account has been created successfully'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAll(OtpScreen(), arguments: {'phone': phoneController.text});
    } on ApiException catch (e) {
      final errorMessage = e.message;

      Get.snackbar(
        'Registration failed'.tr,
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      Get.snackbar(
        'Registration failed'.tr,
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
    firstNameController.removeListener(_onFirstNameChanged);
    lastNameController.removeListener(_onLastNameChanged);
    usernameController.removeListener(_onUsernameChanged);
    phoneController.removeListener(_onPhoneChanged);
    passwordController.removeListener(_onPasswordChanged);
    confirmedPasswordController.removeListener(_onConfirmedPasswordChanged);
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmedPasswordController.dispose();
    super.onClose();
  }
}
