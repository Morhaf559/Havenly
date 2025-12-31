// View: Profile Screen UI using GetX - فقط استدعاءات الـ Widgets
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../home/controller/main_navigation_controller.dart';
import '../widgets/top_bar_widget.dart';
import '../widgets/profile_section_widget.dart';
import '../widgets/navigation_tabs_widget.dart';
import '../widgets/properties_list_widget.dart';
import '../widgets/archive_list_widget.dart';
import '../widgets/bottom_navigation_bar_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers using GetX
    final ProfileController controller = Get.put(ProfileController());
    final MainNavigationController navigationController = Get.put(MainNavigationController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TopBarWidget(controller: controller),
            ProfileSectionWidget(controller: controller),
            NavigationTabsWidget(controller: controller),
            Expanded(
              child: Obx(() => controller.selectedTab.value == 0
                  ? PropertiesListWidget(controller: controller)
                  : const ArchiveListWidget()),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(controller: navigationController),
    );
  }
}