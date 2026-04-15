import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateController extends GetxController {
  final selectedDate = Rxn<DateTime>();

  Future<void> pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime lastDateAllowed = now.subtract(const Duration(days: 365 * 18));

    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value ?? DateTime(2000),
        firstDate: DateTime(1900),
        lastDate: lastDateAllowed,
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        selectedDate.value = picked;
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'There is error in Date'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void clearDate() {
    selectedDate.value = null;
  }
}
