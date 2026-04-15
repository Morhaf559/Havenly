import 'package:dio/dio.dart';

abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException({required this.message, this.statusCode, this.originalError});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({
    String message = 'Network error: Please check your internet connection',
    int? statusCode,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode,
         originalError: originalError,
       );
}

class ServerException extends ApiException {
  final Map<String, dynamic>? errors;

  ServerException({
    required String message,
    int? statusCode,
    this.errors,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode,
         originalError: originalError,
       );
}

class AuthenticationException extends ServerException {
  AuthenticationException({
    String message = 'Authentication failed. Please login again.',
    int? statusCode,
    Map<String, dynamic>? errors,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode ?? 401,
         errors: errors,
         originalError: originalError,
       );
}

class AuthorizationException extends ServerException {
  AuthorizationException({
    String message = 'You do not have permission to perform this action.',
    int? statusCode,
    Map<String, dynamic>? errors,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode ?? 403,
         errors: errors,
         originalError: originalError,
       );
}

class ValidationException extends ServerException {
  ValidationException({
    required String message,
    required Map<String, dynamic> errors,
    int? statusCode,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode ?? 422,
         errors: errors,
         originalError: originalError,
       );
}

class NotFoundException extends ServerException {
  NotFoundException({
    String message = 'The requested resource was not found.',
    int? statusCode,
    Map<String, dynamic>? errors,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode ?? 404,
         errors: errors,
         originalError: originalError,
       );
}

class TimeoutException extends NetworkException {
  TimeoutException({
    String message = 'Request timeout. Please try again.',
    int? statusCode,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode,
         originalError: originalError,
       );
}

class UnknownException extends ApiException {
  UnknownException({
    String message = 'An unexpected error occurred. Please try again.',
    int? statusCode,
    dynamic originalError,
  }) : super(
         message: message,
         statusCode: statusCode,
         originalError: originalError,
       );
}

class ExceptionHelper {
  static ApiException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(originalError: error);

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.cancel:
        return NetworkException(
          message: 'Request was cancelled',
          originalError: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Connection error: Unable to reach the server',
          originalError: error,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'SSL certificate error',
          originalError: error,
        );

      case DioExceptionType.unknown:
        return UnknownException(
          message: error.message ?? 'Unknown error occurred',
          originalError: error,
        );
    }
  }

  static ApiException _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    String message = 'Server error';
    Map<String, dynamic>? errors;

    if (responseData != null) {
      if (responseData is Map<String, dynamic>) {
        message =
            responseData['message'] as String? ??
            responseData['error'] as String? ??
            'Server error';

        if (statusCode == 422 && responseData['errors'] != null) {
          errors = Map<String, dynamic>.from(responseData['errors'] as Map);
        }
      } else if (responseData is String) {
        message = responseData;
      }
    }
    switch (statusCode) {
      case 401:
        return AuthenticationException(
          message: message,
          statusCode: statusCode,
          errors: errors,
          originalError: error,
        );

      case 403:
        return AuthorizationException(
          message: message,
          statusCode: statusCode,
          errors: errors,
          originalError: error,
        );

      case 404:
        return NotFoundException(
          message: message,
          statusCode: statusCode,
          errors: errors,
          originalError: error,
        );

      case 422:
        return ValidationException(
          message: message,
          errors: errors ?? {},
          statusCode: statusCode,
          originalError: error,
        );

      default:
        return ServerException(
          message: message,
          statusCode: statusCode,
          errors: errors,
          originalError: error,
        );
    }
  }
}
