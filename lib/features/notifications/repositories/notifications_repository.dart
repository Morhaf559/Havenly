import 'package:my_havenly_application/core/models/api_response.dart';
import 'package:my_havenly_application/features/notifications/models/notification_model.dart';
import 'package:my_havenly_application/features/notifications/services/notifications_api_service.dart';

class NotificationsRepository {
  final NotificationsApiService _apiService;

  NotificationsRepository({NotificationsApiService? apiService})
      : _apiService = apiService ?? NotificationsApiService();

 Future<ApiResponse<NotificationModel>> getNotifications({
    int page = 1,
    int perPage = 15,
  }) async {
    return await _apiService.getNotifications(
      page: page,
      perPage: perPage,
    );
  }

 
  Future<int> getUnreadCount() async {
    return await _apiService.getUnreadCount();
  }

  
  Future<void> markAsRead() async {
    await _apiService.markAsRead();
  }
}
