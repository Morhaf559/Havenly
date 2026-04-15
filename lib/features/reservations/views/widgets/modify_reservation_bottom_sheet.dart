import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_modification_controller.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/date_range_picker_widget.dart';

class ModifyReservationBottomSheet extends StatefulWidget {
  final int reservationId;
  final DateTime currentStartDate;
  final DateTime currentEndDate;

  const ModifyReservationBottomSheet({
    super.key,
    required this.reservationId,
    required this.currentStartDate,
    required this.currentEndDate,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int reservationId,
    required DateTime currentStartDate,
    required DateTime currentEndDate,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => ModifyReservationBottomSheet(
        reservationId: reservationId,
        currentStartDate: currentStartDate,
        currentEndDate: currentEndDate,
      ),
    );
  }

  @override
  State<ModifyReservationBottomSheet> createState() =>
      _ModifyReservationBottomSheetState();
}

class _ModifyReservationBottomSheetState
    extends State<ModifyReservationBottomSheet> {
  final ReservationModificationController _controller =
      Get.find<ReservationModificationController>();

  String _modificationType = 'date'; // 'date' or 'cancel'
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.currentStartDate;
    _selectedEndDate = widget.currentEndDate;
  }

  bool get _canSubmit {
    if (_modificationType == 'cancel') {
      return true;
    }
    // For date modification, both dates must be selected and valid
    return _selectedStartDate != null &&
        _selectedEndDate != null &&
        DateHelper.isValidDateRange(_selectedStartDate!, _selectedEndDate!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Modify Reservation'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                Text(
                  'Select modification type'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Change Dates'.tr),
                        value: 'date',
                        groupValue: _modificationType,
                        onChanged: (value) {
                          setState(() {
                            _modificationType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Cancel Reservation'.tr),
                        value: 'cancel',
                        groupValue: _modificationType,
                        onChanged: (value) {
                          setState(() {
                            _modificationType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                if (_modificationType == 'date') ...[
                  Text(
                    'Select new dates'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  DateRangePickerWidget(
                    startDate: _selectedStartDate,
                    endDate: _selectedEndDate,
                    onStartDateSelected: (date) {
                      setState(() {
                        _selectedStartDate = date;
                        // Ensure end date is after start date
                        if (_selectedEndDate != null &&
                            _selectedEndDate!.isBefore(date)) {
                          _selectedEndDate = date.add(const Duration(days: 1));
                        }
                      });
                    },
                    onEndDateSelected: (date) {
                      setState(() {
                        _selectedEndDate = date;
                      });
                    },
                  ),
                  if (_selectedStartDate != null &&
                      _selectedEndDate != null &&
                      !DateHelper.isValidDateRange(
                        _selectedStartDate!,
                        _selectedEndDate!,
                      )) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'End date must be after start date'.tr,
                      style: TextStyle(fontSize: 12.sp, color: Colors.red),
                    ),
                  ],
                ] else if (_modificationType == 'cancel') ...[
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 24.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Are you sure you want to cancel this reservation?'
                                .tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  child: Obx(() {
                    if (_controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _canSubmit
                          ? () async {
                              final success = await _controller
                                  .requestModification(
                                    reservationId: widget.reservationId,
                                    requestedStartDate:
                                        _modificationType == 'date'
                                        ? _selectedStartDate
                                        : null,
                                    requestedEndDate:
                                        _modificationType == 'date'
                                        ? _selectedEndDate
                                        : null,
                                    isCancellation:
                                        _modificationType == 'cancel',
                                  );

                              if (success && context.mounted) {
                                Get.snackbar(
                                  'Success'.tr,
                                  _modificationType == 'cancel'
                                      ? 'Cancellation requested successfully'.tr
                                      : 'Modification requested successfully'
                                            .tr,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
                                Navigator.pop(context, true);
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        backgroundColor: _modificationType == 'cancel'
                            ? Colors.red
                            : const Color(0xff001733),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _modificationType == 'cancel'
                            ? 'Request Cancellation'.tr
                            : 'Request Modification'.tr,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
