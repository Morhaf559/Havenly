import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DateController extends GetxController {
  var selectedDate = DateTime(2000).obs;

  Future<void> pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime lastDateAllowed = now.add(const Duration(days: 1));

    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate.value,
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
      Get.snackbar('Error', 'There is error in Date');
    }
  }
}
