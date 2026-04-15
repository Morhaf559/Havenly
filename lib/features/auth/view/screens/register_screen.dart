import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/auth/controllers/register_controller.dart';
import 'package:my_havenly_application/features/auth/view/widget/costum_button.dart';
import 'package:my_havenly_application/features/auth/view/widget/costum_field.dart';
import 'package:my_havenly_application/features/auth/view/widget/date_time_widget.dart';
import 'package:my_havenly_application/features/auth/view/widget/image_picker_widget.dart';
import 'package:my_havenly_application/features/auth/view/screens/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final registerController = Get.find<RegisterController>();

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        children: [
          Column(
            children: [
              SizedBox(height: 20.h),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accentBlue, width: 2.w),
                  borderRadius: BorderRadius.circular(18.r),
                  color: AppColors.cardColor,
                ),
                padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 18),
                child: SafeArea(
                  child: Column(
                    children: [
                      Text(
                        'Create Account'.tr,
                        style: TextStyle(
                          fontSize: 28.sp,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => CostumField(
                                controller:
                                    registerController.firstNameController,
                                labelText: 'First Name'.tr,
                                errorText:
                                    registerController.firstNameError.value,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Obx(
                              () => CostumField(
                                controller:
                                    registerController.lastNameController,
                                labelText: 'Last Name'.tr,
                                errorText:
                                    registerController.lastNameError.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Obx(
                        () => CostumField(
                          controller: registerController.usernameController,
                          labelText: 'Username'.tr,
                          errorText: registerController.usernameError.value,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Obx(
                        () => CostumField(
                          controller: registerController.phoneController,
                          labelText: 'Phone Number'.tr,
                          keyboardType: TextInputType.phone,
                          errorText: registerController.phoneError.value,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Obx(
                        () => CostumField(
                          controller: registerController.passwordController,
                          labelText: 'Password'.tr,
                          isPassword: true,
                          errorText: registerController.passwordError.value,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Obx(
                        () => CostumField(
                          controller:
                              registerController.confirmedPasswordController,
                          labelText: 'Confirmed Password'.tr,
                          isPassword: true,
                          errorText:
                              registerController.confirmedPasswordError.value,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      const DateTimeWidget(),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => ImagePickerWidget(
                                    text: 'ID image'.tr,
                                    errorText:
                                        registerController.idImageError.value,
                                    onImagePicked: (path) {
                                      registerController.idImagePath.value =
                                          path;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => ImagePickerWidget(
                                    text: 'personal photo'.tr,
                                    errorText: registerController
                                        .personalPhotoError
                                        .value,
                                    onImagePicked: (path) {
                                      registerController
                                              .personalPhotoPath
                                              .value =
                                          path;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      Obx(
                        () => CostumButton(
                          text: registerController.isLoading.value
                              ? 'Loading...'.tr
                              : 'Sign up'.tr,
                          Width: double.infinity,
                          color: AppColors.accentBlue,
                          onTap: registerController.isLoading.value
                              ? null
                              : () {
                                  registerController.registerUser();
                                },
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?".tr,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () {
                              Get.off(() => const LoginScreen());
                            },
                            child: Text(
                              'Login'.tr,
                              style: TextStyle(
                                color: AppColors.accentBlue,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
