import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../reservations/views/widgets/reservation_status_badge.dart';
import '../../controllers/owner_reservation_request_details_controller.dart';
import '../widgets/accept_reject_dialog_widget.dart';

/// Owner Reservation Request Details Screen
/// Displays comprehensive details of a reservation request
class OwnerReservationRequestDetailsScreen extends StatelessWidget {
  final int requestId;

  const OwnerReservationRequestDetailsScreen({
    super.key,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    // OwnerReservationRequestDetailsController should be initialized via OwnerBinding
    final controller = Get.put(
      OwnerReservationRequestDetailsController(requestId: requestId),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Reservation Request Details'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value && controller.request.value == null) {
          return const LoadingWidget(message: 'Loading reservation request details...');
        }

        // Error State
        if (controller.errorMessage.value != null && controller.request.value == null) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refresh(),
          );
        }

        final request = controller.request.value;
        if (request == null) {
          return Center(
            child: Text(
              'Reservation request not found'.tr,
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          );
        }

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
                  child: ReservationStatusBadge(status: request.status),
                ),
                SizedBox(height: 24.h),

                // Apartment Information Section
                _buildSectionTitle('Apartment Information'.tr),
                SizedBox(height: 12.h),
                _buildApartmentInfo(request, controller),
                SizedBox(height: 24.h),

                // Guest Information Section
                _buildSectionTitle('Guest Information'.tr),
                SizedBox(height: 12.h),
                _buildGuestInfo(request),
                SizedBox(height: 24.h),

                // Reservation Details Section
                _buildSectionTitle('Reservation Details'.tr),
                SizedBox(height: 12.h),
                _buildReservationDetails(request, controller),
                SizedBox(height: 24.h),

                // Notes Section (if exists)
                if (request.note != null && request.note!.isNotEmpty) ...[
                  _buildSectionTitle('Notes'.tr),
                  SizedBox(height: 12.h),
                  _buildNotesSection(request),
                  SizedBox(height: 24.h),
                ],

                // Action Buttons (only if pending)
                if (request.isPending()) ...[
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

  /// Build Apartment Information Card
  Widget _buildApartmentInfo(
    request,
    OwnerReservationRequestDetailsController controller,
  ) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final apartment = request.apartment;
    if (apartment == null) {
      return _buildInfoCard(
        child: Text(
          'Apartment information not available'.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
      );
    }

    final title = apartment.getLocalizedTitle(locale) ?? 'No Title'.tr;
    final address = apartment.getLocalizedAddress(locale) ?? apartment.city ?? '';
    final mainImage = apartment.mainImage ?? '';

    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Apartment Image
          if (mainImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                mainImage,
                width: double.infinity,
                height: 200.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200.h,
                  color: AppColors.grey300,
                  child: Icon(Icons.home, size: 50.sp, color: AppColors.grey600),
                ),
              ),
            ),
          if (mainImage.isNotEmpty) SizedBox(height: 16.h),

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
              Icon(Icons.location_on, size: 18.sp, color: AppColors.textSecondary),
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

