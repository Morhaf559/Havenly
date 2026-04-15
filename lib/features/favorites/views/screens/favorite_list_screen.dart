import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/widgets/loading_widget.dart';
import 'package:my_havenly_application/core/widgets/empty_state_widget.dart';
import 'package:my_havenly_application/core/widgets/error_state_widget.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/favorites/controllers/favorite_controller.dart';
import 'package:my_havenly_application/features/main/controllers/main_navigation_controller.dart';
import 'package:my_havenly_application/features/profile/widgets/bottom_navigation_bar_widget.dart';

class FavoriteListScreen extends StatelessWidget {
  const FavoriteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();
    final navController = Get.find<MainNavigationController>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navController.navigateToTab('favorite');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.favorites.isEmpty) {
          return const LoadingWidget(message: 'Loading favorites...');
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
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: controller.favorites.length,
            itemBuilder: (context, index) {
              final apartment = controller.favorites[index];
              return _FavoriteApartmentCard(apartment: apartment);
            },
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBarWidget(
        controller: navController,
      ),
    );
  }
}

class _FavoriteApartmentCard extends StatelessWidget {
  final ApartmentModel apartment;

  const _FavoriteApartmentCard({required this.apartment});

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final title = apartment.getLocalizedTitle(locale) ?? 'No Title';

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.apartmentDetails, arguments: apartment.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (apartment.mainImage != null)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                ),
                child: Image.network(
                  apartment.mainImage!,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200.h,
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 48.sp),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200.h,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 48.sp),
              ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        apartment.city ?? 'Not specified'.tr,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '\$${apartment.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

