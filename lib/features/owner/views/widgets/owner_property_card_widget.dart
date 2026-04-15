import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../profile/models/property.dart';
import '../../controllers/owner_properties_controller.dart';
import '../../../reservations/repositories/reservation_requests_repository.dart';

/// Owner Property Card Widget
/// Displays a property card with image, name, location, and action buttons
/// Compatible with OwnerPropertiesController
class OwnerPropertyCardWidget extends StatefulWidget {
  final Property property;
  final OwnerPropertiesController controller;

  const OwnerPropertyCardWidget({
    super.key,
    required this.property,
    required this.controller,
  });

  @override
  State<OwnerPropertyCardWidget> createState() => _OwnerPropertyCardWidgetState();
}

class _OwnerPropertyCardWidgetState extends State<OwnerPropertyCardWidget> {
  int pendingRequestsCount = 0;
  bool isLoadingRequests = false;

  @override
  void initState() {
    super.initState();
    _loadPendingRequestsCount();
  }

  Future<void> _loadPendingRequestsCount() async {
    setState(() => isLoadingRequests = true);
    try {
      final requestsRepository = Get.find<ReservationRequestsRepository>();
      final allRequests = await requestsRepository.getReservationRequests();
      final pendingCount = allRequests.where((request) {
        return request.apartmentId == widget.property.id &&
               request.status?.toLowerCase() == 'pending';
      }).length;
      
      if (mounted) {
        setState(() {
          pendingRequestsCount = pendingCount;
          isLoadingRequests = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingRequests = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Property Image
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.borderColor,
                  width: 1,
                ),
                color: AppColors.backgroundColor,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: property.imageUrl.isNotEmpty && 
                       !property.imageUrl.contains('unsplash.com')
                    ? Image.network(
                        property.imageUrl,
                        fit: BoxFit.cover,
                        width: 120.w,
                        height: 120.h,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderImage();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120.w,
                            height: 120.h,
                            color: AppColors.backgroundColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            SizedBox(width: 16.w),

            // Property Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.name,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Pending Requests Badge
                      if (pendingRequestsCount > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '$pendingRequestsCount',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          property.location,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  // Quick Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.edit,
                          label: 'Edit'.tr,
                          onPressed: () => widget.controller.onEditPropertyPressed(property),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.visibility,
                          label: 'View'.tr,
                          onPressed: () => widget.controller.onViewPropertyDetails(property),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.photo_library,
                          label: 'Photos'.tr,
                          onPressed: () => widget.controller.onManagePhotosPressed(property),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildQuickActionButton(
                          icon: Icons.inbox,
                          label: 'Requests'.tr,
                          onPressed: () => widget.controller.onViewRequestsPressed(property),
                          badge: pendingRequestsCount > 0 ? pendingRequestsCount.toString() : null,
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

  /// Build Quick Action Button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    String? badge,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: badge != null
          ? Badge(
              label: Text(
                badge,
                style: TextStyle(fontSize: 10.sp, color: Colors.white),
              ),
              child: Icon(icon, size: 16.sp),
            )
          : Icon(icon, size: 16.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 12.sp),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        minimumSize: Size(0, 40.h),
        side: BorderSide(color: AppColors.primaryNavy.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  /// Build placeholder image when no image is available
  Widget _buildPlaceholderImage() {
    return Container(
      width: 120.w,
      height: 120.h,
      color: AppColors.backgroundColor,
      child: Icon(
        Icons.home_outlined,
        size: 48.sp,
        color: AppColors.textSecondary,
      ),
    );
  }
}

