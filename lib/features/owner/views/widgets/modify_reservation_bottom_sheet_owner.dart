import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/date_range_picker_widget.dart';
import '../../controllers/owner_reservation_details_controller.dart';

/// Modify Reservation Bottom Sheet for Owner
/// Allows owner to request modification for a reservation
class ModifyReservationBottomSheetOwner extends StatefulWidget {
  final OwnerReservationDetailsController controller;
  final DateTime currentStartDate;
  final DateTime currentEndDate;

  const ModifyReservationBottomSheetOwner({
    super.key,
    required this.controller,
    required this.currentStartDate,
    required this.currentEndDate,
  });

  static Future<bool?> show(
    BuildContext context, {
    required OwnerReservationDetailsController controller,
    required DateTime currentStartDate,
    required DateTime currentEndDate,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => ModifyReservationBottomSheetOwner(
        controller: controller,
        currentStartDate: currentStartDate,
        currentEndDate: currentEndDate,
      ),
    );
  }

  @override
  State<ModifyReservationBottomSheetOwner> createState() =>
      _ModifyReservationBottomSheetOwnerState();
}

class _ModifyReservationBottomSheetOwnerState
    extends State<ModifyReservationBottomSheetOwner> {
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.currentStartDate;
    _selectedEndDate = widget.currentEndDate;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Request Modification'.tr,
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

              // Date Selection
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
                      _selectedStartDate!, _selectedEndDate!)) ...[
                SizedBox(height: 8.h),
                Text(
                  'End date must be after start date'.tr,
                  style: TextStyle(fontSize: 12.sp, color: Colors.red),
                ),
              ],

              SizedBox(height: 16.h),

              // Note Field (Optional)
              Text(
                'Note (Optional)'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add a note about this modification request...'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  if (widget.controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _canSubmit
                        ? () async {
                            final success = await widget.controller
                                .requestModification(
                                  requestedStartDate: _selectedStartDate,
                                  requestedEndDate: _selectedEndDate,
                                  note: _noteController.text.trim().isEmpty
                                      ? null
                                      : _noteController.text.trim(),
                                );

                            if (success && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      backgroundColor: const Color(0xff001733),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Request Modification'.tr),
                  );
                }),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}