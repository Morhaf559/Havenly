import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/auth/controllers/reset_password_controller.dart';
import 'package:my_havenly_application/features/auth/view/widget/costum_button.dart';
import 'package:my_havenly_application/features/auth/view/widget/costum_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResetPasswordController>();

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100.h),
            Text(
              'Reset Password'.tr,
              style: TextStyle(
                fontSize: 32.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Enter phone number and new password'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accentBlue, width: 2.w),
                borderRadius: BorderRadius.circular(18.r),
                color: AppColors.cardColor,
              ),
              padding: EdgeInsets.all(20.w),
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Text(
                    'Reset'.tr,
                    style: TextStyle(
                      fontSize: 32.sp,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Obx(
                    () => CostumField(
                      labelText: 'Phone Number'.tr,
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      errorText: controller.phoneError.value,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => CostumField(
                      labelText: 'New Password'.tr,
                      isPassword: true,
                      controller: controller.passwordController,
                      errorText: controller.passwordError.value,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => CostumField(
                      labelText: 'Confirmed Password'.tr,
                      isPassword: true,
                      controller: controller.passwordConfirmationController,
                      errorText: controller.passwordConfirmationError.value,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Obx(
                    () => CostumButton(
                      text: controller.isLoading.value
                          ? 'Loading...'.tr
                          : 'Reset'.tr,
                      Width: double.infinity,
                      color: AppColors.accentBlue,
                      onTap: controller.isLoading.value
                          ? null
                          : () {
                              controller.resetPassword();
                            },
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Remember your password?'.tr,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {
                          Get.back();
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
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

