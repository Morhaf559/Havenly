import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:havenly/features/auth/controller/date_controller.dart';
import 'package:havenly/features/auth/service/auth_register_service.dart';

class RegisterController extends GetxController {
  var isLoading = false.obs;
  var agreedToTerms = false.obs;
  var idImagePath = Rxn<String>();
  var personalPhotoPath = Rxn<String>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmedPasswordController = TextEditingController();

  final DateController dateController = Get.find<DateController>();

  void toggleTerms(bool? value) {
    if (value != null) {
      agreedToTerms.value = value;
    }
  }

  bool validateInput() {
    print('Value of firstNameController: "${firstNameController.text}"');
    print('Value after trim: "${firstNameController.text.trim()}"');
    if (firstNameController.text.trim().isEmpty) {
      Get.snackbar('فشل التحقق', 'الاسم الأول فارغ أو يحتوي على مسافات.');
      return false;
    }
    if (lastNameController.text.trim().isEmpty) {
      Get.snackbar('فشل التحقق', 'الاسم الأخير فارغ أو يحتوي على مسافات.');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('فشل التحقق', 'رقم الهاتف فارغ أو يحتوي على مسافات.');
      return false;
    }
    if (usernameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'The USERNAME has a sapce or empty');
      return false;
    }
    if (passwordController.text.trim().isEmpty) {
      Get.snackbar('فشل التحقق', 'كلمة المرور فارغة.');
      return false;
    }
    if (confirmedPasswordController.text.trim().isEmpty) {
      Get.snackbar('فشل التحقق', 'تأكيد كلمة المرور فارغ.');
      return false;
    }
    /* if (!agreedToTerms.value) {
      Get.snackbar('خطأ', 'يجب الموافقة على الشروط والأحكام.');
      return false;
    } */
    if (passwordController.text != confirmedPasswordController.text) {
      Get.snackbar('خطأ', 'لا يوجد تطابق');
      return false;
    }
    if (idImagePath.value == null || personalPhotoPath.value == null) {
      Get.snackbar('Warning', 'Please Upload the photo');
      return false;
    }
    return true;
  }

  Future<void> registerUser() async {
    if (!validateInput()) {
      return;
    }

    isLoading.value = true;

    try {
      final userData = {
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'username': usernameController.text,
        'phoneNumber': phoneController.text,
        'password': passwordController.text,
        'dateOfBirth': dateController.selectedDate.value
            .toIso8601String()
            .split('T')
            .first,
        'idImage': idImagePath.value,
        'personalPhoto': personalPhotoPath.value,
      };

      await AuthRegisterService().register(
        phoneController.text,
        firstNameController.text,

        lastNameController.text,
        usernameController.text,
        passwordController.text,
        confirmedPasswordController.text,
        dateController.selectedDate.value.toIso8601String().split('T').first,
        File(idImagePath.value!),
        File(personalPhotoPath.value!),
      );

      Get.snackbar(
        'Congratulations!',
        'The account has been created successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
      );

      // Get.offAll();                // الصفحة يلي ما بعد انشاء الحساب
    } catch (e) {
      Get.snackbar(
        'خطأ في التسجيل',
        'فشل التسجيل: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      print(e);
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
