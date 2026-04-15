import 'package:get/get.dart';
import 'package:my_havenly_application/features/notifications/services/notifications_api_service.dart';
import 'package:my_havenly_application/features/notifications/repositories/notifications_repository.dart';
import 'package:my_havenly_application/features/notifications/controllers/notifications_controller.dart';
import 'package:my_havenly_application/features/notifications/controllers/notification_badge_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsApiService>(() => NotificationsApiService());

    Get.lazyPut<NotificationsRepository>(() => NotificationsRepository());

    Get.lazyPut<NotificationsController>(() => NotificationsController());

    Get.put<NotificationBadgeController>(NotificationBadgeController(), permanent: true);
  }
}
