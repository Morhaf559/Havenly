import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/notifications/models/notification_model.dart';
import 'package:my_havenly_application/features/notifications/repositories/notifications_repository.dart';
import 'package:my_havenly_application/features/notifications/controllers/notification_badge_controller.dart';

class NotificationsController extends BaseController {
  final NotificationsRepository _repository =
      Get.find<NotificationsRepository>();
  NotificationBadgeController? _badgeController;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  int currentPage = 1;
  int lastPage = 1;
  final RxBool hasMore = true.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _badgeController = Get.find<NotificationBadgeController>();
    } catch (e) {
      _badgeController = null;
    }

    fetchNotifications();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage = 1;
        hasMore.value = true;
        setLoading(true);
        clearError();
      } else if (!hasMore.value) {
        return;
      }

      if (!refresh && isLoading.value) {
        return;
      }

      final response = await _repository.getNotifications(
        page: currentPage,
        perPage: 15,
      );

      final List<NotificationModel> fetchedNotifications = response.data;
      lastPage = response.lastPage;
      currentPage = response.page;

      if (refresh) {
        notifications.value = fetchedNotifications;
      } else {
        final currentNotificationIds = notifications.map((e) => e.id).toSet();
        final uniqueNewNotifications = fetchedNotifications
            .where((e) => !currentNotificationIds.contains(e.id))
            .toList();
        notifications.addAll(uniqueNewNotifications);
      }

      hasMore.value = currentPage < lastPage;

      _badgeController?.refreshUnreadCount();
    } catch (e) {
      handleError(e, title: 'Error loading notifications');
    } finally {
      setLoading(false);
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoading.value || isLoadingMore.value) {
      return;
    }

    isLoadingMore.value = true;
    currentPage++;
    await fetchNotifications();
  }

  @override
  Future<void> refresh() async {
    await fetchNotifications(refresh: true);
  }

  Future<bool> markAllAsRead() async {
    try {
      setLoading(true);
      clearError();

      await _repository.markAsRead();

      final now = DateTime.now();
      notifications.value = notifications.map((notification) {
        if (!notification.isRead()) {
          return NotificationModel(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            type: notification.type,
            data: notification.data,
            readAt: now,
            createdAt: notification.createdAt,
            updatedAt: now,
          );
        }
        return notification;
      }).toList();

      _badgeController?.resetUnreadCount();

      return true;
    } catch (e) {
      handleError(e, title: 'Error marking notifications as read');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Map<String, List<NotificationModel>> getGroupedNotifications() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final Map<String, List<NotificationModel>> grouped = {
      'Today': <NotificationModel>[],
      'Yesterday': <NotificationModel>[],
      'Older': <NotificationModel>[],
    };

    for (final notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notificationDate.isAtSameMomentAs(today)) {
        grouped['Today']!.add(notification);
      } else if (notificationDate.isAtSameMomentAs(yesterday)) {
        grouped['Yesterday']!.add(notification);
      } else {
        grouped['Older']!.add(notification);
      }
    }

    return grouped;
  }
}
