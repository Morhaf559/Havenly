import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';

class AvailableApartmentCard extends StatelessWidget {
  final ApartmentModel apartment;
  final String locale;

  const AvailableApartmentCard({
    super.key,
    required this.apartment,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final title = apartment.getLocalizedTitle(locale) ?? 'Apartment ${apartment.id}';
    final location = _getLocationString(apartment);

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.apartmentDetails, arguments: apartment.id);
      },
      child: Container(
        width: 200.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Container(
                height: 120.h,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: apartment.mainImage != null && apartment.mainImage!.isNotEmpty
                    ? Image.network(
                        apartment.mainImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.home,
                              size: 40.sp,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Icon(
                          Icons.home,
                          size: 40.sp,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '\$${apartment.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
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

  String _getLocationString(ApartmentModel apartment) {
    final parts = <String>[];
    if (apartment.city != null && apartment.city!.isNotEmpty) {
      parts.add(apartment.city!);
    }
    if (apartment.governorate != null && apartment.governorate!.isNotEmpty) {
      parts.add(apartment.governorate!);
    }
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location'.tr;
  }
}
