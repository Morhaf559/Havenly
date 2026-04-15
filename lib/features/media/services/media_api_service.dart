import 'dart:io';
import 'package:dio/dio.dart';
import 'package:my_havenly_application/core/models/media_model.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/dio_config.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/core/network/response_parser.dart';
import 'package:my_havenly_application/core/utils/form_data_helper.dart';
import 'package:my_havenly_application/features/media/endpoints/media_endpoints.dart';

class MediaApiService {
  Future<MediaModel> uploadSingle({
    required File file,
    required String type,
    required String forType,
    ProgressCallback? onSendProgress,
  }) async {
    try {
     
      final formData = FormDataHelper.single(
        file: file,
        fieldName: 'medium',
        fields: {
          'type': type,
          'for': forType,
        },
      );

     
      return await ApiService.post<MediaModel>(
        path: MediaEndpoints.uploadSingle,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
           
          },
        ),
        fromJson: (json) => MediaModel.fromJson(json),
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
    ProgressCallback? onSendProgress,
  }) async {
    if (files.isEmpty) {
      throw ValidationException(
        message: 'Files list cannot be empty',
        errors: {},
      );
    }

    if (types.length != files.length || forTypes.length != files.length) {
      throw ValidationException(
        message: 'types and forTypes must match files length',
        errors: {},
      );
    }

    try {
      
      final fieldsPerFile = <Map<String, dynamic>>[];
      for (int i = 0; i < files.length; i++) {
        fieldsPerFile.add({
          'type': types[i],
          'for': forTypes[i],
        });
      }

      final formData = FormDataHelper.multiple(
        files: files,
        fieldNamePattern: 'media[{{index}}][medium]',
        fieldsPerFile: fieldsPerFile,
      );

      final dio = DioConfig.instance;
      final response = await dio.post(
        MediaEndpoints.uploadMultiple,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
        onSendProgress: onSendProgress,
      );

      return ResponseParser.parseList<MediaModel>(
        responseData: response.data,
        fromJson: (json) => MediaModel.fromJson(json),
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

 Future<MediaModel> getMedia(int mediaId) async {
    try {
      return await ApiService.get<MediaModel>(
        path: MediaEndpoints.getMedia(mediaId),
        fromJson: (json) => MediaModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get media: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
