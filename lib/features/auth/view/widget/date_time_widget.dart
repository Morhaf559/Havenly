import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/auth/controllers/date_controller.dart';

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DateController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of birth'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(
          () => MaterialButton(
            onPressed: () {
              controller.pickDate(context);
            },
            color: AppColors.grey100,
            textColor: AppColors.textPrimary,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18.sp,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 8.w),
                Text(
                  controller.selectedDate.value != null
                      ? '${controller.selectedDate.value!.day.toString().padLeft(2, '0')}/'
                          '${controller.selectedDate.value!.month.toString().padLeft(2, '0')}/'
                          '${controller.selectedDate.value!.year}'
                      : 'Select Date'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
