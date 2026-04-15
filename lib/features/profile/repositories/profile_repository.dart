import 'package:get/get.dart';
import 'package:my_havenly_application/core/models/user_model.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/profile/services/profile_api_service.dart';

class ProfileRepository {
  final ProfileApiService _apiService = Get.find<ProfileApiService>();
  Future<UserModel> getProfile() async {
    try {
      return await _apiService.getProfile();
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to get profile: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? username,
    String? dateOfBirth,
    int? idPhoto,
    int? personalPhoto,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (firstName != null && firstName.isNotEmpty) {
        data['first_name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        data['last_name'] = lastName;
      }
      if (phone != null && phone.isNotEmpty) {
        data['phone'] = phone;
      }
      if (username != null && username.isNotEmpty) {
        data['username'] = username;
      }
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        data['date_of_birth'] = dateOfBirth;
      }
      if (idPhoto != null) {
        data['id_photo'] = idPhoto;
      }
      if (personalPhoto != null) {
        data['personal_photo'] = personalPhoto;
      }

      if (data.isEmpty) {
        throw ValidationException(
          message: 'At least one field must be provided for update',
          errors: {},
        );
      }

      return await _apiService.updateProfile(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to update profile: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
