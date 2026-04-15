import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../controllers/owner_reservation_modifications_controller.dart';
import '../widgets/owner_modification_request_card_widget.dart';
import '../widgets/accept_reject_dialog_widget.dart';

/// Owner Reservation Modifications Screen
/// Displays reservation modification requests for owner's apartments with filter
class OwnerReservationModificationsScreen extends StatelessWidget {
  const OwnerReservationModificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // OwnerReservationModificationsController should be initialized via OwnerBinding
    final controller = Get.find<OwnerReservationModificationsController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Reservation Modifications'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value && controller.modifications.isEmpty) {
          return const LoadingWidget(message: 'Loading modification requests...');
        }

        // Error State
        if (controller.errorMessage.value != null && controller.modifications.isEmpty) {
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
                final filteredModifications = controller.modifications;

                if (filteredModifications.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.edit_note_outlined,
                    title: 'No Modification Requests'.tr,
                    subtitle: 'No modification requests found for your apartments'.tr,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 16.h),
                    itemCount: filteredModifications.length,
                    itemBuilder: (context, index) {
                      final modification = filteredModifications[index];
                      final reservation = controller.getReservationForModification(modification);
                      
                      return OwnerModificationRequestCardWidget(
                        modification: modification,
                        reservation: reservation,
                        onAccept: modification.isPending()
                            ? () => _showAcceptDialog(context, controller, modification.id)
                            : null,
                        onReject: modification.isPending()
                            ? () => _showRejectDialog(context, controller, modification.id)
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

  /// Build Filter Chips
  Widget _buildFilterChips(OwnerReservationModificationsController controller) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 8.h, top: 8.h),
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
        ],
      ),
    );
  }

  /// Build Filter Chip
  Widget _buildFilterChip(
    OwnerReservationModificationsController controller,
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
    OwnerReservationModificationsController controller,
    int modificationId,
  ) {
    Get.dialog(
      AcceptRejectDialogWidget(
        title: 'Accept Modification Request'.tr,
        message: 'Are you sure you want to accept this modification request?'.tr,
        confirmText: 'Accept'.tr,
        cancelText: 'Cancel'.tr,
        isAccept: true,
        onConfirm: () async {
          Get.back();
          final success = await controller.acceptModification(modificationId);
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
    OwnerReservationModificationsController controller,
    int modificationId,
  ) {
    Get.dialog(
      AcceptRejectDialogWidget(
        title: 'Reject Modification Request'.tr,
        message: 'Are you sure you want to reject this modification request?'.tr,
        confirmText: 'Reject'.tr,
        cancelText: 'Cancel'.tr,
        isAccept: false,
        onConfirm: () async {
          Get.back();
          final success = await controller.rejectModification(modificationId);
          if (!success) {
            // Error message is already shown in controller
          }
        },
      ),
    );
  }
}

