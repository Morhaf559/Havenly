import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/core/widgets/error_state_widget.dart';
import 'package:my_havenly_application/core/widgets/empty_state_widget.dart';
import 'package:my_havenly_application/core/widgets/shimmer_widgets.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_request_controller.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_controller.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/reservation_request_card.dart';
import 'package:my_havenly_application/features/reservations/views/widgets/reservation_card.dart';

class ReservationsContentWidget extends StatefulWidget {
  const ReservationsContentWidget({super.key});

  @override
  State<ReservationsContentWidget> createState() => _ReservationsContentWidgetState();
}

class _ReservationsContentWidgetState extends State<ReservationsContentWidget> 
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late ReservationRequestController _requestController;
  late ReservationController _reservationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _requestController = Get.find<ReservationRequestController>();
    _reservationController = Get.find<ReservationController>();
    
    WidgetsBinding.instance.addObserver(this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForCurrentTab();
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadDataForCurrentTab();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadDataForCurrentTab();
    }
  }

  void _loadDataForCurrentTab() {
    if (_tabController.index == 0) {
      _requestController.fetchSentReservationRequests();
    } else if (_tabController.index == 1) {
      _reservationController.fetchMyReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('My Reservations'.tr),
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Reservation Requests'.tr),
            Tab(text: 'Reservations'.tr),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReservationRequestsTab(),
          _buildReservationsTab(),
        ],
      ),
    );
  }

  Widget _buildReservationRequestsTab() {
    return Obx(() {
      final controller = _requestController;

      if (controller.isLoading.value && controller.requests.isEmpty) {
        return const ShimmerList();
      }

      if (controller.errorMessage.value != null && controller.requests.isEmpty) {
        return ErrorStateWidget(
          message: controller.errorMessage.value!,
          onRetry: () => controller.refresh(),
        );
      }

      if (controller.requests.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: EmptyStateWidget(
                icon: Icons.event_note_outlined,
                title: 'No Reservation Requests'.tr,
                subtitle: 'You don\'t have any reservation requests yet'.tr,
              ),
            ),
          ),
        );
      }

      // Content
      return Column(
        children: [
          // Filter Tabs
          Container(
            height: 50.h,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _buildRequestFilterChip(controller, 'all', 'All'.tr),
                _buildRequestFilterChip(controller, 'pending', 'Pending'.tr),
                _buildRequestFilterChip(controller, 'accepted', 'Accepted'.tr),
                _buildRequestFilterChip(controller, 'rejected', 'Rejected'.tr),
                _buildRequestFilterChip(controller, 'cancelled', 'Cancelled'.tr),
              ],
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = controller.filteredRequests[index];
                  return ReservationRequestCard(
                    request: request,
                    onTap: () async {
                      await Get.toNamed(
                        AppRoutes.reservationRequestDetails.replaceAll(':id', request.id.toString()),
                        parameters: {'id': request.id.toString()},
                      );
                      controller.fetchSentReservationRequests();
                    },
                    onCancel: request.canBeCancelled()
                        ? () {
                            _showCancelDialog(context, controller, request.id);
                          }
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildReservationsTab() {
    return Obx(() {
      final controller = _reservationController;

      if (controller.isLoading.value && controller.reservations.isEmpty) {
        return const ShimmerList();
      }

      if (controller.errorMessage.value != null && controller.reservations.isEmpty) {
        return ErrorStateWidget(
          message: controller.errorMessage.value!,
          onRetry: () => controller.refresh(),
        );
      }

      if (controller.reservations.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: EmptyStateWidget(
                icon: Icons.event_available_outlined,
                title: 'No Reservations'.tr,
                subtitle: 'You don\'t have any reservations yet'.tr,
              ),
            ),
          ),
        );
      }

      // Content
      return Column(
        children: [
          // Filter Tabs
          Container(
            height: 50.h,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _buildReservationFilterChip(controller, 'all', 'All'.tr),
                _buildReservationFilterChip(controller, 'active', 'Active'.tr),
                _buildReservationFilterChip(controller, 'completed', 'Completed'.tr),
                _buildReservationFilterChip(controller, 'cancelled', 'Cancelled'.tr),
              ],
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.filteredReservations.length,
                itemBuilder: (context, index) {
                  final reservation = controller.filteredReservations[index];
                  return ReservationCard(
                    reservation: reservation,
                    onTap: () async {
                      await Get.toNamed(
                        AppRoutes.reservationDetails.replaceAll(':id', reservation.id.toString()),
                        parameters: {'id': reservation.id.toString()},
                      );
                      controller.fetchMyReservations();
                    },
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildRequestFilterChip(
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
          selectedColor: AppColors.primaryNavy.withOpacity(0.2),
          checkmarkColor: AppColors.primaryNavy,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primaryNavy : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    });
  }

  Widget _buildReservationFilterChip(
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
            controller.fetchMyReservations();
          },
          selectedColor: AppColors.primaryNavy.withOpacity(0.2),
          checkmarkColor: AppColors.primaryNavy,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.primaryNavy : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
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
        content: Text('Are you sure you want to cancel this reservation request?'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.cancelReservationRequest(requestId);
              if (success) {
                Get.snackbar(
                  'Success'.tr,
                  'Reservation request cancelled'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                controller.fetchSentReservationRequests();
              }
            },
            child: Text('Yes'.tr, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
