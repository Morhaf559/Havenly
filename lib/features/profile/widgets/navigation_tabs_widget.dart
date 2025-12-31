// Widget: Navigation Tabs (Properties and Archive)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class NavigationTabsWidget extends StatelessWidget {
  final ProfileController controller;

  const NavigationTabsWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          // Properties Tab
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setSelectedTab(0),
              child: Obx(() => Column(
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: controller.selectedTab.value == 0
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: controller.selectedTab.value == 0
                              ? const Color(0xFF1565C0)
                              : Colors.grey,
                        ),
                        child: const Text('Properties'),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        decoration: BoxDecoration(
                          color: controller.selectedTab.value == 0
                              ? const Color(0xFF1565C0)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  )),
            ),
          ),

          // Archive Tab
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setSelectedTab(1),
              child: Obx(() => Column(
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: controller.selectedTab.value == 1
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: controller.selectedTab.value == 1
                              ? const Color(0xFF1565C0)
                              : Colors.grey,
                        ),
                        child: const Text('Archive'),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3,
                        decoration: BoxDecoration(
                          color: controller.selectedTab.value == 1
                              ? const Color(0xFF1565C0)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

