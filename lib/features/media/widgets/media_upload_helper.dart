import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/models/media_model.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/media/repositories/media_repository.dart';

class MediaUploadHelper {
  final MediaRepository _repository = Get.find<MediaRepository>();

  Future<MediaModel> uploadSingle({
    required File file,
    required String type,
    required String forType,
    ValueChanged<double>? onProgress,
  }) async {
    try {
      return await _repository.uploadSingle(
        file: file,
        type: type,
        forType: forType,
        onSendProgress: onProgress != null
            ? (sent, total) {
                onProgress(sent / total);
              }
            : null,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
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
    ValueChanged<double>? onProgress,
  }) async {
    try {
      return await _repository.uploadMultiple(
        files: files,
        types: types,
        forTypes: forTypes,
        onSendProgress: onProgress != null
            ? (sent, total) {
                onProgress(sent / total);
              }
            : null,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Multiple media upload failed: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
