import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/controllers/theme_controller.dart';
import '../../main/controllers/main_navigation_controller.dart';
import 'bottom_nav_item_widget.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final MainNavigationController controller;

  const BottomNavigationBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return Obx(() {
      final visibleTabs = controller.visibleTabs;
      if (visibleTabs.isEmpty) {
        return const SizedBox.shrink();
      }

      final isDark = themeController.themeMode == ThemeMode.dark ||
          (themeController.themeMode == ThemeMode.system && Get.isDarkMode);
      final backgroundColor = isDark 
          ? AppColors.darkPrimaryColor 
          : AppColors.primaryNavy;

      return Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10.r,
              offset: Offset(0, -2.h),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: visibleTabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;

              return BottomNavItemWidget(
                icon: tab.icon,
                label: tab.labelKey.tr,
                index: index,
                controller: controller,
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
