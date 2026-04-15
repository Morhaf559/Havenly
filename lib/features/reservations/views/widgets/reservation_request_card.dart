import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_request_model.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/reservation_status_badge.dart';

class ReservationRequestCard extends StatelessWidget {
  final ReservationRequestModel request;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const ReservationRequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onCancel,
  });

  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final apartmentTitle =
        request.apartment?.getLocalizedTitle(locale) ?? 'Unknown Apartment';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      apartmentTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ReservationStatusBadge(status: request.status),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16.sp, color: Colors.grey),
                  SizedBox(width: 8.w),
                  Text(
                    '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              if (request.note != null && request.note!.isNotEmpty) ...[
                Text(
                  'Note: ${request.note}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
              ],
              if (request.canBeCancelled() && onCancel != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onCancel,
                    icon: Icon(Icons.cancel, size: 18.sp),
                    label: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
