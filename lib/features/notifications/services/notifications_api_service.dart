import 'package:my_havenly_application/core/models/api_response.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/features/notifications/endpoints/notifications_endpoints.dart';
import 'package:my_havenly_application/features/notifications/models/notification_model.dart';

class NotificationsApiService {
  Future<ApiResponse<NotificationModel>> getNotifications({
    int? page,
    int? perPage,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (page != null) queryParameters['page'] = page;
    if (perPage != null) queryParameters['perPage'] = perPage;

    return await ApiService.getPaginated<NotificationModel>(
      path: NotificationsEndpoints.list,
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      fromJson: (json) => NotificationModel.fromJson(json),
    );
  }

   Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.get<Map<String, dynamic>>(
        path: NotificationsEndpoints.unreadCount,
        fromJson: (json) => json,
      );

      return response['unread_count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead() async {
    await ApiService.postVoid(
      path: NotificationsEndpoints.markAsRead,
    );
  }
}
