import 'package:flutter/foundation.dart';

class ApiResponse<T> {
  final List<T> data;
  final int page;
  final int perPage;
  final int lastPage;
  final int total;

  ApiResponse({
    required this.data,
    required this.page,
    required this.perPage,
    required this.lastPage,
    required this.total,
  });
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    List<dynamic> dataList;

    if (json['data'] != null && json['data'] is List) {
      dataList = json['data'] as List<dynamic>;
    } else if (json['data'] != null && json['data'] is Map) {
      dataList = [json['data']];
    } else if (json is List) {
      dataList = json as List<dynamic>;
    } else {
      dataList = [];
    }
    final parsedData = <T>[];
    for (final item in dataList) {
      try {
        if (item is Map<String, dynamic>) {
          parsedData.add(fromJsonT(item));
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ ApiResponse: Failed to parse item: $e');
        }
      }
    }

    return ApiResponse<T>(
      data: parsedData,
      page: json['page'] as int? ?? 0,
      perPage: json['perPage'] as int? ?? json['per_page'] as int? ?? 15,
      lastPage: json['lastPage'] as int? ?? json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? parsedData.length,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'page': page,
      'perPage': perPage,
      'lastPage': lastPage,
      'total': total,
    };
  }

  bool hasMorePages() {
    return page < lastPage;
  }

  bool isEmpty() {
    return data.isEmpty;
  }
}

class ApiSingleResponse<T> {
  final T data;

  ApiSingleResponse({required this.data});
  factory ApiSingleResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    Map<String, dynamic> dataMap;

    if (json['data'] != null && json['data'] is Map) {
      dataMap = json['data'] as Map<String, dynamic>;
    } else {
      dataMap = json;
    }

    return ApiSingleResponse<T>(data: fromJsonT(dataMap));
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {'data': toJsonT(data)};
  }
}

class ApiError {
  final String message;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiError({required this.message, this.errors, this.statusCode});

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    String errorMessage = json['message'] as String? ?? 'Unknown error';
    if (json['errors'] != null) {
      final errors = json['errors'] as Map<String, dynamic>;
      if (errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          errorMessage = firstError.first.toString();
        } else if (firstError is String) {
          errorMessage = firstError;
        }
      }
    }

    return ApiError(
      message: errorMessage,
      errors: json['errors'] != null
          ? Map<String, dynamic>.from(json['errors'] as Map)
          : null,
      statusCode: statusCode ?? json['status_code'],
    );
  }
  String? getFieldError(String field) {
    if (errors == null) return null;
    final fieldErrors = errors![field];
    if (fieldErrors is List) {
      if (fieldErrors.isNotEmpty) {
        return fieldErrors.first.toString();
      }
    } else if (fieldErrors is String) {
      return fieldErrors;
    }
    return null;
  }

  bool hasValidationErrors() {
    return errors != null && errors!.isNotEmpty;
  }
}
