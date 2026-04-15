import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/core/widgets/loading_widget.dart';
import 'package:my_havenly_application/features/profile/controllers/profile_edit_controller.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileEditController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Edit Profile'.tr),
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => controller.cancelEdit(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Updating profile...');
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileImageSection(controller, context),
                SizedBox(height: 32.h),

                Text(
                  'Personal Information'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 16.h),

                _buildTextField(
                  controller: controller.firstNameController,
                  label: 'First Name'.tr,
                  icon: Icons.person_outline,
                  hint: 'Enter first name'.tr,
                ),
                SizedBox(height: 16.h),

                _buildTextField(
                  controller: controller.lastNameController,
                  label: 'Last Name'.tr,
                  icon: Icons.person_outline,
                  hint: 'Enter last name'.tr,
                ),
                SizedBox(height: 16.h),

                _buildTextField(
                  controller: controller.phoneController,
                  label: 'Phone Number'.tr,
                  icon: Icons.phone_outlined,
                  hint: 'Enter phone number'.tr,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 16.h),

                _buildTextField(
                  controller: controller.usernameController,
                  label: 'Username'.tr,
                  icon: Icons.alternate_email,
                  hint: 'Enter username'.tr,
                ),
                SizedBox(height: 16.h),

                _buildDateField(controller, context),
                SizedBox(height: 32.h),

                // Action Buttons
                _buildActionButtons(controller),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileImageSection(
    ProfileEditController controller,
    BuildContext context,
  ) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Obx(() {
                final selectedImage = controller.selectedPersonalPhoto.value;
                final currentImageUrl = controller.getCurrentProfileImageUrl();

                return Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryNavy, width: 3),
                    image: selectedImage != null
                        ? DecorationImage(
                            image: FileImage(selectedImage),
                            fit: BoxFit.cover,
                          )
                        : (currentImageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(currentImageUrl),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    // Handle error
                                  },
                                )
                              : null),
                  ),
                  child: selectedImage == null && currentImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 60.sp,
                          color: AppColors.primaryNavy,
                        )
                      : null,
                );
              }),

              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () =>
                      _showImagePickerBottomSheet(controller, context, true),
                  child: Container(
                    width: 40.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => _showImagePickerBottomSheet(controller, context, true),
            child: Text(
              'Change Photo'.tr,
              style: TextStyle(
                color: AppColors.primaryNavy,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primaryNavy, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    ProfileEditController controller,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of birth'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => controller.selectDateOfBirth(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.textSecondary),
                SizedBox(width: 12.w),
                Expanded(
                  child: Obx(() {
                    final dateOfBirth = controller.selectedDateOfBirth.value;
                    final displayText = dateOfBirth != null
                        ? DateHelper.formatForDisplay(
                            dateOfBirth,
                            locale: Get.locale?.languageCode,
                          )
                        : 'Select date of birth'.tr;

                    return Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: dateOfBirth != null
                            ? AppColors.textColor
                            : Colors.grey,
                      ),
                    );
                  }),
                ),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ProfileEditController controller) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => controller.cancelEdit(),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              side: BorderSide(color: AppColors.primaryNavy),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),

        Expanded(
          flex: 2,
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.updateProfile(),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Save Changes'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _showImagePickerBottomSheet(
    ProfileEditController controller,
    BuildContext context,
    bool isPersonalPhoto,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isPersonalPhoto
                  ? 'Select Profile Photo'.tr
                  : 'Select ID Photo'.tr,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  icon: Icons.photo_library,
                  label: 'Gallery'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(
                      source: ImageSource.gallery,
                      isPersonalPhoto: isPersonalPhoto,
                    );
                  },
                ),
                _buildImagePickerOption(
                  icon: Icons.camera_alt,
                  label: 'Camera'.tr,
                  onTap: () {
                    Navigator.pop(context);
                    controller.pickImage(
                      source: ImageSource.camera,
                      isPersonalPhoto: isPersonalPhoto,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40.sp, color: AppColors.primaryNavy),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textColor),
          ),
        ],
      ),
    );
  }
}
