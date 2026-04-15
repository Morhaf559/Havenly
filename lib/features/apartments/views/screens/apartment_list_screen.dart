import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/apartments/controllers/apartment_list_controller.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/apartments/views/widgets/apartment_filters_bottom_sheet.dart';
import 'package:my_havenly_application/features/main/controllers/main_navigation_controller.dart';
import 'package:my_havenly_application/features/profile/widgets/bottom_navigation_bar_widget.dart';

/// Apartment List Screen
class ApartmentListScreen extends StatefulWidget {
  const ApartmentListScreen({super.key});

  @override
  State<ApartmentListScreen> createState() => _ApartmentListScreenState();
}

class _ApartmentListScreenState extends State<ApartmentListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late final ApartmentListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ApartmentListController());
    _scrollController.addListener(_onScroll);
    // Update bottom nav bar index when screen is opened
    // MainNavigationController should be initialized via MainBinding when navigating from MainWrapperScreen
    // If not found, create it (fallback for direct navigation)
    final navController = Get.isRegistered<MainNavigationController>()
        ? Get.find<MainNavigationController>()
        : Get.put(MainNavigationController());
    navController.setSelectedBottomNav(1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  void _showFilters() async {
    final filters = await ApartmentFiltersBottomSheet.show(context);
    if (filters != null && mounted) {
      // Convert Map to ApartmentFilterModel
      controller.applyFiltersFromMap(filters);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apartments'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search apartments...',
                prefixIcon: Icon(Icons.search, size: 24.sp),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          _searchController.clear();
                          controller.applySearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 16.sp),
              onSubmitted: (value) {
                controller.applySearch(value);
              },
              onChanged: (value) {
                // Optional: Implement debounce here if needed
              },
            ),
          ),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.apartments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text(
                        'No apartments found',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshList,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount:
                      controller.apartments.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.apartments.length) {
                      // Loading indicator at the bottom
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    final apartment = controller.apartments[index];
                    return _ApartmentCard(apartment: apartment);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        controller: Get.find<MainNavigationController>(),
      ),
    );
  }
}

class _ApartmentCard extends StatelessWidget {
  final ApartmentModel apartment;

  const _ApartmentCard({required this.apartment});

  @override
  Widget build(BuildContext context) {
    final locale = Get.locale?.languageCode ?? 'ar';
    final title = apartment.getLocalizedTitle(locale) ?? 'No Title';

    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      clipBehavior: Clip.antiAlias, // يضمن عدم خروج المحتوى عن حدود الكارد
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.apartmentDetails, arguments: apartment.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // يجعل العمود يأخذ أقل مساحة ممكنة
          children: [
            // Image Section
            _buildImage(),

            // Content Section
            Padding(
              padding: EdgeInsets.all(12.w), // تقليل البادينج قليلاً
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title مع تحديد عدد الأسطر
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // يضع نقاط (...) إذا كان النص طويلاً
                    style: TextStyle(
                      fontSize: 16.sp, // تقليل الحجم قليلاً لتناسب المساحة
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // City
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Expanded(
                        // يمنع النص من تجاوز عرض الشاشة
                        child: Text(
                          apartment.city ?? 'Not specified'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Price and Button (اختياري وضعهم في Row لتوفير مساحة عمودية)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${apartment.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      // زر عرض التفاصيل لتقليل الازدحام
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "View Details",
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت منفصل للصورة لتنظيم الكود
  Widget _buildImage() {
    double imageHeight = 140.h; // تقليل الارتفاع قليلاً
    if (apartment.mainImage != null) {
      return Image.network(
        apartment.mainImage!,
        width: double.infinity,
        height: imageHeight,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _placeholderImage(imageHeight),
      );
    } else {
      return _placeholderImage(imageHeight);
    }
  }

  Widget _placeholderImage(double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image, size: 40.sp, color: Colors.grey[500]),
    );
  }
}
