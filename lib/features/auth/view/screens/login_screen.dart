import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/auth/controllers/login_controller.dart';
import 'package:my_havenly_application/features/auth/view/screens/register_screen.dart';
import 'package:my_havenly_application/features/auth/view/widget/costum_button.dart';
import 'package:my_havenly_application/features/auth/view/widget/costum_field.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تم حذف منطق Get.isRegistered من هنا لضمان استقرار الـ UI

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100.h),
            Text(
              'Welcome Back !'.tr,
              style: TextStyle(
                fontSize: 32.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'sign in to continue'.tr,
              style: TextStyle(
                fontSize: 20.sp,
                color: Colors.white.withOpacity(0.9),
              ),
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
                    'Log in'.tr,
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
                      labelText: 'Password'.tr,
                      isPassword: true,
                      controller: controller.passwordController,
                      errorText: controller.passwordError.value,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.resetPassword),
                        child: Text(
                          'Forget password?'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.accentBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Obx(
                    () => CostumButton(
                      text: controller.isLoading.value
                          ? 'Loading...'.tr
                          : 'Login'.tr,
                      Width: double.infinity,
                      color: AppColors.accentBlue,
                      onTap: controller.isLoading.value
                          ? null
                          : () => controller.loginUser(),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?".tr,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.register),
                        child: Text(
                          'Register Now'.tr,
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
