// Widget: Bottom Navigation Bar Item (Home, Explore, Favorite)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controller/main_navigation_controller.dart';

class BottomNavItemWidget extends StatelessWidget {
  final IconData icon;
  final int index;
  final MainNavigationController controller;

  const BottomNavItemWidget({
    super.key,
    required this.icon,
    required this.index,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Call specific method based on index
        switch (index) {
          case 0:
            controller.onHomePressed();
            break;
          case 1:
            controller.onExplorePressed();
            break;
          case 2:
            controller.onFavoritePressed();
            break;
          case 3:
            controller.onProfilePressed();
            break;
          default:
            controller.setSelectedBottomNav(index);
        }
      },
      child: Obx(() {
        final isSelected = controller.selectedBottomNav.value == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: isSelected ? 1.1 : 1.0,
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 28,
            ),
          ),
        );
      }),
    );
  }
}

