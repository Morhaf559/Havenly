import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_havenly_application/features/main/view/screens/main_wrapper_screen.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/controllers/theme_controller.dart';
import '../../../../../core/controllers/locale_controller.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../profile/services/profile_services.dart';
import '../../../profile/models/profile_model.dart';
import '../../../auth/controllers/logout_controller.dart';
import '../../../auth/bindings/auth_binding.dart';

class SideBarWidget extends StatelessWidget {
  const SideBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localeController = Get.find<LocaleController>();
    final profileService = ProfileService();

    return Drawer(
      backgroundColor: AppColors.cardColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildUserProfileCard(profileService),
            SizedBox(height: 24.h),
            _buildThemeToggleCard(themeController),
            SizedBox(height: 16.h),
            _buildLanguageToggleCard(localeController),
            const Spacer(),
            _buildLogoutButton(),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Havenly v1.0.0',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(ProfileService profileService) {
    return FutureBuilder<UserProfile>(
      future: profileService.getProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryNavy),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.person, size: 60.sp, color: AppColors.textSecondary),
                SizedBox(height: 8.h),
                Text(
                  'User'.tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          );
        }

        final profile = snapshot.data;
        final userName = profile?.name ?? 'User'.tr;
        final profileImageUrl = profile?.profileImageUrl ?? '';

        return GestureDetector(
          onTap: () {
            Get.back();
            Get.to(() => const MainWrapperScreen());
          },
          child: Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryNavy, width: 2),
                  ),
                  child: ClipOval(
                    child: profileImageUrl.isNotEmpty
                        ? Image.network(
                            profileImageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: AppColors.grey300,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2,
                                    color: AppColors.primaryNavy,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.grey300,
                                  child: Icon(
                                    Icons.person,
                                    size: 30.sp,
                                    color: AppColors.grey600,
                                  ),
                                ),
                          )
                        : Container(
                            color: AppColors.grey300,
                            child: Icon(
                              Icons.person,
                              size: 30.sp,
                              color: AppColors.grey600,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'View Profile'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeToggleCard(ThemeController themeController) {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  themeController.isDarkMode
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: AppColors.primaryNavy,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      themeController.isDarkMode
                          ? 'Dark Mode'.tr
                          : 'Light Mode'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Switch(
              value: themeController.isDarkMode,
              onChanged: (value) {
                if (value) {
                  themeController.setDarkMode();
                } else {
                  themeController.setLightMode();
                }
              },
              activeColor: AppColors.primaryNavy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggleCard(LocaleController localeController) {
    return Obx(
      () => Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.language, color: AppColors.primaryNavy, size: 24.sp),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language'.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      localeController.localeName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Switch(
              value: localeController.isEnglish,
              onChanged: (value) {
                localeController.toggleLocale();
              },
              activeColor: AppColors.primaryNavy,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(),
        icon: Icon(Icons.logout, size: 20.sp, color: Colors.white),
        label: Text(
          'Logout'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Logout'.tr),
        content: Text('Are you sure you want to logout?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Logout'.tr, style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      Get.back();

      if (!Get.isRegistered<LogoutController>()) {
        AuthBinding().dependencies();
      }

      Get.dialog(
        Center(child: CircularProgressIndicator(color: AppColors.primaryNavy)),
        barrierDismissible: false,
      );

      final logoutController = Get.isRegistered<LogoutController>()
          ? Get.find<LogoutController>()
          : Get.put(LogoutController());
      
      await logoutController.logout();

      await Future.delayed(const Duration(milliseconds: 400));
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error'.tr,
        'Failed to logout: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: Icon(Icons.error, color: Colors.white),
      );
      
      await Future.delayed(const Duration(milliseconds: 200));
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }
}
