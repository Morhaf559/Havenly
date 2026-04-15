import 'dart:io';
import 'package:my_havenly_application/core/models/user_model.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/auth/endpoints/auth_endpoints.dart';
import 'package:my_havenly_application/features/auth/models/auth_response_model.dart';
import 'package:my_havenly_application/features/auth/services/auth_api_service.dart';
import 'package:my_havenly_application/features/media/endpoints/media_endpoints.dart';
import 'package:my_havenly_application/features/media/repositories/media_repository.dart';
import 'package:get/get.dart';

class AuthRepository {
  final AuthApiService _apiService = AuthApiService();
  final AuthStateController _authStateController =
      Get.find<AuthStateController>();
  final MediaRepository _mediaRepository = Get.find<MediaRepository>();

  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final authResponse = await _apiService.login(
        phone: phone,
        password: password,
      );

      if (authResponse.token == null || authResponse.user == null) {
        throw UnknownException(
          message: 'Login failed: Invalid response structure',
        );
      }

      await _authStateController.setAuthState(
        newToken: authResponse.token!,
        newUser: authResponse.user!,
      );

      return authResponse.user!;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Login failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<UserModel> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String username,
    required String password,
    required String passwordConfirmation,
    required String dateOfBirth,
    required File idPhoto,
    required File personalPhoto,
  }) async {
    try {
      final idPhotoMedia = await _mediaRepository.uploadSingle(
        file: idPhoto,
        type: MediaEndpoints.typeImage,
        forType: MediaEndpoints.purposeIdPhoto,
      );

      final personalPhotoMedia = await _mediaRepository.uploadSingle(
        file: personalPhoto,
        type: MediaEndpoints.typeImage,
        forType: MediaEndpoints.purposePersonalPhoto,
      );

      final authResponse = await _apiService.register(
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        username: username,
        password: password,
        passwordConfirmation: passwordConfirmation,
        dateOfBirth: dateOfBirth,
        idPhotoId: idPhotoMedia.id!,
        personalPhotoId: personalPhotoMedia.id!,
      );

      if (authResponse.token == null || authResponse.user == null) {
        throw UnknownException(
          message: 'Registration failed: Invalid response structure',
        );
      }

      await _authStateController.setAuthState(
        newToken: authResponse.token!,
        newUser: authResponse.user!,
      );

      return authResponse.user!;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Registration failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final userData = await ApiService.get<Map<String, dynamic>>(
        path: AuthEndpoints.getCurrentUser,
        fromJson: (json) => json,
      );

      Map<String, dynamic>? userJson;

      if (userData['data'] != null) {
        final data = userData['data'] as Map<String, dynamic>;
        if (data['user'] != null) {
          userJson = data['user'] as Map<String, dynamic>;
        } else {
          userJson = data;
        }
      } else if (userData['user'] != null) {
        userJson = userData['user'] as Map<String, dynamic>;
      } else {
        userJson = userData;
      }

      if (userJson.isEmpty) {
        throw UnknownException(
          message: 'Failed to parse user data from /auth/me response',
        );
      }

      final user = UserModel.fromJson(userJson);

      await _authStateController.updateUser(user);

      return user;
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to get current user: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? username,
    String? dateOfBirth,
    File? idPhoto,
    File? personalPhoto,
  }) async {
    try {
      final payload = <String, dynamic>{};

      if (firstName != null && firstName.isNotEmpty) {
        payload['first_name'] = firstName.trim();
      }
      if (lastName != null && lastName.isNotEmpty) {
        payload['last_name'] = lastName.trim();
      }
      if (username != null && username.isNotEmpty) {
        payload['username'] = username.trim();
      }
      if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
        payload['date_of_birth'] = dateOfBirth;
      }

      if (idPhoto != null) {
        final idPhotoMedia = await _mediaRepository.uploadSingle(
          file: idPhoto,
          type: MediaEndpoints.typeImage,
          forType: MediaEndpoints.purposeIdPhoto,
        );
        payload['id_photo'] = idPhotoMedia.id;
      }

      if (personalPhoto != null) {
        final personalPhotoMedia = await _mediaRepository.uploadSingle(
          file: personalPhoto,
          type: MediaEndpoints.typeImage,
          forType: MediaEndpoints.purposePersonalPhoto,
        );
        payload['personal_photo'] = personalPhotoMedia.id;
      }

      final userData = await ApiService.put<Map<String, dynamic>>(
        path: AuthEndpoints.updateProfile,
        data: payload,
        fromJson: (json) => json,
      );

      Map<String, dynamic>? userJson;

      if (userData['data'] != null) {
        final data = userData['data'] as Map<String, dynamic>;
        if (data['user'] != null) {
          userJson = data['user'] as Map<String, dynamic>;
        } else {
          userJson = data;
        }
      } else if (userData['user'] != null) {
        userJson = userData['user'] as Map<String, dynamic>;
      } else {
        userJson = userData;
      }

      if (userJson.isEmpty) {
        throw UnknownException(message: 'Failed to parse updated user data');
      }

      final updatedUser = UserModel.fromJson(userJson);

      await _authStateController.updateUser(updatedUser);

      return updatedUser;
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

  Future<void> resetPassword({
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiService.resetPassword(
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Password reset failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> logout() async {
    await _authStateController.logout();
  }

  Future<void> sendOtp(String phone) async {
    try {
      await _apiService.sendOtp(phone);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to send OTP: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<bool> verifyOtp({required String phone, required String otp}) async {
    try {
      final authResponse = await _apiService.verifyOtp(phone, otp);

      if (authResponse.user != null) {
        final String? existingToken = _authStateController.token;
        final String? tokenToUse = authResponse.token ?? existingToken;

        if (tokenToUse != null) {
          await _authStateController.setAuthState(
            newToken: tokenToUse,
            newUser: authResponse.user!,
          );
          print("OTP Verified correctly.");
          return true;
        }
      }

      print("OTP Verification failed: Server returned user as null");
      return false;
    } catch (e) {
      print("Repository Error in verifyOtp: $e");
      return false;
    }
  }
}
