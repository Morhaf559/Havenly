import 'package:dio/dio.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/auth/endpoints/auth_endpoints.dart';
import 'package:my_havenly_application/features/auth/models/auth_response_model.dart';

class AuthApiService {
  Future<AuthResponseModel> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String username,
    required String password,
    required String passwordConfirmation,
    required String dateOfBirth,
    required int idPhotoId,
    required int personalPhotoId,
  }) async {
    try {
      final registerPayload = {
        'phone': phone.trim(),
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'username': username.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'date_of_birth': dateOfBirth,
        'id_photo': idPhotoId,
        'personal_photo': personalPhotoId,
      };

      final authResponse = await ApiService.post<AuthResponseModel>(
        path: AuthEndpoints.register,
        data: registerPayload,
        fromJson: (json) => AuthResponseModel.fromJson(json),
      );

      if (!authResponse.isValid) {
        throw UnknownException(
          message:
              'Registration failed: Invalid response structure. Token or user missing.',
        );
      }

      return authResponse;
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

  Future<AuthResponseModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final loginPayload = {'phone': phone.trim(), 'password': password};

      final authResponse = await ApiService.post<AuthResponseModel>(
        path: AuthEndpoints.login,
        data: loginPayload,
        fromJson: (json) => AuthResponseModel.fromJson(json),
      );

      if (!authResponse.isValid) {
        throw UnknownException(
          message:
              'Login failed: Invalid response structure. Token or user missing.',
        );
      }

      return authResponse;
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

  Future<void> resetPassword({
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await ApiService.postVoid(
        path: AuthEndpoints.resetPassword,
        data: {
          'phone': phone.trim(),
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
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

  Future<void> sendOtp(String phone) async {
    try {
      await ApiService.postVoid(
        path: AuthEndpoints.sendOtp,
        data: {'phone': phone.trim()},
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(
        message: 'Send OTP failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<AuthResponseModel> verifyOtp(String phone, String otp) async {
    try {
      final authResponse = await ApiService.post<AuthResponseModel>(
        path: AuthEndpoints.verifyOtp,
        data: {'phone': phone.trim(), 'otp': otp.trim()},
        fromJson: (json) => AuthResponseModel.fromJson(json),
      );
      return authResponse;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw UnknownException(message: e.toString());
    }
  }
}
