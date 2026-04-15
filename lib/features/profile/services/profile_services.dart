import '../models/profile_model.dart';
import '../../../core/network/api_service.dart';

class ProfileService {
  Future<UserProfile> getProfile() async {
    try {
      return await ApiService.get<UserProfile>(
        path: '/auth/me',
        fromJson: (json) => UserProfile.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int?> getUserId() async {
    try {
      final profile = await getProfile();
      return profile.id;
    } catch (e) {
      return null;
    }
  }
}
