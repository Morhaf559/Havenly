import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/date_controller.dart';

class DateTimeWidget extends StatelessWidget {
  DateTimeWidget({super.key});
  final DateController controller = Get.put(DateController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Date of birth'.tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xff001733),
          ),
        ),
        const SizedBox(height: 8),

        Obx(
          () => MaterialButton(
            onPressed: () {
              controller.pickDate(context);
            },
            color: Color(0xffE0E4EB),
            textColor: Color(0xff001733),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),

            child: Text(
              '${controller.selectedDate.value.day.toString().padLeft(2, '0')}/'
              '${controller.selectedDate.value.month.toString().padLeft(2, '0')}/'
              '${controller.selectedDate.value.year}',
              style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}
