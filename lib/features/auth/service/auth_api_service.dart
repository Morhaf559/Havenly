import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
/* import 'package:get/get_connect/http/src/multipart/form_data.dart'
    hide FormData;
import 'package:get/get_connect/http/src/multipart/multipart_file.dart'
    hide MultipartFile; */
import 'package:get_storage/get_storage.dart';
import 'package:my_havenly_application/features/auth/model/auth_response_model.dart';
import 'package:my_havenly_application/features/auth/model/image_id_upload_model.dart';

/// Centralized API service for authentication using Dio
/// All methods are static for global accessibility
class AuthApiService {
  // Base URL for API
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Storage instance for token persistence
  static final GetStorage _storage = GetStorage();

  // Dio instance (singleton pattern)
  static Dio? _dio;

  /// Get or create Dio instance with default configuration
  static Dio get _dioInstance {
    _dio ??= Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Accept-Language': Get.locale?.languageCode ?? 'ar',
        },
      ),
    );

    // Add interceptor to include auth token in requests
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept-Language'] =
              Get.locale?.languageCode ?? 'ar'; //////
          final token = _storage.read<String>('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );

    return _dio!;
  }

  /// Upload image to media endpoint
  /// Returns ImageIdUploadModel with the uploaded image ID
  static Future<ImageIdUploadModel> uploadImage({
    required File imageFile,
    required String imageType,
    required String imageFor,
  }) async {
    try {
      final formData = FormData.fromMap({
        'medium': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last.split('\\').last,
        ),
        'type': imageType,
        'for': imageFor,
      });

      final response = await _dioInstance.post(
        '/media',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) {
          throw Exception('Image upload failed: Empty response from server');
        }
        return ImageIdUploadModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data?['message'] ?? 'Image upload failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        final errorMessage = errorData is Map
            ? (errorData['message'] ??
                  errorData['errors'] ??
                  'Image upload failed')
            : 'Image upload failed: ${errorData.toString()}';
        throw Exception(errorMessage.toString());
      }

      // Handle different DioException types
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server error: ${e.response?.statusCode ?? 'Unknown'}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              'Connection error: Unable to reach the server. Please check if the server is running at $baseUrl';
          break;
        default:
          errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Image upload failed: ${e.toString()}');
    }
  }

  /// Register a new user
  /// Returns AuthResponseModel with token and user data
  static Future<AuthResponseModel> register({
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
      // First, upload both images
      final idPhotoResult = await uploadImage(
        imageFile: idPhoto,
        imageType: '1',
        imageFor: 'id-photo',
      );

      final personalPhotoResult = await uploadImage(
        imageFile: personalPhoto,
        imageType: '1',
        imageFor: 'personal-photo',
      );

      // Prepare registration payload
      final registerPayload = {
        'phone': phone.trim(),
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'username': username.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'date_of_birth': dateOfBirth,
        'id_photo': idPhotoResult.id,
        'personal_photo': personalPhotoResult.id,
      };

      // Then register with the uploaded image IDs
      final response = await _dioInstance.post(
        '/auth/register',
        data: registerPayload,
      );

      // Print registration response to console
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) {
          throw Exception('Registration failed: Empty response from server');
        }

        // Parse response
        final authResponse = AuthResponseModel.fromJson(response.data);

        // Validate response
        if (authResponse.token == null || authResponse.user == null) {
          throw Exception(
            'Registration failed: Invalid response structure. Token or user missing.',
          );
        }

        // Persist authentication data
        await _storage.write('token', authResponse.token);
        await _storage.write('user', authResponse.user!.toJson());

        return authResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data?['message'] ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;

        String errorMessage;
        if (errorData is Map) {
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else if (errorData['errors'] != null) {
            // Handle validation errors
            final errors = errorData['errors'];
            if (errors is Map) {
              errorMessage = errors.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', ');
            } else {
              errorMessage = errors.toString();
            }
          } else {
            errorMessage = 'Registration failed';
          }
        } else {
          errorMessage = 'Registration failed: ${errorData.toString()}';
        }
        throw Exception(errorMessage);
      }

      // Handle different DioException types
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server error: ${e.response?.statusCode ?? 'Unknown'}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              'Connection error: Unable to reach the server. Please check if the server is running at $baseUrl';
          break;
        default:
          errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Login with phone and password
  /// Returns AuthResponseModel with token and user data
  static Future<AuthResponseModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final loginPayload = {'phone': phone.trim(), 'password': password};

      final response = await _dioInstance.post(
        '/auth/login',
        data: loginPayload,
      );

      // Print login response to console
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) {
          throw Exception('Login failed: Empty response from server');
        }

        // Parse response
        final authResponse = AuthResponseModel.fromJson(response.data);

        // Validate response
        if (authResponse.token == null || authResponse.user == null) {
          throw Exception(
            'Login failed: Invalid response structure. Token or user missing.',
          );
        }

        // Persist authentication data
        await _storage.write('token', authResponse.token);
        await _storage.write('user', authResponse.user!.toJson());

        return authResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: response.data?['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;

        String errorMessage;
        if (errorData is Map) {
          if (errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          } else if (errorData['errors'] != null) {
            // Handle validation errors
            final errors = errorData['errors'];
            if (errors is Map) {
              errorMessage = errors.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join(', ');
            } else {
              errorMessage = errors.toString();
            }
          } else {
            errorMessage = 'Login failed';
          }
        } else {
          errorMessage = 'Login failed: ${errorData.toString()}';
        }
        throw Exception(errorMessage);
      }

      // Handle different DioException types
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Server error: ${e.response?.statusCode ?? 'Unknown'}';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Request was cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              'Connection error: Unable to reach the server. Please check if the server is running at $baseUrl';
          break;
        default:
          errorMessage = 'Network error: ${e.message ?? 'Unknown error'}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Get stored token from local storage
  static String? getStoredToken() {
    return _storage.read<String>('token');
  }

  /// Get stored user from local storage
  static Map<String, dynamic>? getStoredUser() {
    return _storage.read<Map<String, dynamic>>('user');
  }

  /// Clear authentication data from storage
  static Future<void> clearAuthData() async {
    await _storage.remove('token');
    await _storage.remove('user');
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    final token = getStoredToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool?> logout() async {
    try {
      final response = await _dioInstance.post('/auth/logout');
      if (response.statusCode == 200 || response.statusCode == 204) {
        await clearAuthData();
        return true;
      }
      return false;
    } catch (e) {
      await clearAuthData();
      return true;
    } finally {
      await clearAuthData();
    }
  }
}
