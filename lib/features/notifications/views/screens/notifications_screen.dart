import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/features/notifications/controllers/notifications_controller.dart';
import 'package:my_havenly_application/features/notifications/models/notification_model.dart';
import 'package:my_havenly_application/features/notifications/views/widgets/notification_empty_state.dart';
import 'package:my_havenly_application/features/notifications/views/widgets/notification_item_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات'.tr),
        actions: [
           Obx(() {
            final hasUnread = controller.notifications.any((n) => !n.isRead());
            if (hasUnread) {
              return TextButton.icon(
                onPressed: () async {
                  final success = await controller.markAllAsRead();
                  if (success) {
                    Get.snackbar(
                      'Success'.tr,
                      'All notifications marked as read'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  } else {
                    Get.snackbar(
                      'Error'.tr,
                      'Failed to mark notifications as read'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                icon: Icon(Icons.done_all, color: Colors.white, size: 20.sp),
                label: Text(
                  'Mark all as read'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value != null && controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value!,
                  style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.refresh,
                  child: Text('إعادة المحاولة'.tr),
                ),
              ],
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return const NotificationEmptyState();
        }

        final grouped = controller.getGroupedNotifications();

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            itemCount: _calculateItemCount(grouped),
            itemBuilder: (context, index) {
              return _buildGroupedItem(context, grouped, index);
            },
          ),
        );
      }),
    );
  }

  int _calculateItemCount(Map<String, List<NotificationModel>> grouped) {
    int count = 0;
    grouped.forEach((key, notifications) {
      if (notifications.isNotEmpty) {
        count += 1 + notifications.length; // 1 for header + notifications
      }
    });
    return count;
  }

  Widget _buildGroupedItem(
    BuildContext context,
    Map<String, List<NotificationModel>> grouped,
    int index,
  ) {
    int currentIndex = 0;
    
    for (final entry in grouped.entries) {
      final groupName = entry.key;
      final notifications = entry.value;
      
      if (notifications.isEmpty) continue;
      
      // Header
      if (index == currentIndex) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          color: Colors.grey[100],
          child: Text(
            _getGroupTitle(groupName),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        );
      }
      currentIndex++;
      
      // Notifications in this group
      for (int i = 0; i < notifications.length; i++) {
        if (index == currentIndex) {
          return NotificationItemWidget(notification: notifications[i]);
        }
        currentIndex++;
      }
    }
    
    return const SizedBox.shrink();
  }

  String _getGroupTitle(String key) {
    switch (key) {
      case 'Today':
        return 'اليوم';
      case 'Yesterday':
        return 'أمس';
      case 'Older':
        return 'أقدم';
      default:
        return key;
    }
  }
}

