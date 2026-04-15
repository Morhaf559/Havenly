import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/models/media_model.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/media/endpoints/media_endpoints.dart';
import 'package:my_havenly_application/features/media/services/media_api_service.dart';

class MediaRepository {
  final MediaApiService _apiService = Get.find<MediaApiService>();

  
  Future<MediaModel> uploadSingle({
    required File file,
    required String type,
    required String forType,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _apiService.uploadSingle(
        file: file,
        type: type,
        forType: forType,
        onSendProgress: onSendProgress,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Media upload failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<MediaModel>> uploadMultiple({
    required List<File> files,
    required List<String> types,
    required List<String> forTypes,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _apiService.uploadMultiple(
        files: files,
        types: types,
        forTypes: forTypes,
        onSendProgress: onSendProgress,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Multiple media upload failed: ${e.toString()}',
        originalError: e,
      );
    }
  }

   Future<MediaModel> getMedia(int mediaId) async {
    try {
      return await _apiService.getMedia(mediaId);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to get media: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<int> uploadProfileImage(File imageFile) async {
    final media = await uploadSingle(
      file: imageFile,
      type: MediaEndpoints.typeImage,
      forType: MediaEndpoints.purposePersonalPhoto,
    );
    return media.id!;
  }

  Future<int> uploadIdPhoto(File imageFile) async {
    final media = await uploadSingle(
      file: imageFile,
      type: MediaEndpoints.typeImage,
      forType: MediaEndpoints.purposeIdPhoto,
    );
    return media.id!;
  }

   Future<List<int>> uploadApartmentPhotos(List<File> imageFiles) async {
    final mediaList = await uploadMultiple(
      files: imageFiles,
      types: List.filled(imageFiles.length, MediaEndpoints.typeImage),
      forTypes: List.filled(imageFiles.length, MediaEndpoints.purposeApartmentPhoto),
    );
    return mediaList.map((m) => m.id!).whereType<int>().toList();
  }
}
