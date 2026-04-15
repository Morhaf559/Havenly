import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/governorates/controllers/governorate_controller.dart';

class GovernoratePicker extends StatelessWidget {
  final int? selectedGovernorateId;
  final Function(int?) onChanged;

  const GovernoratePicker({
    super.key,
    this.selectedGovernorateId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GovernorateController());
    final locale = Get.locale?.languageCode ?? 'ar';

    return Obx(() {
      if (controller.isLoading.value) {
        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Governorate'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          items: [],
          onChanged: null,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
          hint: Text(
            'Loading...'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      if (controller.governorates.isEmpty) {
        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Governorate'.tr,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          items: [],
          onChanged: null,
          style: TextStyle(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
          hint: Text(
            'No governorates available'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return DropdownButtonFormField<int>(
        value: selectedGovernorateId,
        decoration: InputDecoration(
          labelText: 'Governorate'.tr,
          hintText: 'Select governorate'.tr,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.textPrimary,
        ),
        dropdownColor: Colors.white,
        items: controller.governorates.map((governorate) {
          final name = governorate.getLocalizedName(locale) ?? 'Unknown';
          return DropdownMenuItem<int>(
            value: governorate.id,
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      );
    });
  }
}

