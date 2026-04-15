import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/controllers/theme_controller.dart';
import '../../main/controllers/main_navigation_controller.dart';

class BottomNavItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final MainNavigationController controller;

  const BottomNavItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    
    return GestureDetector(
      onTap: () {
        controller.setSelectedTab(index);
      },
      child: Obx(() {
        final isSelected = controller.selectedTabIndex.value == index;
        final isDark = themeController.themeMode == ThemeMode.dark ||
            (themeController.themeMode == ThemeMode.system && Get.isDarkMode);
        
        final selectedColor = isDark 
            ? Colors.white 
            : AppColors.accentBlue;
        final unselectedColor = isDark 
            ? Colors.white70 
            : Colors.white70;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(
                  icon,
                  color: isSelected ? selectedColor : unselectedColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 4.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
