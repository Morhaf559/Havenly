import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../reservations/models/reservation_modification_model.dart';
import '../../../reservations/models/reservation_model.dart';
import '../../../reservations/views/widgets/reservation_status_badge.dart';

/// Owner Modification Request Card Widget
/// Displays a modification request card with reservation info, modification type, old/new values, and action buttons
class OwnerModificationRequestCardWidget extends StatelessWidget {
  final ReservationModificationModel modification;
  final ReservationModel? reservation; // Optional reservation details
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OwnerModificationRequestCardWidget({
    super.key,
    required this.modification,
    this.reservation,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  /// Format date string
  String _formatDate(String? date) {
    if (date == null || date.isEmpty) return 'N/A'.tr;
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  /// Get modification type text
  String _getModificationTypeText() {
    switch (modification.type?.toLowerCase()) {
      case 'start_date':
        return 'Check-in Date'.tr;
      case 'end_date':
        return 'Check-out Date'.tr;
      default:
        return modification.type ?? 'Unknown'.tr;
    }
  }

  /// Get old value (current reservation date)
  String? _getOldValue() {
    if (reservation == null) return null;
    
    switch (modification.type?.toLowerCase()) {
      case 'start_date':
        return reservation!.startDate;
      case 'end_date':
        return reservation!.endDate;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final apartmentTitle = reservation?.apartment?.getLocalizedTitle(locale) ?? 'Reservation #${modification.reservationId}';
    final apartmentLocation = reservation?.apartment?.city ?? '';
    final oldValue = _getOldValue();
    final newValue = modification.newValue ?? modification.requestedStartDate ?? modification.requestedEndDate;
    final isPending = modification.isPending();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Reservation Info and Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          apartmentTitle,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (apartmentLocation.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  apartmentLocation,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ReservationStatusBadge(status: modification.status),
                ],
              ),
              SizedBox(height: 16.h),

              // Divider
              Divider(
                height: 1,
                color: AppColors.borderColor.withOpacity(0.3),
              ),
              SizedBox(height: 12.h),

              // Modification Type
              Row(
                children: [
                  Icon(
                    Icons.edit_calendar,
                    size: 18.sp,
                    color: AppColors.primaryNavy,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _getModificationTypeText(),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Old Value
              if (oldValue != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _formatDate(oldValue),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],

              // New Value
              if (newValue != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 16.sp,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Requested'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _formatDate(newValue),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
              ],

              // Note (if exists)
              if (modification.note != null && modification.note!.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          modification.note!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Action Buttons (only if pending)
              if (isPending && (onAccept != null || onReject != null))
                Row(
                  children: [
                    if (onAccept != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onAccept,
                          icon: Icon(Icons.check, size: 20.sp),
                          label: Text(
                            'Accept'.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                    if (onAccept != null && onReject != null) SizedBox(width: 12.w),
                    if (onReject != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onReject,
                          icon: Icon(Icons.close, size: 20.sp),
                          label: Text(
                            'Reject'.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red, width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

