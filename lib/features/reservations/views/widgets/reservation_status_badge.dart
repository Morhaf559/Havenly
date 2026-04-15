import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReservationStatusBadge extends StatelessWidget {
  final String? status;

  const ReservationStatusBadge({super.key, this.status});

  Color _getStatusColor() {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'active':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'Pending'.tr;
      case 'accepted':
        return 'Accepted'.tr;
      case 'rejected':
        return 'Rejected'.tr;
      case 'cancelled':
        return 'Cancelled'.tr;
      case 'active':
        return 'Active'.tr;
      case 'completed':
        return 'Completed'.tr;
      default:
        return status ?? 'Unknown'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _getStatusColor().withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _getStatusColor(), width: 1),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
