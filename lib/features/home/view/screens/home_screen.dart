import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/auth/controller/logout_controller.dart';
import 'package:my_havenly_application/features/auth/controller/theme_controller.dart';
import '../../controller/home_controller.dart';
import '../../controller/main_navigation_controller.dart';
import '../widgets/category_chip.dart';
import '../widgets/item_card.dart';
import '../../../profile/widgets/bottom_navigation_bar_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final navigationController = Get.put(MainNavigationController());
    // final LogoutController logoutController = Get.put(LogoutController());
    final logoutController = Get.find<LogoutController>();

    return Scaffold(
      backgroundColor: ThemeController.getHomeBg(context),
      /* Get.isDarkMode
          ? Colors.grey.shade900
          : Colors.grey.shade50, */
      body: SafeArea(
        child: Obx(
          () => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with icons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Sidebar menu icon
                      GestureDetector(
                        onTap: controller.openSidebar,
                        // child: SvgPicture.asset(
                        //   'assets/svgs/notification_icon.svg',
                        // ),
                        child: Icon(Icons.notifications, size: 35),
                      ),
                      // Notes section iconw
                      GestureDetector(
                        onTap: controller.openNotes,

                        // child: SvgPicture.asset('assets/svgs/menu_icom.svg'),
                        child: Icon(Icons.menu, size: 35),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),

                // User information section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello! '.tr + ' ${controller.userName}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Get.isDarkMode
                              ? Colors.white
                              : Color(0xff001733),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.changeThemeMode(
                                Get.isDarkMode
                                    ? ThemeMode.light
                                    : ThemeMode.dark,
                              );
                            },
                            icon: Icon(
                              Get.isDarkMode
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                            ),
                            label: Text(
                              Get.isDarkMode ? "الوضع الفاتح" : "الوضع الداكن",
                            ),
                          ),
                          ElevatedButton(
                            //////////////////
                            onPressed: () {
                              logoutController.logout();
                            },
                            child: Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          ////////////////
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            controller.userLocation,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              controller.userStatus,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: controller.updateSearchText,
                      decoration: InputDecoration(
                        hintText: 'Find your House'.tr,
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Categories section
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        return CategoryChip(
                          name: category.name,
                          isSelected: category.isSelected,
                          onTap: () => controller.selectCategory(category.id),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Items section
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearby'.tr,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff001733),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: controller.searchedItems.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No items found'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.searchedItems.length,
                                itemBuilder: (context, index) {
                                  final item = controller.searchedItems[index];
                                  return ItemCard(item: item);
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        controller: navigationController,
      ),
    );
  }
}
