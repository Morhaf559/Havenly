import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/core/widgets/error_state_widget.dart';
import 'package:my_havenly_application/core/widgets/shimmer_widgets.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/features/profile/controllers/profile_controller.dart';

class ProfileContentWidget extends StatelessWidget {
  const ProfileContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Profile'.tr),
        elevation: 0,
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        actions: [
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => controller.navigateToEdit(),
            tooltip: 'Edit Profile'.tr,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.user.value == null) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerProfileCard(),
                SizedBox(height: 24.h),
                Container(
                  width: double.infinity,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 16.h),
                const ShimmerProfileCard(),
                SizedBox(height: 12.h),
                const ShimmerProfileCard(),
                SizedBox(height: 12.h),
                const ShimmerProfileCard(),
                SizedBox(height: 12.h),
                const ShimmerProfileCard(),
              ],
            ),
          );
        }

        if (controller.errorMessage.value != null &&
            controller.user.value == null) {
          return ErrorStateWidget(
            message: controller.errorMessage.value!,
            onRetry: () => controller.refresh(),
          );
        }

        final user = controller.user.value;
        if (user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text(
                  'No profile data'.tr,
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.refresh(),
                  child: Text('Retry'.tr),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeaderCard(user),
                SizedBox(height: 24.h),
                Text(
                  'Personal Information'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 16.h),
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number'.tr,
                  value: user.phone ?? 'N/A'.tr,
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  icon: Icons.person_outline,
                  title: 'Username'.tr,
                  value: user.username ?? 'N/A'.tr,
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  icon: Icons.badge_outlined,
                  title: 'Full Name'.tr,
                  value: user.fullName.isNotEmpty ? user.fullName : 'N/A'.tr,
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  icon: Icons.cake_outlined,
                  title: 'Date of birth'.tr,
                  value: user.dateOfBirth != null
                      ? DateHelper.formatForDisplay(
                          DateTime.parse(user.dateOfBirth!),
                        )
                      : 'N/A'.tr,
                ),
                SizedBox(height: 12.h),
                _buildInfoCard(
                  icon: Icons.verified_user_outlined,
                  title: 'Role'.tr,
                  value: user.role != null && user.role!.isNotEmpty
                      ? user.role![0].toUpperCase() + user.role!.substring(1).toLowerCase()
                      : 'User'.tr,
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.resetPassword),
                    icon: const Icon(Icons.lock_reset),
                    label: Text('Change Password'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context, controller),
                    icon: const Icon(Icons.logout),
                    label: Text('Logout'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red, width: 1.5),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeaderCard(user) {
    final imageUrl = user.personalPhoto?.url;
    
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryNavy.withOpacity(0.1),
            AppColors.primaryNavy.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryNavy.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryNavy, width: 2),
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(
                    Icons.person,
                    size: 40.sp,
                    color: AppColors.primaryNavy,
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.isNotEmpty ? user.fullName : 'User'.tr,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  user.role != null && user.role!.isNotEmpty
                      ? user.role![0].toUpperCase() + user.role!.substring(1).toLowerCase()
                      : 'User'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 24.sp, color: AppColors.primaryNavy),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'.tr),
        content: Text('Are you sure you want to logout?'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.logout();
            },
            child: Text(
              'Logout'.tr,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
