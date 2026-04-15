import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../controllers/owner_dashboard_controller.dart';
import '../widgets/statistics_card_widget.dart';
import '../widgets/quick_action_card_widget.dart';
import '../../../../features/main/controllers/main_navigation_controller.dart';
import '../../../../features/profile/widgets/bottom_navigation_bar_widget.dart';
import '../../../../core/controllers/auth_state_controller.dart';

/// Owner Dashboard Screen
/// Main dashboard for apartment owners
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OwnerDashboardController>();
    // MainNavigationController should be initialized via MainBinding
    final navController = Get.find<MainNavigationController>();

    // Update bottom nav bar index when screen is opened
    // Use navigateToTab for role-based navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navController.navigateToTab('dashboard');
      // Refresh dashboard data when screen is opened
      controller.refresh();
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Owner Dashboard'.tr),
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value &&
            controller.totalApartments.value == 0) {
          return const LoadingWidget(message: 'Loading dashboard...');
        }

        // Error State
        if (controller.errorMessage.value != null &&
            controller.totalApartments.value == 0) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refresh(),
          );
        }

        // Empty State (when no data at all)
        final hasNoData =
            controller.totalApartments.value == 0 &&
            controller.pendingRequests.value == 0 &&
            controller.activeReservations.value == 0 &&
            controller.pendingModifications.value == 0;

        if (hasNoData) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: EmptyStateWidget(
                  icon: Icons.dashboard_outlined,
                  title: 'No Data Available'.tr,
                  subtitle: 'Start by adding your first apartment'.tr,
                  actionButton: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Get.toNamed(AppRoutes.addApartment);
                      if (result == true) {
                        controller.refresh();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: Text('Add Apartment'.tr),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Content
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section with User Profile
                _buildWelcomeSection(controller),
                SizedBox(height: 24.h),

                // Statistics Section
                _buildStatisticsSection(controller),
                SizedBox(height: 24.h),

                // Quick Actions Section
                _buildQuickActionsSection(controller),
              ],
            ),
          ),
        );
      }),

      bottomNavigationBar: BottomNavigationBarWidget(controller: navController),
    );
  }

  /// Build Welcome Section with User Profile
  /// Uses AuthStateController (reuses existing logic)
  Widget _buildWelcomeSection(OwnerDashboardController controller) {
    return GetBuilder<AuthStateController>(
      builder: (authController) {
        final user = authController.user;
        final userName = user?.fullName ?? 'Owner'.tr;
        // UserModel uses personalPhoto property
        final userImage = user?.personalPhoto?.url ?? '';

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryNavy.withOpacity(0.1),
                AppColors.primaryNavy.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primaryNavy.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Profile Image
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryNavy, width: 2),
                  image: userImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(userImage),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            // Handle image load error
                          },
                        )
                      : null,
                ),
                child: userImage.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 30.sp,
                        color: AppColors.primaryNavy,
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              // Welcome Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Manage your properties and reservations'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build Statistics Section
  Widget _buildStatisticsSection(OwnerDashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistics'.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: 16.h),
        // Statistics Grid
        Row(
          children: [
            Expanded(
              child: StatisticsCardWidget(
                icon: Icons.home_work,
                value: controller.totalApartments.value,
                label: 'Apartments'.tr,
                iconColor: AppColors.primaryNavy,
                onTap: () {
                  Get.toNamed(AppRoutes.ownerPropertiesList);
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: StatisticsCardWidget(
                icon: Icons.pending_actions,
                value: controller.pendingRequests.value,
                label: 'Pending Requests'.tr,
                iconColor: Colors.orange,
                onTap: () {
                  Get.toNamed(AppRoutes.ownerReservationRequests);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: StatisticsCardWidget(
                icon: Icons.check_circle,
                value: controller.activeReservations.value,
                label: 'Active Reservations'.tr,
                iconColor: AppColors.success,
                onTap: () {
                  Get.toNamed(AppRoutes.ownerActiveReservations);
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: StatisticsCardWidget(
                icon: Icons.edit,
                value: controller.pendingModifications.value,
                label: 'Modifications'.tr,
                iconColor: AppColors.info,
                onTap: () {
                  Get.toNamed(AppRoutes.ownerReservationModifications);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Quick Actions Section
  Widget _buildQuickActionsSection(OwnerDashboardController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions'.tr,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: 16.h),
        QuickActionCardWidget(
          icon: Icons.add_circle_outline,
          title: 'Add New Apartment'.tr,
          subtitle: 'Create a new property listing'.tr,
          iconColor: AppColors.success,
          onTap: () async {
            final result = await Get.toNamed(AppRoutes.addApartment);
            if (result == true) {
              controller.refresh();
            }
          },
        ),
        SizedBox(height: 12.h),
        QuickActionCardWidget(
          icon: Icons.home_work_outlined,
          title: 'View All My Properties'.tr,
          subtitle: 'Manage your apartments'.tr,
          iconColor: AppColors.primaryNavy,
          onTap: () {
            Get.toNamed(AppRoutes.ownerPropertiesList);
          },
        ),
        SizedBox(height: 12.h),
        QuickActionCardWidget(
          icon: Icons.inbox_outlined,
          title: 'View Reservation Requests'.tr,
          subtitle: 'Pending requests: ${controller.pendingRequests.value}'.tr,
          iconColor: Colors.orange,
          onTap: () {
            Get.toNamed(AppRoutes.ownerReservationRequests);
          },
        ),
        SizedBox(height: 12.h),
        QuickActionCardWidget(
          icon: Icons.check_circle_outline,
          title: 'View Active Reservations'.tr,
          subtitle: 'Active: ${controller.activeReservations.value}'.tr,
          iconColor: AppColors.success,
          onTap: () {
            Get.toNamed(AppRoutes.ownerActiveReservations);
          },
        ),
        SizedBox(height: 12.h),
        QuickActionCardWidget(
          icon: Icons.edit_note,
          title: 'View Modifications'.tr,
          subtitle: 'Pending: ${controller.pendingModifications.value}'.tr,
          iconColor: AppColors.info,
          onTap: () {
            Get.toNamed(AppRoutes.ownerReservationModifications);
          },
        ),
      ],
    );
  }
}
