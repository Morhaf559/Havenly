import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/utils/app_colors.dart';
import 'package:my_havenly_application/features/home/controllers/home_controller.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/shimmer_widgets.dart';
import '../../../home/view/widgets/side_bar_widget.dart';
import '../../../home/view/widgets/filters_bottom_sheet_widget.dart';
import '../../../home/view/widgets/category_chip.dart';
import '../../../home/view/widgets/item_card.dart';
import '../../../notifications/views/widgets/notification_badge.dart';

class HomeContentWidget extends StatefulWidget {
  const HomeContentWidget({super.key});

  @override
  State<HomeContentWidget> createState() => _HomeContentWidgetState();
}

class _HomeContentWidgetState extends State<HomeContentWidget> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<HomeController>();
    _searchController = TextEditingController(
      text: controller.searchText.value,
    );

    ever(controller.searchText, (String value) {
      if (_searchController.text != value) {
        _searchController.text = value;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      drawer: const SideBarWidget(),
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => Padding(
            padding: EdgeInsets.all(9.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.menu,
                  color: AppColors.primaryNavy,
                  size: 24.sp,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: 'Menu'.tr,
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(9.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: NotificationBadge(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primaryNavy,
                    size: 24.sp,
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.notifications),
                  tooltip: 'Notifications'.tr,
                ),
              ),
            ),
          ),
        ],
      ),

      body: Builder(
        builder: (context) => SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshApartments();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  // Search field and Filter button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        // Search field
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Obx(
                              () => TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  controller.searchText.value = value;
                                },
                                onSubmitted: (value) {
                                  if (value.trim().isNotEmpty ||
                                      controller.filters.isNotEmpty ||
                                      controller.selectedGovernorate.value !=
                                          null) {
                                    controller.navigateToSearchResults();
                                  }
                                },
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  hintText: 'Find your House'.tr,
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade400,
                                  ),
                                  suffixIcon:
                                      controller.searchText.value.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.grey.shade400,
                                          ),
                                          onPressed: () {
                                            controller.searchText.value = '';
                                            _searchController.clear();
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 16.h,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Filter button
                        GestureDetector(
                          onTap: () async {
                            final filters = await FiltersBottomSheetWidget.show(
                              context,
                              initialFilters: controller.filters,
                            );
                            if (filters != null) {
                              controller.applyFilters(filters);
                              controller.navigateToSearchResults();
                            }
                          },
                          child: Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.filter_list,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),
                  Obx(() {
                    if (controller.availableApartments.isEmpty &&
                        !controller.isLoading.value) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            'Available Now'.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        SizedBox(
                          height: 280.h,
                          child:
                              controller.isLoading.value &&
                                  controller.availableApartments.isEmpty
                              ? const ShimmerHorizontalList()
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                  ),
                                  itemCount: controller.availableItems.length,
                                  itemBuilder: (context, index) {
                                    final item =
                                        controller.availableItems[index];
                                    return Container(
                                      width: 180.w,
                                      margin: EdgeInsets.only(right: 12.w),
                                      child: ItemCard(item: item),
                                    );
                                  },
                                ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    );
                  }),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w),
                    child: SizedBox(
                      height: 50.h,
                      child: Obx(() {
                        final allGovernorates = [
                          null,
                          ...controller.governorates,
                        ];

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allGovernorates.length,
                          itemBuilder: (context, index) {
                            final governorate = allGovernorates[index];
                            final name = governorate == null
                                ? 'All'.tr
                                : governorate.getLocalizedName(
                                        controller.currentLocale,
                                      ) ??
                                      'Unknown'.tr;

                            return Obx(() {
                              final isSelected =
                                  controller.selectedGovernorate.value ==
                                  governorate;

                              return CategoryChip(
                                key: ValueKey(
                                  'governorate_${governorate?.id ?? 'all'}',
                                ),
                                name: name,
                                isSelected: isSelected,
                                onTap: () {
                                  controller.selectGovernorate(governorate);
                                },
                              );
                            });
                          },
                        );
                      }),
                    ),
                  ),

                  SizedBox(height: 24.h),
                  Obx(() {
                    if (controller.isLoading.value &&
                        controller.allApartments.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const ShimmerGrid(itemCount: 4),
                      );
                    }

                    if (controller.errorMessage.value != null &&
                        controller.allApartments.isEmpty) {
                      return ErrorStateWidget(
                        message:
                            controller.errorMessage.value ??
                            'Error loading apartments'.tr,
                        onRetry: () => controller.refreshApartments(),
                        retryText: 'Retry'.tr,
                      );
                    }

                    if (controller.allItems.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.home_outlined,
                        title: 'No Apartments Found'.tr,
                        subtitle:
                            controller.searchText.value.isNotEmpty ||
                                controller.filters.isNotEmpty ||
                                controller.selectedGovernorate.value != null
                            ? 'Try adjusting your search or filters'.tr
                            : 'No apartments available at the moment'.tr,
                        actionButton:
                            (controller.searchText.value.isNotEmpty ||
                                controller.filters.isNotEmpty ||
                                controller.selectedGovernorate.value != null)
                            ? ElevatedButton(
                                onPressed: () {
                                  controller.searchText.value = '';
                                  controller.clearFilters();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryNavy,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                    vertical: 12.h,
                                  ),
                                ),
                                child: Text('Clear Filters'.tr),
                              )
                            : null,
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Apartments'.tr,
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              if (controller.total.value > 0)
                                Text(
                                  '${controller.total.value} ${'results'.tr}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12.w,
                                  mainAxisSpacing: 12.h,
                                  childAspectRatio: 0.75,
                                ),
                            itemCount:
                                controller.allItems.length +
                                (controller.hasMorePages.value ? 2 : 0),
                            itemBuilder: (context, index) {
                              if (index >= controller.allItems.length) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!controller.isLoadingMore.value) {
                                    controller.loadMoreApartments();
                                  }
                                });
                                return const ShimmerItemCard();
                              }

                              final item = controller.allItems[index];
                              return ItemCard(item: item);
                            },
                          ),
                          if (controller.hasMorePages.value &&
                              !controller.isLoadingMore.value)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 16.h,
                              ),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      controller.loadMoreApartments(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryNavy,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  child: Text('Load More'.tr),
                                ),
                              ),
                            ),
                          if (controller.isLoadingMore.value)
                            Padding(
                              padding: EdgeInsets.all(16.w),
                              child: const ShimmerGrid(itemCount: 2),
                            ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
