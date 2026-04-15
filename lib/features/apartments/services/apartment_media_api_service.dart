import 'dart:io';
import 'package:dio/dio.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/dio_config.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/apartments/endpoints/apartment_media_endpoints.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_photo_model.dart';

/// Apartment Media API Service
/// Low-level API service for apartment photo endpoints
/// Handles only HTTP requests, no business logic
/// 
/// Endpoints:
/// - GET /apartment/:id/photo - Get all photos
/// - POST /apartment/:id/photo - Upload photo
/// - DELETE /apartment/:id/photo/:photoId - Delete photo
/// - PUT /apartment/:id/photo/:photoId/main - Set main photo
/// - GET /apartment/:id/photo/main - Get main photo
class ApartmentMediaApiService {
  /// Get all photos for an apartment
  /// 
  /// GET /apartment/:id/photo
  /// 
  /// Returns [List<ApartmentPhotoModel>] with apartment photos
  /// Throws [ApiException] on error
  Future<List<ApartmentPhotoModel>> getPhotos(int apartmentId) async {
    try {
      return await ApiService.getList<ApartmentPhotoModel>(
        path: ApartmentMediaEndpoints.getPhotos(apartmentId),
        fromJson: (json) => ApartmentPhotoModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get apartment photos: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Upload a photo for an apartment
  /// 
  /// POST /apartment/:id/photo
  /// Body: multipart/form-data with media[0][medium], media[0][type], media[0][for]
  /// 
  /// Note: API uses array format: media[0][medium], media[0][type], media[0][for]
  /// Response: { "data": [{ ... }] } - array response
  /// 
  /// Returns [ApartmentPhotoModel] with uploaded photo info
  /// Throws [ApiException] on error
  Future<ApartmentPhotoModel> uploadPhoto(
    int apartmentId,
    File imageFile, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // Prepare form data with array format (as per API spec)
      final formData = FormData();
      
      formData.files.add(
        MapEntry(
          'media[0][medium]',
          await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last.split('\\').last,
          ),
        ),
      );
      
      formData.fields.addAll([
        MapEntry('media[0][type]', '1'), // Image type
        MapEntry('media[0][for]', 'apartment-photo'),
      ]);

      // API returns array response { "data": [{ ... }] }
      // Use DioConfig directly to handle array response
      final dio = DioConfig.instance;
      final response = await dio.post(
        '/apartment/$apartmentId/photo',
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}),
        onSendProgress: onSendProgress,
      );

      // Parse response - API returns { "data": [{ ... }] }
      // Handle response structure
      List<ApartmentPhotoModel> data;
      if (response.data is Map && response.data['data'] != null && response.data['data'] is List) {
        final dataList = response.data['data'] as List;
        data = dataList
            .map((item) => ApartmentPhotoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (response.data is List) {
        final dataList = response.data as List;
        data = dataList
            .map((item) => ApartmentPhotoModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw UnknownException(
          message: 'Invalid response format from upload API',
          originalError: null,
        );
      }

      if (data.isEmpty) {
        throw UnknownException(
          message: 'Upload response is empty',
          originalError: null,
        );
      }

      return data.first;
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to upload apartment photo: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete a photo from an apartment
  /// 
  /// DELETE /apartment/:id/photo/:photoId
  /// 
  /// Returns void on success
  /// Throws [ApiException] on error
  Future<void> deletePhoto(int apartmentId, int photoId) async {
    try {
      await ApiService.delete(
        path: '/apartment/$apartmentId/photo/$photoId',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to delete apartment photo: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Set a photo as the main photo
  /// 
  /// PUT /apartment/:id/photo/:photoId/main
  /// 
  /// Returns [ApartmentPhotoModel] with updated photo (is_main: true)
  /// Throws [ApiException] on error
  Future<ApartmentPhotoModel> setMainPhoto(int apartmentId, int photoId) async {
    try {
      return await ApiService.put<ApartmentPhotoModel>(
        path: '/apartment/$apartmentId/photo/$photoId/main',
        fromJson: (json) => ApartmentPhotoModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to set main photo: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get the main photo for an apartment
  /// 
  /// GET /apartment/:id/photo/main
  /// 
  /// Returns [ApartmentPhotoModel?] with main photo (null if not found)
  /// Throws [ApiException] on error (except NotFoundException which returns null)
  Future<ApartmentPhotoModel?> getMainPhoto(int apartmentId) async {
    try {
      return await ApiService.get<ApartmentPhotoModel>(
        path: '/apartment/$apartmentId/photo/main',
        fromJson: (json) => ApartmentPhotoModel.fromJson(json),
      );
    } on NotFoundException {
      // No main photo found - return null
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get main photo: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
