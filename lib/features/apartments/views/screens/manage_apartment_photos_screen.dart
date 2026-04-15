import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../controllers/manage_apartment_photos_controller.dart';
import '../widgets/photo_action_sheet_widget.dart';

/// Manage Apartment Photos Screen
/// Allows users to view, upload, delete, and set main photo for an apartment
class ManageApartmentPhotosScreen extends StatelessWidget {
  final int apartmentId;

  const ManageApartmentPhotosScreen({
    super.key,
    required this.apartmentId,
  });

  @override
  Widget build(BuildContext context) {
    // Validate apartment ID
    if (apartmentId <= 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Manage Photos'.tr),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Invalid apartment ID'.tr,
                style: const TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: Text('Go Back'.tr),
              ),
            ],
          ),
        ),
      );
    }

    final controller = Get.put(
      ManageApartmentPhotosController(apartmentId: apartmentId),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Manage Photos'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        // Loading State
        if (controller.isLoading.value && controller.photos.isEmpty) {
          return const LoadingWidget(message: 'Loading photos...');
        }

        // Error State
        if (controller.errorMessage.value != null && controller.photos.isEmpty) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.loadPhotos(),
          );
        }

        // Content
        return RefreshIndicator(
          onRefresh: controller.loadPhotos,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Photo Section
                if (controller.mainPhoto.value != null)
                  _buildMainPhotoSection(controller),

                if (controller.mainPhoto.value != null) SizedBox(height: 24.h),

                // All Photos Section
                _buildAllPhotosSection(controller),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickAndUploadImage(controller),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(Icons.add_photo_alternate, color: Colors.white),
      ),
    );
  }

  /// Build Main Photo Section
  Widget _buildMainPhotoSection(ManageApartmentPhotosController controller) {
    final mainPhoto = controller.mainPhoto.value!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Main Photo'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          height: 250.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: mainPhoto.imageUrl != null
                    ? Image.network(
                        mainPhoto.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.grey300,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48.sp,
                            color: AppColors.grey600,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.grey300,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48.sp,
                          color: AppColors.grey600,
                        ),
                      ),
              ),
              // Main Badge
              Positioned(
                top: 12.h,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Main'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build All Photos Section
  Widget _buildAllPhotosSection(ManageApartmentPhotosController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Photos'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: 12.h),
        Obx(() {
          if (controller.photos.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.photo_library_outlined,
              title: 'No Photos'.tr,
              subtitle: 'Add photos to showcase your apartment'.tr,
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
            ),
            itemCount: controller.photos.length,
            itemBuilder: (context, index) {
              final photo = controller.photos[index];
              final isMain = controller.isMainPhoto(photo.id);

              return _buildPhotoGridItem(controller, photo, isMain);
            },
          );
        }),
      ],
    );
  }

  /// Build Photo Grid Item
  Widget _buildPhotoGridItem(
    ManageApartmentPhotosController controller,
    photo,
    bool isMain,
  ) {
    return GestureDetector(
      onTap: () => _showPhotoActionSheet(controller, photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: photo.imageUrl != null
                  ? Image.network(
                      photo.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.grey300,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.grey300,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 32.sp,
                          color: AppColors.grey600,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.grey300,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 32.sp,
                        color: AppColors.grey600,
                      ),
                    ),
            ),
            // Main Badge
            if (isMain)
              Positioned(
                top: 4.h,
                right: 4.w,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Pick image from gallery and upload
  Future<void> _pickAndUploadImage(
    ManageApartmentPhotosController controller,
  ) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      await controller.uploadPhoto(File(image.path));
    }
  }

  /// Show photo action sheet
  void _showPhotoActionSheet(
    ManageApartmentPhotosController controller,
    photo,
  ) {
    Get.bottomSheet(
      PhotoActionSheetWidget(
        photo: photo,
        isMain: controller.isMainPhoto(photo.id),
        onSetMain: () {
          Get.back();
          controller.setMainPhoto(photo.id);
        },
        onDelete: () {
          Get.back();
          _showDeleteConfirmation(controller, photo);
        },
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(
    ManageApartmentPhotosController controller,
    photo,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Photo'.tr),
        content: Text('Are you sure you want to delete this photo?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deletePhoto(photo.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('Delete'.tr),
          ),
        ],
      ),
    );
  }
}

