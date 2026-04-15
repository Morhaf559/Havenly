import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/apartments/controllers/apartment_details_controller.dart';
import 'package:my_havenly_application/features/apartments/views/widgets/apartment_image_gallery.dart';
import 'package:my_havenly_application/features/reviews/views/widgets/add_review_bottom_sheet.dart';
import 'package:my_havenly_application/features/reviews/views/widgets/rating_widget.dart';
import 'package:my_havenly_application/features/reviews/views/widgets/reviews_list_widget.dart';

/// Apartment Details Screen
/// Modern design with image gallery, overlay info, and detailed content card
class ApartmentDetailsScreen extends StatefulWidget {
  const ApartmentDetailsScreen({super.key});

  @override
  State<ApartmentDetailsScreen> createState() => _ApartmentDetailsScreenState();
}

class _ApartmentDetailsScreenState extends State<ApartmentDetailsScreen> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    // ApartmentDetailsController should be initialized via ApartmentsBinding
    final controller = Get.find<ApartmentDetailsController>();
    final reviewController = controller.reviewController;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        // Access observable variables to ensure proper tracking
        final isLoading = controller.isLoading.value;
        final apartment = controller.apartment.value;
        final photos = controller.photos;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (apartment == null) {
          return Center(
            child: Text(
              'Apartment not found'.tr,
              style: TextStyle(fontSize: 16.sp),
            ),
          );
        }

        final locale = Get.locale?.languageCode ?? 'ar';
        final title = apartment.getLocalizedTitle(locale) ?? 'No Title'.tr;
        final description = apartment.getLocalizedDescription(locale) ?? '';
        final address =
            apartment.getLocalizedAddress(locale) ?? apartment.city ?? '';

        // Get average rating
        final averageRating = reviewController.averageRating.value;

        return Stack(
          children: [
            // Scrollable content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery with overlay buttons
                  ApartmentImageGallery(
                    photos: photos,
                    apartmentId: apartment.id,
                  ),

                  // Info overlay bar on image - Only show if we have data
                  Obx(() {
                    final infoItems = <Widget>[];

                    // Floors (only if available)
                    if (apartment.floor != null && apartment.floor! > 0) {
                      infoItems.add(
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.layers,
                            label: '${apartment.floor} ${'Floors'.tr}',
                          ),
                        ),
                      );
                    }

                    // Rating (only show if user is NOT the owner)
                    if (!controller.isOwner.value) {
                      infoItems.add(
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.star,
                            label: averageRating > 0
                                ? '${averageRating.toStringAsFixed(1)} ${'Rating'.tr}'
                                : 'No Rating'.tr,
                          ),
                        ),
                      );
                    }

                    // Rooms or Area
                    if (apartment.numberOfRoom != null &&
                        apartment.numberOfRoom! > 0) {
                      infoItems.add(
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.bed,
                            label: '${apartment.numberOfRoom} ${'Rooms'.tr}',
                          ),
                        ),
                      );
                    } else if (apartment.area != null && apartment.area! > 0) {
                      infoItems.add(
                        Expanded(
                          child: _buildInfoItem(
                            icon: Icons.square_foot,
                            label: '${apartment.area} m²',
                          ),
                        ),
                      );
                    }

                    if (infoItems.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Transform.translate(
                      offset: Offset(0, -60.h),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF1E293B,
                          ).withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: infoItems,
                        ),
                      ),
                    );
                  }),

                  // White content card
                  Container(
                    margin: EdgeInsets.only(top: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and Location
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              // Location - Show address or city/governorate
                              if (address.isNotEmpty ||
                                  apartment.city != null ||
                                  apartment.governorate != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 18.sp,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        _buildLocationText(
                                          address: address,
                                          city: apartment.city,
                                          governorate: apartment.governorate,
                                        ),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          SizedBox(height: 24.h),

                          // Key Features Row - Only show available data
                          Builder(
                            builder: (context) {
                              final features = <Widget>[];

                              if (apartment.numberOfRoom != null &&
                                  apartment.numberOfRoom! > 0) {
                                features.add(
                                  Expanded(
                                    child: _buildFeatureItem(
                                      icon: Icons.bed,
                                      label:
                                          '${apartment.numberOfRoom} ${'Beds'.tr}',
                                    ),
                                  ),
                                );
                              }

                              if (apartment.numberOfBathroom != null &&
                                  apartment.numberOfBathroom! > 0) {
                                features.add(
                                  Expanded(
                                    child: _buildFeatureItem(
                                      icon: Icons.bathtub,
                                      label:
                                          '${apartment.numberOfBathroom} ${'Baths'.tr}',
                                    ),
                                  ),
                                );
                              }

                              if (apartment.area != null &&
                                  apartment.area! > 0) {
                                features.add(
                                  Expanded(
                                    child: _buildFeatureItem(
                                      icon: Icons.square_foot,
                                      label: '${apartment.area} m²',
                                    ),
                                  ),
                                );
                              }

                              if (apartment.floor != null &&
                                  apartment.floor! > 0) {
                                features.add(
                                  Expanded(
                                    child: _buildFeatureItem(
                                      icon: Icons.layers,
                                      label: '${'Floor'.tr} ${apartment.floor}',
                                    ),
                                  ),
                                );
                              }

                              if (features.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: features,
                              );
                            },
                          ),

                          SizedBox(height: 32.h),

                          // Details Section - Only show if description exists
                          if (description.isNotEmpty) ...[
                            Text(
                              'Details'.tr,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                              maxLines: _isDescriptionExpanded ? null : 3,
                              overflow: _isDescriptionExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                            if (description.length > 100)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDescriptionExpanded =
                                          !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Text(
                                    _isDescriptionExpanded
                                        ? 'Read less'.tr
                                        : 'Read more'.tr,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 24.h),
                            // View More Photos Button
                            if (photos.isNotEmpty)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Get.toNamed(
                                      AppRoutes.apartmentPhotosGallery,
                                      arguments: {
                                        'apartmentId': apartment.id,
                                        'photos': photos,
                                        'initialIndex': 0,
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.photo_library, size: 20.sp),
                                  label: Text(
                                    'View More Photos'.tr,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                      vertical: 14.h,
                                    ),
                                    backgroundColor: const Color(0xFF1E293B),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 32.h),
                          ],

                          // Reviews Section - Only show if user is NOT the owner
                          Obx(() {
                            // Hide reviews section if user is the owner
                            if (controller.isOwner.value) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reviews'.tr,
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            Obx(
                                              () => RatingWidget(
                                                rating: reviewController
                                                    .averageRating
                                                    .value,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Obx(
                                              () => Text(
                                                reviewController
                                                            .averageRating
                                                            .value >
                                                        0
                                                    ? reviewController
                                                          .averageRating
                                                          .value
                                                          .toStringAsFixed(1)
                                                    : 'No ratings'.tr,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        AddReviewBottomSheet.show(
                                          context: context,
                                          apartmentId: apartment.id,
                                          controller: reviewController,
                                        );
                                      },
                                      icon: Icon(Icons.add, size: 18.sp),
                                      label: Text(
                                        'Add Review'.tr,
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                // Reviews List
                                ReviewsListWidget(controller: reviewController),
                                SizedBox(height: 76.h),
                              ],
                            );
                          }),

                          // Bottom spacing for fixed button (only if booking button is shown)
                          Obx(
                            () => SizedBox(
                              height: controller.showBookingButton.value
                                  ? 100.h
                                  : 20.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Fixed bottom booking section (only show if showBookingButton is true)
            Obx(() {
              if (!controller.showBookingButton.value) {
                return const SizedBox.shrink();
              }

              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        // Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apartment.getFormattedPrice(),
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              Text(
                                '/${'Per Day'.tr}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Booking Button - Only enable if available
                        SizedBox(
                          width: 160.w,
                          child: ElevatedButton(
                            onPressed: apartment.isAvailable()
                                ? () {
                                    Get.toNamed(
                                      AppRoutes.createReservationRequest,
                                      arguments: apartment.id,
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: apartment.isAvailable()
                                  ? const Color(0xFF1E293B)
                                  : Colors.grey[400],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              disabledBackgroundColor: Colors.grey[400],
                              disabledForegroundColor: Colors.white,
                            ),
                            child: Text(
                              apartment.isAvailable()
                                  ? 'Booking Now'.tr
                                  : 'Not Available'.tr,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20.sp, color: Colors.white),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: Colors.grey[700]),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
        ),
      ],
    );
  }

  /// Build location text from available data
  String _buildLocationText({
    required String address,
    String? city,
    String? governorate,
  }) {
    final parts = <String>[];

    if (address.isNotEmpty) {
      parts.add(address);
    }
    if (city != null && city.isNotEmpty) {
      parts.add(city);
    }
    if (governorate != null && governorate.isNotEmpty) {
      parts.add(governorate);
    }

    return parts.join(', ');
  }
}
