import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_controller.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/reservation_card.dart';

class ReservationListScreen extends StatelessWidget {
  const ReservationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReservationController>();

    return Scaffold(
      appBar: AppBar(title: Text('Reservations'.tr)),
      body: Obx(() {
        if (controller.isLoading.value && controller.reservations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value != null &&
            controller.reservations.isEmpty) {
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

        final filteredReservations = controller.filteredReservations;

        if (filteredReservations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'No reservations found',
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
                  _buildFilterChip(controller, 'active', 'Active'),
                  _buildFilterChip(controller, 'completed', 'Completed'),
                  _buildFilterChip(controller, 'cancelled', 'Cancelled'),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.builder(
                  itemCount: filteredReservations.length,
                  itemBuilder: (context, index) {
                    final reservation = filteredReservations[index];
                    return ReservationCard(
                      reservation: reservation,
                      onTap: () {
                        Get.snackbar(
                          'Details',
                          'Reservation details screen (to be implemented)',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
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
    ReservationController controller,
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
}
