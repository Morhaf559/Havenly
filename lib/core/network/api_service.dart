import 'package:dio/dio.dart';
import 'package:my_havenly_application/core/models/api_response.dart';
import 'package:my_havenly_application/core/network/dio_config.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/core/network/response_parser.dart';

class ApiService {
  static final Dio _dio = DioConfig.instance;
  // get requests
  static Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return ResponseParser.parseSingle<T>(
            responseData: response.data,
            fromJson: fromJson,
          ) ??
          (throw UnknownException(
            message: 'Failed to parse response',
            originalError: 'Response data is null or invalid',
          ));
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  static Future<List<T>> getList<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return ResponseParser.parseList<T>(
        responseData: response.data,
        fromJson: fromJson,
      );
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  static Future<ApiResponse<T>> getPaginated<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return ResponseParser.parsePaginated<T>(
        responseData: response.data,
        fromJson: fromJson,
      );
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  //post requests
  static Future<T> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.statusCode == 204 || response.data == null) {
        throw UnknownException(
          message: 'No response data received',
          statusCode: response.statusCode,
        );
      }

      return ResponseParser.parseSingle<T>(
            responseData: response.data,
            fromJson: fromJson,
          ) ??
          (throw UnknownException(
            message: 'Failed to parse response',
            statusCode: response.statusCode,
          ));
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  static Future<void> postVoid({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return;
      } else {
        throw ServerException(
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // update req
  static Future<T> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.statusCode == 204 || response.data == null) {
        throw UnknownException(
          message: 'No response data received',
          statusCode: response.statusCode,
        );
      }

      return ResponseParser.parseSingle<T>(
            responseData: response.data,
            fromJson: fromJson,
          ) ??
          (throw UnknownException(
            message: 'Failed to parse response',
            statusCode: response.statusCode,
          ));
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  static Future<void> putVoid({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return;
      } else {
        throw ServerException(
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }
  // delete req

  static Future<void> delete({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.statusCode != null &&
          (response.statusCode == 200 ||
              response.statusCode == 204 ||
              (response.statusCode! >= 200 && response.statusCode! < 300))) {
        return;
      } else {
        throw ServerException(
          message: 'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  static Future<T> patch<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode == 204 || response.data == null) {
        throw UnknownException(
          message: 'No response data received',
          statusCode: response.statusCode,
        );
      }

      return ResponseParser.parseSingle<T>(
            responseData: response.data,
            fromJson: fromJson,
          ) ??
          (throw UnknownException(
            message: 'Failed to parse response',
            statusCode: response.statusCode,
          ));
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }
  // upload req

  static Future<T> uploadFile<T>({
    required String path,
    required String filePath,
    String fieldName = 'medium',
    Map<String, dynamic>? fields,
    ProgressCallback? onSendProgress,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final formData = FormData();
      formData.files.add(
        MapEntry(fieldName, await MultipartFile.fromFile(filePath)),
      );
      if (fields != null) {
        formData.fields.addAll(
          fields.entries.map((e) => MapEntry(e.key, e.value.toString())),
        );
      }

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options ?? Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return ResponseParser.parseSingle<T>(
              responseData: response.data,
              fromJson: fromJson,
            ) ??
            (throw UnknownException(
              message: 'Failed to parse upload response',
              statusCode: response.statusCode,
            ));
      } else {
        throw ServerException(
          message: 'Upload failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  static Future<T> uploadFiles<T>({
    required String path,
    required Map<String, String> files,
    Map<String, dynamic>? fields,
    ProgressCallback? onSendProgress,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final formData = FormData();

      for (final entry in files.entries) {
        formData.files.add(
          MapEntry(entry.key, await MultipartFile.fromFile(entry.value)),
        );
      }

      if (fields != null) {
        formData.fields.addAll(
          fields.entries.map((e) => MapEntry(e.key, e.value.toString())),
        );
      }

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options ?? Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return ResponseParser.parseSingle<T>(
              responseData: response.data,
              fromJson: fromJson,
            ) ??
            (throw UnknownException(
              message: 'Failed to parse upload response',
              statusCode: response.statusCode,
            ));
      } else {
        throw ServerException(
          message: 'Upload failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }

  static Future<T> uploadFormData<T>({
    required String path,
    required FormData formData,
    ProgressCallback? onSendProgress,
    Options? options,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options ?? Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return ResponseParser.parseSingle<T>(
              responseData: response.data,
              fromJson: fromJson,
            ) ??
            (throw UnknownException(
              message: 'Failed to parse upload response',
              statusCode: response.statusCode,
            ));
      } else {
        throw ServerException(
          message: 'Upload failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ExceptionHelper.fromDioException(e);
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Unexpected error: ${e.toString()}',
        originalError: e,
      );
    }
  }
}

class QueryBuilder {
  final Map<String, dynamic> _params = {};
  QueryBuilder keyword(String? keyword) {
    if (keyword != null && keyword.isNotEmpty) {
      _params['keyword'] = keyword;
    }
    return this;
  }

  QueryBuilder pagination({int? page, int? perPage}) {
    if (page != null) {
      _params['page'] = page;
    }
    if (perPage != null) {
      _params['perPage'] = perPage;
    }
    return this;
  }

  QueryBuilder filter(String name, String operation, dynamic value) {
    final filterIndex = _getFilterCount();
    _params['filters[$filterIndex][name]'] = name;
    _params['filters[$filterIndex][operation]'] = operation;
    _params['filters[$filterIndex][value]'] = value;
    return this;
  }

  QueryBuilder order(String name, String direction) {
    final orderIndex = _getOrderCount();
    _params['orders[$orderIndex][name]'] = name;
    _params['orders[$orderIndex][direction]'] = direction;
    return this;
  }

  QueryBuilder param(String key, dynamic value) {
    _params[key] = value;
    return this;
  }

  Map<String, dynamic> build() {
    return Map<String, dynamic>.from(_params);
  }

  int _getFilterCount() {
    int count = 0;
    for (final key in _params.keys) {
      if (key.startsWith('filters[') && key.contains('][name]')) {
        count++;
      }
    }
    return count;
  }

  int _getOrderCount() {
    int count = 0;
    for (final key in _params.keys) {
      if (key.startsWith('orders[') && key.contains('][name]')) {
        count++;
      }
    }
    return count;
  }
}
