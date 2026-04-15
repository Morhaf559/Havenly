import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_request_controller.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/reservation_request_card.dart';

class ReservationRequestListScreen extends StatelessWidget {
  const ReservationRequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReservationRequestController>();

    return Scaffold(
      appBar: AppBar(title: Text('My Reservation Requests'.tr)),
      body: Obx(() {
        if (controller.isLoading.value && controller.requests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value!,
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: Text('Retry'.tr),
                ),
              ],
            ),
          );
        }

        final filteredRequests = controller.filteredRequests;

        if (filteredRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'No reservation requests found',
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Container(
              height: 50.h,
              margin: EdgeInsets.symmetric(vertical: 8.h),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  _buildFilterChip(controller, 'all', 'All'),
                  _buildFilterChip(controller, 'pending', 'Pending'),
                  _buildFilterChip(controller, 'accepted', 'Accepted'),
                  _buildFilterChip(controller, 'rejected', 'Rejected'),
                  _buildFilterChip(controller, 'cancelled', 'Cancelled'),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index];
                    return ReservationRequestCard(
                      request: request,
                      onTap: () {
                        Get.snackbar(
                          'Details',
                          'Reservation request details screen (to be implemented)',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      onCancel: request.canBeCancelled()
                          ? () {
                              _showCancelDialog(
                                context,
                                controller,
                                request.id,
                              );
                            }
                          : null,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFilterChip(
    ReservationRequestController controller,
    String status,
    String label,
  ) {
    return Obx(() {
      final isSelected = controller.selectedStatus.value == status;
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            controller.setFilterStatus(status);
          },
        ),
      );
    });
  }

  void _showCancelDialog(
    BuildContext context,
    ReservationRequestController controller,
    int requestId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Reservation Request'.tr),
        content: Text(
          'Are you sure you want to cancel this reservation request?'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.cancelReservationRequest(
                requestId,
              );
              if (success) {
                Get.snackbar(
                  'Success'.tr,
                  'Reservation request cancelled'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: Text('Yes'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
