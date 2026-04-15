import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/apartments/controllers/edit_apartment_controller.dart';
import 'package:my_havenly_application/features/apartments/views/widgets/apartment_existing_photos_widget.dart';
import 'package:my_havenly_application/features/apartments/views/widgets/apartment_image_picker_widget.dart';
import 'package:my_havenly_application/features/governorates/views/widgets/governorate_picker.dart';

/// Edit Apartment Screen
/// Form for editing an existing apartment
class EditApartmentScreen extends StatelessWidget {
  final int apartmentId;

  const EditApartmentScreen({
    super.key,
    required this.apartmentId,
  });

  void _showDeleteDialog(BuildContext context, EditApartmentController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'.tr),
        content: Text('Are you sure you want to delete this apartment? This action cannot be undone.'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await controller.deleteApartment();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Validate apartment ID
    if (apartmentId <= 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Apartment'.tr),
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

    // EditApartmentController should be initialized via ApartmentsBinding
    // Note: We need to pass apartmentId, so we'll use Get.put with tag or create a factory
    // For now, we'll use Get.find and set apartmentId manually if needed
    // Or we can use Get.put with a unique tag based on apartmentId
    final controller = Get.put(
      EditApartmentController(apartmentId: apartmentId),
      tag: 'edit_$apartmentId',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Apartment'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        // Show loading state
        if (controller.isLoading.value && controller.apartment.value == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show error state
        if (controller.errorMessage.value != null && controller.apartment.value == null) {
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
                  onPressed: controller.loadApartmentData,
                  child: Text('Retry'.tr),
                ),
              ],
            ),
          );
        }

        // Show form (non-reactive part - form fields don't need Obx)
        return _buildForm(context, controller);
      }),
    );
  }

  /// Build form widget (separated to avoid GetX warning)
  Widget _buildForm(BuildContext context, EditApartmentController controller) {
    return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Section
                Text(
                  'Title'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: controller.titleArController,
                  decoration: InputDecoration(
                    labelText: 'Title (Arabic)'.tr,
                    hintText: 'Enter title in Arabic'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: controller.titleEnController,
                  decoration: InputDecoration(
                    labelText: 'Title (English)'.tr,
                    hintText: 'Enter title in English'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),

                // Description Section
                Text(
                  'Description'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: controller.descriptionArController,
                  decoration: InputDecoration(
                    labelText: 'Description (Arabic)'.tr,
                    hintText: 'Enter description in Arabic'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  maxLines: 3,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: controller.descriptionEnController,
                  decoration: InputDecoration(
                    labelText: 'Description (English)'.tr,
                    hintText: 'Enter description in English'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  maxLines: 3,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),

                // Price and Currency
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: controller.priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price *'.tr,
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: controller.currencyController,
                        decoration: InputDecoration(
                          labelText: 'Currency'.tr,
                          hintText: '\$',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Governorate (reactive)
                Obx(() {
                  final govId = controller.selectedGovernorateId.value;
                  return GovernoratePicker(
                    selectedGovernorateId: govId,
                    onChanged: (value) {
                      controller.setGovernorate(value);
                    },
                  );
                }),
                SizedBox(height: 24.h),

                // City Section
                Text(
                  'City'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: controller.cityArController,
                  decoration: InputDecoration(
                    labelText: 'City (Arabic)'.tr,
                    hintText: 'Enter city in Arabic'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: controller.cityEnController,
                  decoration: InputDecoration(
                    labelText: 'City (English)'.tr,
                    hintText: 'Enter city in English'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),

                // Address Section
                Text(
                  'Address'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: controller.addressArController,
                  decoration: InputDecoration(
                    labelText: 'Address (Arabic)'.tr,
                    hintText: 'Enter address in Arabic'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  maxLines: 2,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: controller.addressEnController,
                  decoration: InputDecoration(
                    labelText: 'Address (English)'.tr,
                    hintText: 'Enter address in English'.tr,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  maxLines: 2,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),

                // Rooms, Bathrooms, Area, Floor
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.numberOfRoomsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Number of Rooms'.tr,
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: controller.numberOfBathroomsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Number of Bathrooms'.tr,
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.areaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Area (m²)'.tr,
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: controller.floorController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Floor'.tr,
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // Existing Photos (reactive)
                Obx(() {
                  // Access observable value to register dependency
                  final photos = controller.existingPhotos.toList();
                  final _ = controller.existingPhotos.length; // dependency
                  return ApartmentExistingPhotosWidget(
                    photos: photos,
                    onDelete: (photoId) {
                      controller.deletePhoto(photoId);
                    },
                    onSetMain: (photoId) {
                      controller.setMainPhoto(photoId);
                    },
                  );
                }),
                SizedBox(height: 24.h),

                // New Images Section (reactive)
                Obx(() {
                  final images = controller.newImages.toList();
                  final _ = controller.newImages.length; // dependency
                  return ApartmentImagePickerWidget(
                    images: images,
                    onImageAdded: (image) {
                      controller.addImage(image);
                    },
                    onImageRemoved: (index) {
                      controller.removeNewImage(index);
                    },
                  );
                }),
                SizedBox(height: 32.h),

                // Update Button (reactive - disable when loading)
                Obx(() {
                  final isLoading = controller.isLoading.value;
                  return ElevatedButton(
                    onPressed: isLoading ? null : controller.updateApartment,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Update Apartment'.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                }),
              ],
            ),
          ),
        );
  }
}

