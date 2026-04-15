import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../reservations/models/reservation_model.dart';
import '../../../reservations/views/widgets/reservation_status_badge.dart';

/// Owner Reservation Card Widget
/// Displays a reservation card with apartment info, guest info, dates, and price
class OwnerReservationCardWidget extends StatelessWidget {
  final ReservationModel reservation;
  final VoidCallback? onTap;

  const OwnerReservationCardWidget({
    super.key,
    required this.reservation,
    this.onTap,
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
      final start = DateTime.parse(reservation.startDate);
      final end = DateTime.parse(reservation.endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// Get total price
  /// Uses total_amount from backend if available, otherwise calculates from apartment price
  double? _getTotalPrice() {
    // Prefer total_amount from backend
    if (reservation.totalAmount != null && reservation.totalAmount! > 0) {
      return reservation.totalAmount;
    }
    
    // Fallback to calculation if total_amount is not available
    final apartment = reservation.apartment;
    if (apartment == null) return null;

    final days = _calculateDays();
    if (days <= 0) return null;

    return apartment.price * days;
  }

  /// Get guest name from user ID
  String? _getGuestName() {
    if (reservation.userId != null) {
      return 'Guest #${reservation.userId}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final apartmentTitle = reservation.apartment?.getLocalizedTitle(locale) ?? 'Unknown Apartment';
    final apartmentLocation = reservation.apartment?.city ?? '';
    final totalPrice = _getTotalPrice();
    final days = _calculateDays();
    final guestName = _getGuestName();
    final currency = reservation.apartment?.currency ?? '\$';

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
                  ReservationStatusBadge(status: reservation.status),
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
                      child: Text(
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
                      '${_formatDate(reservation.startDate)} - ${_formatDate(reservation.endDate)}',
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
              if (totalPrice != null && totalPrice > 0)
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
                  ],
                )
              else if (reservation.apartment != null && days > 0 && reservation.apartment!.price > 0)
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
                      '${(reservation.apartment!.price * days).toStringAsFixed(2)} $currency',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
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

