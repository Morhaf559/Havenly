import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../../core/widgets/apartment_card_widget.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../favorites/controllers/favorite_controller.dart';

class FavoriteContentWidget extends StatelessWidget {
  const FavoriteContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Favorite'.tr),
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.favorites.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: const ShimmerGrid(itemCount: 4),
          );
        }

        if (controller.errorMessage.value != null && controller.favorites.isEmpty) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: controller.refresh,
            retryText: 'Retry'.tr,
          );
        }

        if (controller.favorites.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.favorite_border,
            title: 'No favorite items'.tr,
            subtitle: 'Add your favorite apartments to see them here'.tr,
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
                    Text(
                      'Favorite Apartments'.tr,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                    ),
                    Text(
                      '${controller.favorites.length} ${controller.favorites.length == 1 ? 'item'.tr : 'items'.tr}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
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
                  itemCount: controller.favorites.length,
                  itemBuilder: (context, index) {
                    final apartment = controller.favorites[index];
                    return ApartmentCardWidget(
                      apartment: apartment,
                      showFavoriteButton: true,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
