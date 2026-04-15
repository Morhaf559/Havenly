import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_photo_model.dart';
import 'package:my_havenly_application/features/apartments/services/apartment_media_api_service.dart';

/// Apartment Media Repository
/// Business logic layer for apartment photo operations
/// Isolates apartment-specific photo logic from general media operations
/// 
/// Responsibilities:
/// - Upload apartment photos
/// - Delete apartment photos
/// - Set main photo
/// - Get photos and main photo
/// - Coordinate between ApartmentMediaApiService and controllers
/// 
/// Architectural Principle:
/// - Reuses ApartmentMediaApiService (isolated API layer)
/// - Handles business logic for apartment photos
/// - Controllers receive clean, typed data
class ApartmentMediaRepository {
  final ApartmentMediaApiService _apiService = Get.find<ApartmentMediaApiService>();

  /// Get all photos for an apartment
  /// 
  /// [apartmentId] - Apartment ID
  /// 
  /// Returns [List<ApartmentPhotoModel>] with apartment photos
  /// Throws [ApiException] on error
  Future<List<ApartmentPhotoModel>> getPhotos(int apartmentId) async {
    try {
      return await _apiService.getPhotos(apartmentId);
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
  /// [apartmentId] - Apartment ID
  /// [imageFile] - Image file to upload
  /// [onSendProgress] - Optional progress callback
  /// 
  /// Returns [ApartmentPhotoModel] with uploaded photo info
  /// Throws [ApiException] on error
  Future<ApartmentPhotoModel> uploadPhoto(
    int apartmentId,
    File imageFile, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _apiService.uploadPhoto(
        apartmentId,
        imageFile,
        onSendProgress: onSendProgress,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to upload apartment photo: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Upload multiple photos for an apartment
  /// 
  /// [apartmentId] - Apartment ID
  /// [imageFiles] - List of image files to upload
  /// [onSendProgress] - Optional progress callback
  /// 
  /// Returns [List<ApartmentPhotoModel>] with uploaded photos info
  /// Throws [ApiException] on error
  Future<List<ApartmentPhotoModel>> uploadMultiplePhotos(
    int apartmentId,
    List<File> imageFiles, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final results = <ApartmentPhotoModel>[];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        
        // Calculate progress for multiple files
        ProgressCallback? progressCallback;
        if (onSendProgress != null) {
          progressCallback = (sent, total) {
            // Calculate overall progress across all files
            final overallSent = (i * total) + sent;
            final overallTotal = imageFiles.length * total;
            onSendProgress(overallSent, overallTotal);
          };
        }
        
        final photo = await _apiService.uploadPhoto(
          apartmentId,
          file,
          onSendProgress: progressCallback,
        );
        results.add(photo);
      }
      
      return results;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to upload apartment photos: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete a photo from an apartment
  /// 
  /// [apartmentId] - Apartment ID
  /// [photoId] - Photo ID
  /// 
  /// Returns void on success
  /// Throws [ApiException] on error
  Future<void> deletePhoto(int apartmentId, int photoId) async {
    try {
      await _apiService.deletePhoto(apartmentId, photoId);
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
  /// [apartmentId] - Apartment ID
  /// [photoId] - Photo ID
  /// 
  /// Returns [ApartmentPhotoModel] with updated photo (is_main: true)
  /// Throws [ApiException] on error
  Future<ApartmentPhotoModel> setMainPhoto(int apartmentId, int photoId) async {
    try {
      return await _apiService.setMainPhoto(apartmentId, photoId);
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
  /// [apartmentId] - Apartment ID
  /// 
  /// Returns [ApartmentPhotoModel?] with main photo (null if not found)
  /// Throws [ApiException] on error (except NotFoundException which returns null)
  Future<ApartmentPhotoModel?> getMainPhoto(int apartmentId) async {
    try {
      return await _apiService.getMainPhoto(apartmentId);
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

  /// Get all photos and main photo (convenience method)
  /// 
  /// [apartmentId] - Apartment ID
  /// 
  /// Returns [Map] with 'photos' and 'mainPhoto' keys
  /// Throws [ApiException] on error
  Future<Map<String, dynamic>> getPhotosWithMain(int apartmentId) async {
    try {
      final results = await Future.wait([
        getPhotos(apartmentId),
        getMainPhoto(apartmentId),
      ]);

      return {
        'photos': results[0] as List<ApartmentPhotoModel>,
        'mainPhoto': results[1] as ApartmentPhotoModel?,
      };
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get apartment photos: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
