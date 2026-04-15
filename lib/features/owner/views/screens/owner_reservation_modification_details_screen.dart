import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../reservations/views/widgets/reservation_status_badge.dart';
import '../../controllers/owner_reservation_modification_details_controller.dart';
import '../widgets/accept_reject_dialog_widget.dart';

/// Owner Reservation Modification Details Screen
/// Displays comprehensive details of a modification request
class OwnerReservationModificationDetailsScreen extends StatelessWidget {
  final int modificationId;

  const OwnerReservationModificationDetailsScreen({
    super.key,
    required this.modificationId,
  });

  @override
  Widget build(BuildContext context) {
    // OwnerReservationModificationDetailsController should be initialized via OwnerBinding
    final controller = Get.put(
      OwnerReservationModificationDetailsController(
        modificationId: modificationId,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(title: Text('Modification Details'.tr), elevation: 0),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value &&
            controller.modification.value == null) {
          return const LoadingWidget(
            message: 'Loading modification details...',
          );
        }

        // Error State
        if (controller.errorMessage.value != null &&
            controller.modification.value == null) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refresh(),
          );
        }

        final modification = controller.modification.value;
        if (modification == null) {
          return Center(
            child: Text(
              'Modification not found'.tr,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          );
        }

        final reservation = controller.reservation.value;

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Center(
                  child: ReservationStatusBadge(status: modification.status),
                ),
                SizedBox(height: 24.h),

                // Reservation Information Section
                if (reservation != null) ...[
                  _buildSectionTitle('Reservation Information'.tr),
                  SizedBox(height: 12.h),
                  _buildReservationInfo(reservation),
                  SizedBox(height: 24.h),
                ],

                // Modification Details Section
                _buildSectionTitle('Modification Details'.tr),
                SizedBox(height: 12.h),
                _buildModificationDetails(modification, reservation),
                SizedBox(height: 24.h),

                // Notes Section (if exists)
                if (modification.note != null &&
                    modification.note!.isNotEmpty) ...[
                  _buildSectionTitle('Notes'.tr),
                  SizedBox(height: 12.h),
                  _buildNotesSection(modification),
                  SizedBox(height: 24.h),
                ],

                // Action Buttons (only if pending)
                if (modification.isPending()) ...[
                  _buildActionButtons(context, controller),
                  SizedBox(height: 24.h),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Build Section Title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textColor,
      ),
    );
  }

  /// Build Reservation Information Card
  Widget _buildReservationInfo(reservation) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final apartment = reservation.apartment;
    if (apartment == null) {
      return _buildInfoCard(
        child: Text(
          'Reservation information not available'.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      );
    }

    final title = apartment.getLocalizedTitle(locale) ?? 'No Title'.tr;
    final address =
        apartment.getLocalizedAddress(locale) ?? apartment.city ?? '';

    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apartment Title
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 8.h),

          // Address
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18.sp,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Current Dates
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Current Check-in'.tr,
            value: _formatDate(reservation.startDate),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Current Check-out'.tr,
            value: _formatDate(reservation.endDate),
          ),
          SizedBox(height: 12.h),

          // View Reservation Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.ownerReservationDetails,
                  parameters: {'id': reservation.id.toString()},
                );
              },
              icon: Icon(Icons.visibility, size: 18.sp),
              label: Text('View Reservation Details'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryNavy,
                side: BorderSide(color: AppColors.primaryNavy),
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Modification Details Card
  Widget _buildModificationDetails(modification, reservation) {
    final modificationType = _getModificationTypeText(modification);
    final oldValue = _getOldValue(modification, reservation);
    final newValue = _getNewValue(modification);

    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modification Type
          Row(
            children: [
              Icon(
                Icons.edit_calendar,
                size: 24.sp,
                color: AppColors.primaryNavy,
              ),
              SizedBox(width: 12.w),
              Text(
                modificationType,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Old Value (Current)
          if (oldValue != null) ...[
            _buildDetailRow(
              icon: Icons.arrow_back,
              label: 'Current Value'.tr,
              value: _formatDate(oldValue),
            ),
            SizedBox(height: 16.h),
          ],

          // New Value (Requested)
          if (newValue != null) ...[
            _buildDetailRow(
              icon: Icons.arrow_forward,
              label: 'Requested Value'.tr,
              value: _formatDate(newValue),
              isHighlighted: true,
            ),
            SizedBox(height: 16.h),
          ],

          // Request Date
          if (modification.createdAt != null) ...[
            Divider(color: AppColors.borderColor),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.schedule,
              label: 'Request Date'.tr,
              value: _formatDateTime(modification.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  /// Build Notes Section
  Widget _buildNotesSection(modification) {
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, size: 20.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                'Modification Notes'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            modification.note ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Action Buttons
  Widget _buildActionButtons(
    BuildContext context,
    OwnerReservationModificationDetailsController controller,
  ) {
    return Obx(() {
      final modification = controller.modification.value;
      if (modification == null || !modification.isPending()) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAcceptDialog(context, controller),
              icon: Icon(Icons.check, size: 24.sp),
              label: Text(
                'Accept Modification'.tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(context, controller),
              icon: Icon(Icons.close, size: 24.sp),
              label: Text(
                'Reject Modification'.tr,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red, width: 2),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Build Info Card Container
  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Build Detail Row
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: isHighlighted ? AppColors.success : AppColors.textSecondary,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isHighlighted
                      ? AppColors.success
                      : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get Modification Type Text
  String _getModificationTypeText(modification) {
    if (modification.requestedStartDate != null &&
        modification.requestedEndDate != null) {
      return 'Both Dates'.tr;
    } else if (modification.requestedStartDate != null) {
      return 'Check-in Date'.tr;
    } else if (modification.requestedEndDate != null) {
      return 'Check-out Date'.tr;
    }
    return modification.type ?? 'Unknown'.tr;
  }

  /// Get Old Value (Current Reservation Date)
  String? _getOldValue(modification, reservation) {
    if (reservation == null) return null;

    if (modification.requestedStartDate != null) {
      return reservation.startDate;
    } else if (modification.requestedEndDate != null) {
      return reservation.endDate;
    }
    return null;
  }

  /// Get New Value (Requested Date)
  String? _getNewValue(modification) {
    return modification.requestedStartDate ??
        modification.requestedEndDate ??
        modification.newValue;
  }

  /// Format Date
  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  /// Format DateTime
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Show Accept Dialog
  void _showAcceptDialog(
    BuildContext context,
    OwnerReservationModificationDetailsController controller,
  ) {
    Get.dialog(
      AcceptRejectDialogWidget(
        title: 'Accept Modification Request'.tr,
        message:
            'Are you sure you want to accept this modification request?'.tr,
        confirmText: 'Accept'.tr,
        cancelText: 'Cancel'.tr,
        isAccept: true,
        onConfirm: () async {
          Get.back();
          final success = await controller.acceptModification();
          if (success) {
            // Navigate back to modifications list and refresh
            Get.back(result: true); // Return true to indicate refresh needed
          }
        },
      ),
    );
  }

  /// Show Reject Dialog
  void _showRejectDialog(
    BuildContext context,
    OwnerReservationModificationDetailsController controller,
  ) {
    Get.dialog(
      AcceptRejectDialogWidget(
        title: 'Reject Modification Request'.tr,
        message:
            'Are you sure you want to reject this modification request?'.tr,
        confirmText: 'Reject'.tr,
        cancelText: 'Cancel'.tr,
        isAccept: false,
        onConfirm: () async {
          Get.back();
          final success = await controller.rejectModification();
          if (success) {
            // Navigate back to modifications list and refresh
            Get.back(result: true); // Return true to indicate refresh needed
          }
        },
      ),
    );
  }
}
