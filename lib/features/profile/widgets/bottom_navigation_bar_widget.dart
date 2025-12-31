// Widget: Bottom Navigation Bar
import 'package:flutter/material.dart';
import '../../home/controller/main_navigation_controller.dart';
import 'bottom_nav_item_widget.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final MainNavigationController controller;

  const BottomNavigationBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF012E65),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomNavItemWidget(
            icon: Icons.home,
            index: 0,
            controller: controller,
          ),
          BottomNavItemWidget(
            icon: Icons.explore,
            index: 1,
            controller: controller,
          ),
          BottomNavItemWidget(
            icon: Icons.favorite,
            index: 2,
            controller: controller,
          ),
          BottomNavItemWidget(
            icon: Icons.person,
            index: 3,
            controller: controller,
          ),
        ],
      ),
    );
  }
}
