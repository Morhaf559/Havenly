import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/apartments/controllers/add_apartment_controller.dart';
import 'package:my_havenly_application/features/apartments/views/widgets/apartment_image_picker_widget.dart';
import 'package:my_havenly_application/features/governorates/views/widgets/governorate_picker.dart';

/// Add Apartment Screen
/// Form for adding a new apartment
class AddApartmentScreen extends StatelessWidget {
  const AddApartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AddApartmentController should be initialized via ApartmentsBinding
    final controller = Get.find<AddApartmentController>();

    return Scaffold(
      appBar: AppBar(title: Text('Add New Apartment'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Form(
            child: SafeArea(
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    maxLines: 3,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  SizedBox(height: 24.h),

                  // Price and Currency
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: controller.priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Daily Price *'.tr,
                                hintText: '0.00',
                                helperText: 'Price per day'.tr,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
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
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                              ),
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Note: This is the daily rental price'.tr,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Governorate
                  GovernoratePicker(
                    selectedGovernorateId:
                        controller.selectedGovernorateId.value,
                    onChanged: (value) {
                      controller.setGovernorate(value);
                    },
                  ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
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
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  ApartmentImagePickerWidget(
                    images: controller.selectedImages.toList(),
                    onImageAdded: (image) {
                      controller.addImage(image);
                    },
                    onImageRemoved: (index) {
                      controller.removeImage(index);
                    },
                  ),
                  SizedBox(height: 32.h),

                  // Submit Button
                  ElevatedButton(
                    onPressed: controller.submit,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Add Apartment'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
