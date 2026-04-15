import 'package:my_havenly_application/core/models/user_model.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/profile/endpoints/profile_endpoints.dart';

class ProfileApiService {
  Future<UserModel> getProfile() async {
    try {
      return await ApiService.get<UserModel>(
        path: ProfileEndpoints.me,
        fromJson: (json) => UserModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get profile: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      return await ApiService.post<UserModel>(
        path: ProfileEndpoints.updateProfile,
        data: data,
        fromJson: (json) => UserModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to update profile: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
