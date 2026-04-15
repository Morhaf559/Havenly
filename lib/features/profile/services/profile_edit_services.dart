import '../models/profile_model.dart';
import '../../../core/network/api_service.dart';

class ProfileEditService {
  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? username,
    String? dateOfBirth,
    int? idPhoto,
    int? personalPhoto,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      // Add fields only if provided
      if (firstName != null) body['first_name'] = firstName;
      if (lastName != null) body['last_name'] = lastName;
      if (phone != null) body['phone'] = phone;
      if (username != null) body['username'] = username;
      if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;
      if (idPhoto != null) body['id_photo'] = idPhoto;
      if (personalPhoto != null) body['personal_photo'] = personalPhoto;

      return await ApiService.post<UserProfile>(
        path: '/auth/update-profile',
        data: body,
        fromJson: (json) => UserProfile.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}
