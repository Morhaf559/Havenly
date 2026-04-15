import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../controllers/owner_properties_controller.dart';
import '../widgets/owner_property_card_widget.dart';

/// Owner Properties List Screen
/// Displays all apartments owned by the current user
class OwnerPropertiesListScreen extends StatelessWidget {
  const OwnerPropertiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OwnerPropertiesController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('My Properties'.tr),
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoadingProperties.value && controller.properties.isEmpty) {
          return const LoadingWidget(message: 'Loading properties...');
        }

        // Error state
        if (controller.propertiesErrorMessage.value.isNotEmpty && controller.properties.isEmpty) {
          return ErrorStateWidget(
            message: controller.propertiesErrorMessage.value,
            onRetry: () => controller.refresh(),
          );
        }

        // Empty state
        if (controller.properties.isEmpty && !controller.isLoadingProperties.value) {
          return Stack(
            children: [
              EmptyStateWidget(
                icon: Icons.home_outlined,
                title: 'No properties yet'.tr,
                subtitle: 'Add your first property to get started'.tr,
                actionButton: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Get.toNamed(AppRoutes.addApartment);
                    if (result == true) {
                      controller.refresh();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text('Add Property'.tr),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                ),
              ),
              // Add Button (Floating)
              Positioned(
                bottom: 16.h,
                right: 16.w,
                child: FloatingActionButton(
                  onPressed: () async {
                    final result = await Get.toNamed(AppRoutes.addApartment);
                    if (result == true) {
                      controller.refresh();
                    }
                  },
                  backgroundColor: AppColors.primaryNavy,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          );
        }

        // Properties list
        return Stack(
          children: [
            // Properties List
            RefreshIndicator(
              onRefresh: () => controller.refresh(),
              child: ListView.builder(
                padding: EdgeInsets.all(16.w).copyWith(bottom: 80.h),
                itemCount: controller.properties.length,
                itemBuilder: (context, index) {
                  final property = controller.properties[index];
                  return OwnerPropertyCardWidget(
                    property: property,
                    controller: controller,
                  );
                },
              ),
            ),
            // Add Button
            Positioned(
              bottom: 16.h,
              right: 16.w,
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Get.toNamed(AppRoutes.addApartment);
                  if (result == true) {
                    controller.refresh();
                  }
                },
                backgroundColor: AppColors.primaryNavy,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      }),
    );
  }
}

