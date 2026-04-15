import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/main_navigation_controller.dart';
import '../../../../features/profile/widgets/bottom_navigation_bar_widget.dart';
import '../../models/navigation_tab_model.dart';
import '../widgets/home_content_widget.dart';
import '../widgets/reservations_content_widget.dart';
import '../widgets/dashboard_content_widget.dart';
import '../widgets/favorite_content_widget.dart';
import '../widgets/profile_content_widget.dart';
import '../../../../features/reservations/controllers/reservation_request_controller.dart';

class MainWrapperScreen extends StatelessWidget {
  const MainWrapperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<MainNavigationController>();

    navController.initializeTabs(
      NavigationTabModel.getDefaultTabs(
        homeBuilder: () => const HomeContentWidget(),
        reservationsBuilder: () => const ReservationsContentWidget(),
        dashboardBuilder: () => const DashboardContentWidget(),
        favoriteBuilder: () => const FavoriteContentWidget(),
        profileBuilder: () => const ProfileContentWidget(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      if (args is Map && args['targetTab'] is String) {
        final targetTab = args['targetTab'] as String;
        navController.applyInitialTab(targetTab);

        if (targetTab == 'reservations') {
          try {
            final reservationRequestController =
                Get.find<ReservationRequestController>();
            Future.delayed(const Duration(milliseconds: 200), () {
              reservationRequestController.fetchSentReservationRequests();
            });
          } catch (e) {}
        }
      }
    });

    return Scaffold(
      body: Obx(() {
        final visibleTabs = navController.visibleTabs;

        if (visibleTabs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return PageView(
          controller: navController.pageController,
          onPageChanged: navController.onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: visibleTabs.map((tab) {
            final content = navController.getTabContent(tab.id);
            return content ?? const SizedBox.shrink();
          }).toList(),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: BottomNavigationBarWidget(controller: navController),
      ),
    );
  }
}