          // Apartment Features
          Row(
            children: [
              if (apartment.numberOfRoom != null) ...[
                _buildFeatureChip(
                  icon: Icons.bed,
                  label: '${apartment.numberOfRoom} ${'Rooms'.tr}',
                ),
                SizedBox(width: 8.w),
              ],
              if (apartment.numberOfBathroom != null) ...[
                _buildFeatureChip(
                  icon: Icons.bathtub,
                  label: '${apartment.numberOfBathroom} ${'Baths'.tr}',
                ),
                SizedBox(width: 8.w),
              ],
              if (apartment.area != null) ...[
                _buildFeatureChip(
                  icon: Icons.square_foot,
                  label: '${apartment.area} ${'sqft'.tr}',
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),

          // View Apartment Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.apartmentDetails,
                  arguments: {
                    'apartmentId': apartment.id,
                    'showBookingButton': false, // Hide booking button from Owner Dashboard
                  },
                );
              },
              icon: Icon(Icons.visibility, size: 18.sp),
              label: Text('View Apartment Details'.tr),
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

  /// Build Guest Information Card
  Widget _buildGuestInfo(request) {
    final userId = request.userId;
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 24.sp,
                  color: AppColors.primaryNavy,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userId != null ? 'Guest #$userId'.tr : 'Guest Information'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'User ID: ${userId ?? 'N/A'}'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Reservation Details Card
  Widget _buildReservationDetails(
    request,
    OwnerReservationRequestDetailsController controller,
  ) {
    final days = controller.calculateDays();
    final totalPrice = controller.calculateTotalPrice();
    final apartment = request.apartment;
    
    // Use total_amount from backend if available, otherwise use calculated price
    final displayTotalPrice = request.totalAmount ?? totalPrice;
    final currency = apartment?.currency ?? '\$';

    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dates
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Check-in Date'.tr,
            value: _formatDate(request.startDate),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Check-out Date'.tr,
            value: _formatDate(request.endDate),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.access_time,
            label: 'Duration'.tr,
            value: days > 0 ? '$days ${days == 1 ? 'day' : 'days'}'.tr : 'N/A'.tr,
          ),
          if (apartment != null) ...[
            SizedBox(height: 16.h),
            Divider(color: AppColors.borderColor),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.attach_money,
              label: 'Daily Price'.tr,
              value: '${apartment.price} $currency/day',
            ),
            if (displayTotalPrice != null && displayTotalPrice > 0) ...[
              SizedBox(height: 12.h),
              _buildDetailRow(
                icon: Icons.calculate,
                label: 'Total Amount'.tr,
                value: '${displayTotalPrice.toStringAsFixed(2)} $currency',
                isHighlighted: true,
              ),
            ] else if (days > 0 && apartment.price > 0) ...[
              // Fallback: calculate if total_amount is not available
              SizedBox(height: 12.h),
              _buildDetailRow(
                icon: Icons.calculate,
                label: 'Total Amount'.tr,
                value: '${(apartment.price * days).toStringAsFixed(2)} $currency',
                isHighlighted: true,
              ),
            ],
          ],
          if (request.createdAt != null) ...[
            SizedBox(height: 16.h),
            Divider(color: AppColors.borderColor),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.schedule,
              label: 'Request Date'.tr,
              value: _formatDateTime(request.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  /// Build Notes Section
  Widget _buildNotesSection(request) {
    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, size: 20.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                'Guest Notes'.tr,
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
            request.note ?? '',
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
  Widget _buildActionButtons(BuildContext context, OwnerReservationRequestDetailsController controller) {
    return Obx(() {
      final request = controller.request.value;
      if (request == null || !request.isPending()) {
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
                'Accept Request'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
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
                'Reject Request'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
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
        Icon(icon, size: 20.sp, color: AppColors.textSecondary),
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
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                  color: isHighlighted ? AppColors.primaryNavy : AppColors.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build Feature Chip
  Widget _buildFeatureChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppColors.primaryNavy),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
    BuildContext? context,
    OwnerReservationRequestDetailsController controller,
  ) {
    Get.dialog(
      AcceptRejectDialogWidget(
        title: 'Accept Reservation Request'.tr,
        message: 'Are you sure you want to accept this reservation request?'.tr,
        confirmText: 'Accept'.tr,
        cancelText: 'Cancel'.tr,
        isAccept: true,
        onConfirm: () async {
          Get.back();
          final success = await controller.acceptRequest();
          if (success) {
            // Navigate back to requests list and refresh
            Get.back(result: true); // Return true to indicate refresh needed
          }
        },
      ),
    );
  }

  /// Show Reject Dialog
  void _showRejectDialog(
    BuildContext? context,
    OwnerReservationRequestDetailsController controller,
  ) {
    Get.dialog(
      AcceptRejectDialogWidget(
        title: 'Reject Reservation Request'.tr,
        message: 'Are you sure you want to reject this reservation request?'.tr,
        confirmText: 'Reject'.tr,
        cancelText: 'Cancel'.tr,
        isAccept: false,
        onConfirm: () async {
          Get.back();
          final success = await controller.rejectRequest();
          if (success) {
            // Navigate back to requests list and refresh
            Get.back(result: true); // Return true to indicate refresh needed
          }
        },
      ),
    );
  }
}

