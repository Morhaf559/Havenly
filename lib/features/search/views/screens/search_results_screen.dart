import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/core/widgets/apartment_card_widget.dart';
import 'package:my_havenly_application/core/widgets/loading_widget.dart';
import 'package:my_havenly_application/core/widgets/empty_state_widget.dart';
import 'package:my_havenly_application/core/widgets/error_state_widget.dart';
import 'package:my_havenly_application/features/search/controllers/search_results_controller.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SearchResultsController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Search Results'.tr),
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.apartments.isEmpty) {
          return const LoadingWidget(message: 'Loading results...');
        }
        if (controller.errorMessage.value != null &&
            controller.apartments.isEmpty) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refresh(),
            retryText: 'Retry'.tr,
          );
        }
        if (controller.apartments.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.search_off,
            title: 'No Results Found'.tr,
            subtitle: 'Try adjusting your search or filters'.tr,
            actionButton: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text('Go Back'.tr),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.getSearchSummary(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${controller.total.value} ${controller.total.value == 1 ? 'result'.tr : 'results'.tr}',
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
                SizedBox(height: 16.h),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount:
                      controller.apartments.length +
                      (controller.hasMorePages.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.apartments.length) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!controller.isLoadingMore.value) {
                          controller.loadMoreApartments();
                        }
                      });
                      return const Center(child: CircularProgressIndicator());
                    }

                    final apartment = controller.apartments[index];
                    return ApartmentCardWidget(
                      apartment: apartment,
                      showFavoriteButton: true,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.apartmentDetails,
                          arguments: {
                            'apartmentId': apartment.id,
                            'showBookingButton': true,
                          },
                        );
                      },
                    );
                  },
                ),

                if (controller.hasMorePages.value &&
                    !controller.isLoadingMore.value) ...[
                  SizedBox(height: 16.h),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => controller.loadMoreApartments(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text('Load More'.tr),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
