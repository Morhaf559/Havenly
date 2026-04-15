import 'dart:async';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/notifications/repositories/notifications_repository.dart';

class NotificationBadgeController extends GetxController {
  final NotificationsRepository _repository;

  final RxInt unreadCount = 0.obs;

  Timer? _refreshTimer;

  static const Duration refreshInterval = Duration(minutes: 5);

  static const Duration extendedRefreshInterval = Duration(minutes: 15);

  int _consecutiveFailures = 0;
  bool _isNetworkAvailable = true;

  NotificationBadgeController({NotificationsRepository? repository})
    : _repository = repository ?? Get.find<NotificationsRepository>();

  @override
  void onInit() {
    super.onInit();
    refreshUnreadCount();

    startPeriodicRefresh();
  }

  @override
  void onClose() {
    stopPeriodicRefresh();
    super.onClose();
  }

  Future<void> refreshUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      unreadCount.value = count;

      _consecutiveFailures = 0;
      _isNetworkAvailable = true;

      if (_refreshTimer != null && !_isNetworkAvailable) {
        stopPeriodicRefresh();
        startPeriodicRefresh();
      }
    } on NetworkException {
      _consecutiveFailures++;
      _isNetworkAvailable = false;

      if (_consecutiveFailures >= 3 && _refreshTimer != null) {
        stopPeriodicRefresh();
        startPeriodicRefresh(useExtendedInterval: true);
      }
    } catch (_) {
      _consecutiveFailures++;
    }
  }

  void decrementUnreadCount([int amount = 1]) {
    unreadCount.value = (unreadCount.value - amount)
        .clamp(0, double.infinity)
        .toInt();
  }

  void resetUnreadCount() {
    unreadCount.value = 0;
  }

  void startPeriodicRefresh({bool useExtendedInterval = false}) {
    stopPeriodicRefresh();

    final interval = useExtendedInterval
        ? extendedRefreshInterval
        : refreshInterval;

    _refreshTimer = Timer.periodic(interval, (_) {
      refreshUnreadCount();
    });
  }

  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  bool get hasUnread => unreadCount.value > 0;

  String get unreadCountText {
    final count = unreadCount.value;
    return count > 99 ? '99+' : count.toString();
  }
}
