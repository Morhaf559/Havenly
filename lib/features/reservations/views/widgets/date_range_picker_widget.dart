import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';

class DateRangePickerWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime) onStartDateSelected;
  final Function(DateTime) onEndDateSelected;

  const DateRangePickerWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
  });

  Future<void> _selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    // Ensure initialDate is not before firstDate (DateTime.now())
    final initialDate = startDate != null && !startDate!.isBefore(now)
        ? startDate!
        : now;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      onStartDateSelected(picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final now = DateTime.now();
    // Ensure firstDate is not in the past
    final firstDate = startDate != null && startDate!.isAfter(now)
        ? startDate!
        : now;
    
    // Ensure initialDate is not before firstDate
    DateTime initialDate;
    if (endDate != null && !endDate!.isBefore(firstDate)) {
      initialDate = endDate!;
    } else if (startDate != null && startDate!.isAfter(now)) {
      initialDate = startDate!.add(const Duration(days: 1));
    } else {
      initialDate = now.add(const Duration(days: 1));
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      onEndDateSelected(picked);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select Date'.tr;
    final locale = Get.locale?.languageCode ?? 'en';
    return DateHelper.formatForDisplay(date, locale: locale);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _selectStartDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Date'.tr,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(startDate),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
                Icon(Icons.calendar_today, size: 24.sp, color: Colors.grey),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),

        InkWell(
          onTap: () => _selectEndDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'End Date'.tr,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(endDate),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
                Icon(Icons.calendar_today, size: 24.sp, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
