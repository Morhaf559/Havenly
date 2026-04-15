import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../controllers/owner_reservation_requests_controller.dart';
import '../widgets/owner_reservation_request_card_widget.dart';
import '../widgets/accept_reject_dialog_widget.dart';

/// Owner Reservation Requests Screen
/// Displays reservation requests for owner's apartments with filter and search
class OwnerReservationRequestsScreen extends StatelessWidget {
  const OwnerReservationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if apartmentId filter is passed as argument
    final int? apartmentIdFilter = Get.arguments as int?;
    
    // OwnerReservationRequestsController should be initialized via OwnerBinding
    final controller = Get.find<OwnerReservationRequestsController>();
    
    // Apply apartment filter if provided
    if (apartmentIdFilter != null) {
      controller.setApartmentFilter(apartmentIdFilter);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Reservation Requests'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value && controller.requests.isEmpty) {
          return const LoadingWidget(message: 'Loading reservation requests...');
        }

        // Error State
        if (controller.errorMessage.value != null && controller.requests.isEmpty) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refresh(),
          );
        }

        // Content
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: _buildSearchBar(controller),
            ),

            // Filter Chips
            _buildFilterChips(controller),

            // List
            Expanded(
              child: Obx(() {
                final filteredRequests = controller.requests;

                if (filteredRequests.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.inbox_outlined,
                    title: 'No Reservation Requests'.tr,
                    subtitle: 'No reservation requests found for your apartments'.tr,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 16.h),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = filteredRequests[index];
                      return OwnerReservationRequestCardWidget(
                        request: request,
                        onTap: () async {
                          if (request.id <= 0) {
                            Get.snackbar(
                              'Error'.tr,
                              'Invalid request ID'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }
                          final result = await Get.toNamed(
                            AppRoutes.ownerReservationRequestDetails.replaceAll(':id', request.id.toString()),
                            parameters: {'id': request.id.toString()},
                          );
                          // Refresh list when returning from details screen
                          // if result is true (request was accepted/rejected)
                          if (result == true) {
                            controller.refresh();
                          }
                        },
                        onAccept: request.isPending()
                            ? () => _showAcceptDialog(context, controller, request.id)
                            : null,
                        onReject: request.isPending()
                            ? () => _showRejectDialog(context, controller, request.id)
                            : null,
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

  /// Build Search Bar
  Widget _buildSearchBar(OwnerReservationRequestsController controller) {
    // TODO: Implement search functionality if needed
    return Container(
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
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search requests...'.tr,
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 24.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }

  /// Build Filter Chips
  Widget _buildFilterChips(OwnerReservationRequestsController controller) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildFilterChip(controller, 'all', 'All'.tr),
          SizedBox(width: 8.w),
          _buildFilterChip(controller, 'pending', 'Pending'.tr),
          SizedBox(width: 8.w),
          _buildFilterChip(controller, 'accepted', 'Accepted'.tr),
          SizedBox(width: 8.w),
          _buildFilterChip(controller, 'rejected', 'Rejected'.tr),
          SizedBox(width: 8.w),
          _buildFilterChip(controller, 'cancelled', 'Cancelled'.tr),
        ],
      ),
    );
  }

  /// Build Filter Chip
  Widget _buildFilterChip(
    OwnerReservationRequestsController controller,
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

  /// Show Accept Confirmation Dialog
  void _showAcceptDialog(
    BuildContext context,
    OwnerReservationRequestsController controller,
    int requestId,
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
          final success = await controller.acceptRequest(requestId);
          if (!success) {
            // Error message is already shown in controller
          }
        },
      ),
    );
  }

  /// Show Reject Confirmation Dialog
  void _showRejectDialog(
    BuildContext context,
    OwnerReservationRequestsController controller,
    int requestId,
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
          final success = await controller.rejectRequest(requestId);
          if (!success) {
            // Error message is already shown in controller
          }
        },
      ),
    );
  }
}

