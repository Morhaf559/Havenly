// Widget: Top Bar with Back Button, Title, and Edit Button
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class TopBarWidget extends StatelessWidget {
  final ProfileController controller;

  const TopBarWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: controller.selectedBottomNav.value == 3
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.chevron_left,
                    color: controller.selectedBottomNav.value == 3
                        ? const Color(0xFF1565C0)
                        : Colors.white,
                    size: 24,
                  ),
                  onPressed: controller.onBackPressed,
                ),
              )),

          // Title
          const Text(
            'Reserved',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),

          // Edit Button
          Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: controller.selectedBottomNav.value == 3
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFF1565C0),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: controller.selectedBottomNav.value == 3
                        ? const Color(0xFF1565C0)
                        : Colors.white,
                    size: 20,
                  ),
                  onPressed: controller.onEditPressed,
                ),
              )),
        ],
      ),
    );
  }
}

