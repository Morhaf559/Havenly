import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../reservations/views/widgets/reservation_status_badge.dart';
import '../../controllers/owner_reservation_details_controller.dart';
import '../widgets/modify_reservation_bottom_sheet_owner.dart';

/// Owner Reservation Details Screen
/// Displays comprehensive details of a reservation for owner
class OwnerReservationDetailsScreen extends StatelessWidget {
  final int reservationId;

  const OwnerReservationDetailsScreen({
    super.key,
    required this.reservationId,
  });

  @override
  Widget build(BuildContext context) {
    // OwnerReservationDetailsController should be initialized via OwnerBinding
    final controller = Get.put(
      OwnerReservationDetailsController(reservationId: reservationId),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Reservation Details'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value && controller.reservation.value == null) {
          return const LoadingWidget(message: 'Loading reservation details...');
        }

        // Error State
        if (controller.errorMessage.value != null && controller.reservation.value == null) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refresh(),
          );
        }

        final reservation = controller.reservation.value;
        if (reservation == null) {
          return Center(
            child: Text(
              'Reservation not found'.tr,
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
                  child: ReservationStatusBadge(status: reservation.status),
                ),
                SizedBox(height: 24.h),

                // Apartment Information Section
                _buildSectionTitle('Apartment Information'.tr),
                SizedBox(height: 12.h),
                _buildApartmentInfo(reservation, controller),
                SizedBox(height: 24.h),

                // Guest Information Section
                _buildSectionTitle('Guest Information'.tr),
                SizedBox(height: 12.h),
                _buildGuestInfo(reservation),
                SizedBox(height: 24.h),

                // Reservation Details Section
                _buildSectionTitle('Reservation Details'.tr),
                SizedBox(height: 12.h),
                _buildReservationDetails(reservation, controller),
                SizedBox(height: 24.h),

                // Action Buttons (only if active and not ended)
                if (controller.canRequestModification()) ...[
                  _buildActionButtons(context, controller, reservation),
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
    reservation,
    OwnerReservationDetailsController controller,
  ) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final apartment = reservation.apartment;
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
  Widget _buildGuestInfo(reservation) {
    final userId = reservation.userId;
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
    reservation,
    OwnerReservationDetailsController controller,
  ) {
    final days = controller.calculateDays();
    final totalPrice = controller.calculateTotalPrice();
    final apartment = reservation.apartment;

    return _buildInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dates
          _buildDetailRow(
            icon: Icons.calendar_today,
            label: 'Check-in Date'.tr,
            value: _formatDate(reservation.startDate),
          ),
          SizedBox(height: 12.h),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Check-out Date'.tr,
            value: _formatDate(reservation.endDate),
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
              value: '${apartment.price} ${apartment.currency ?? '\$'}/day',
            ),
            if (totalPrice != null) ...[
              SizedBox(height: 12.h),
              _buildDetailRow(
                icon: Icons.calculate,
                label: 'Total Amount'.tr,
                value: '${totalPrice.toStringAsFixed(2)} ${apartment.currency ?? '\$'}',
                isHighlighted: true,
              ),
            ],
          ],
          if (reservation.createdAt != null) ...[
            SizedBox(height: 16.h),
            Divider(color: AppColors.borderColor),
            SizedBox(height: 12.h),
            _buildDetailRow(
              icon: Icons.schedule,
              label: 'Reservation Date'.tr,
              value: _formatDateTime(reservation.createdAt!),
            ),
          ],
        ],
      ),
    );
  }

  /// Build Action Buttons
  Widget _buildActionButtons(
    BuildContext context,
    OwnerReservationDetailsController controller,
    reservation,
  ) {
    return Obx(() {
      if (!controller.canRequestModification()) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showModifyDialog(context, controller, reservation),
              icon: Icon(Icons.edit, size: 24.sp),
              label: Text(
                'Request Modification'.tr,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
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

  /// Show Modify Dialog
  void _showModifyDialog(
    BuildContext context,
    OwnerReservationDetailsController controller,
    reservation,
  ) {
    ModifyReservationBottomSheetOwner.show(
      context,
      controller: controller,
      currentStartDate: DateTime.parse(reservation.startDate),
      currentEndDate: DateTime.parse(reservation.endDate),
    );
  }
}
