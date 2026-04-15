import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../controllers/owner_active_reservations_controller.dart';
import '../widgets/owner_reservation_card_widget.dart';

/// Owner Active Reservations Screen
/// Displays active reservations for owner's apartments with filter
class OwnerActiveReservationsScreen extends StatelessWidget {
  const OwnerActiveReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // OwnerActiveReservationsController should be initialized via OwnerBinding
    final controller = Get.find<OwnerActiveReservationsController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Active Reservations'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value && controller.reservations.isEmpty) {
          return const LoadingWidget(message: 'Loading reservations...');
        }

        // Error State
        if (controller.errorMessage.value != null && controller.reservations.isEmpty) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refresh(),
          );
        }

        // Content
        return Column(
          children: [
            // Filter Chips
            _buildFilterChips(controller),

            // List
            Expanded(
              child: Obx(() {
                final filteredReservations = controller.reservations;

                if (filteredReservations.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.calendar_month_outlined,
                    title: 'No Reservations'.tr,
                    subtitle: 'No reservations found for your apartments'.tr,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 16.h),
                    itemCount: filteredReservations.length,
                    itemBuilder: (context, index) {
                      final reservation = filteredReservations[index];
                      return OwnerReservationCardWidget(
                        reservation: reservation,
                        onTap: () async {
                          if (reservation.id <= 0) {
                            Get.snackbar(
                              'Error'.tr,
                              'Invalid reservation ID'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          final result = await Get.toNamed(
                            AppRoutes.ownerReservationDetails.replaceAll(':id', reservation.id.toString()),
                            parameters: {'id': reservation.id.toString()},
                          );
                          // Refresh list when returning from details screen
                          // if result is true (reservation was updated)
                          if (result == true) {
                            controller.refresh();
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        );
      }),
    );
  }

  /// Build Filter Chips
  Widget _buildFilterChips(OwnerActiveReservationsController controller) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 8.h, top: 8.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildFilterChip(controller, 'all', 'All'.tr),
          SizedBox(width: 8.w),
          _buildFilterChip(controller, 'active', 'Active'.tr),
          SizedBox(width: 8.w),
          _buildFilterChip(controller, 'completed', 'Completed'.tr),
          SizedBox(width: 8.w),
          _buildFilterChip(controller, 'cancelled', 'Cancelled'.tr),
        ],
      ),
    );
  }

  /// Build Filter Chip
  Widget _buildFilterChip(
    OwnerActiveReservationsController controller,
    String status,
    String label,
  ) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == status;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          controller.setFilterStatus(status);
        },
        selectedColor: AppColors.primaryNavy.withOpacity(0.2),
        checkmarkColor: AppColors.primaryNavy,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryNavy : AppColors.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14.sp,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryNavy : AppColors.borderColor,
          width: isSelected ? 2 : 1,
        ),
      );
    });
  }
}

