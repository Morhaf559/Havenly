import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../reservations/models/reservation_request_model.dart';
import '../../../reservations/views/widgets/reservation_status_badge.dart';

/// Owner Reservation Request Card Widget
/// Displays a reservation request card with apartment info, guest info, dates, price, and action buttons
class OwnerReservationRequestCardWidget extends StatelessWidget {
  final ReservationRequestModel request;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OwnerReservationRequestCardWidget({
    super.key,
    required this.request,
    this.onTap,
    this.onAccept,
    this.onReject,
  });

  /// Format date string
  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  /// Calculate number of days between start and end date
  int _calculateDays() {
    try {
      final start = DateTime.parse(request.startDate);
      final end = DateTime.parse(request.endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Get total price
  /// Uses total_amount from backend if available, otherwise calculates from apartment price
  double? _getTotalPrice() {
    // Prefer total_amount from backend
    if (request.totalAmount != null && request.totalAmount! > 0) {
      return request.totalAmount;
    }
    
    // Fallback to calculation if total_amount is not available
    final apartment = request.apartment;
    if (apartment == null) return null;

    final days = _calculateDays();
    if (days <= 0) return null;

    return apartment.price * days;
  }

  /// Get guest name from user object (if available in JSON)
  String? _getGuestName() {
    // Note: User info should be available in the JSON response
    // For now, we'll use userId or a placeholder
    // This can be enhanced if user object is added to the model
    if (request.userId != null) {
      return 'Guest #${request.userId}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final apartmentTitle = request.apartment?.getLocalizedTitle(locale) ?? 'Unknown Apartment';
    final apartmentLocation = request.apartment?.city ?? '';
    final totalPrice = _getTotalPrice();
    final days = _calculateDays();
    final isPending = request.isPending();
    final guestName = _getGuestName();
    final currency = request.apartment?.currency ?? '\$';

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
              // Header: Apartment Title and Status
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
                  ReservationStatusBadge(status: request.status),
                ],
              ),
              SizedBox(height: 16.h),

              // Divider
              Divider(
                height: 1,
                color: AppColors.borderColor.withOpacity(0.3),
              ),
              SizedBox(height: 12.h),

              // Guest Info
              if (guestName != null)
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child:                     Text(
                      guestName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ),
                  ],
                ),
              if (guestName != null) SizedBox(height: 8.h),

              // Dates
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18.sp,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  if (days > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '$days ${days == 1 ? 'day' : 'days'}'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),

              // Price - Always show if we have price data
              if (totalPrice != null && totalPrice > 0 && request.apartment != null)
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Total: '.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${totalPrice.toStringAsFixed(2)} $currency',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    if (request.apartment!.price > 0) ...[
                      SizedBox(width: 8.w),
                      Text(
                        '(${request.apartment!.price} $currency/day)'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                )
              else if (request.apartment != null && days > 0 && request.apartment!.price > 0)
                // Fallback: show calculated price if total_amount is not available
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 18.sp,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Total: '.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(request.apartment!.price * days).toStringAsFixed(2)} $currency',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '(${request.apartment!.price} $currency/day)'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 12.h),

              // Note (if exists)
              if (request.note != null && request.note!.isNotEmpty) ...[
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
                          request.note!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textColor,
                          ),
                          maxLines: 3,
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

