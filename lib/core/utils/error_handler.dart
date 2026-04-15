import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Error types for better error categorization
enum ErrorType {
  network,
  server,
  validation,
  unauthorized,
  forbidden,
  notFound,
  unknown,
}

/// Error Handler Utility
/// Centralized error handling for the application
class ErrorHandler {
  /// Handle DioException and return user-friendly error message
  static String handleDioException(DioException error) {
    // Handle response errors (4xx, 5xx)
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final errorData = error.response!.data;

      // Handle specific status codes
      switch (statusCode) {
        case 400:
          return _extractErrorMessage(errorData, 'Bad request. Please check your input.');
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'Access forbidden. You don\'t have permission.';
        case 404:
          return 'Resource not found.';
        case 422:
          return _extractValidationErrors(errorData);
        case 500:
          // Extract backend error message, but provide user-friendly fallback
          final backendMessage = _extractErrorMessage(errorData, '');
          if (backendMessage.isNotEmpty && 
              !backendMessage.toLowerCase().contains('undefined method') &&
              !backendMessage.toLowerCase().contains('badmethodcallexception')) {
            // Show backend message if it's user-friendly
            return backendMessage;
          }
          return 'Server error. Please try again later or contact support.';
        case 502:
        case 503:
        case 504:
          return 'Server unavailable. Please try again later.';
        default:
          return _extractErrorMessage(
            errorData,
            'Request failed with status $statusCode',
          );
      }
    }

    // Handle network errors (no response)
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network settings.';
      case DioExceptionType.badCertificate:
        return 'Certificate error. Please contact support.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badResponse:
        return 'Invalid server response.';
      default:
        return 'Network error. Please try again.';
    }
  }

  /// Extract error message from API response
  static String _extractErrorMessage(dynamic errorData, String defaultMessage) {
    if (errorData == null) return defaultMessage;

    if (errorData is Map<String, dynamic>) {
      // Try to get message field
      if (errorData['message'] != null) {
        return errorData['message'].toString();
      }

      // Try to get error field
      if (errorData['error'] != null) {
        return errorData['error'].toString();
      }

      // Try to get errors field (validation errors)
      if (errorData['errors'] != null) {
        return _extractValidationErrors(errorData);
      }
    }

    return defaultMessage;
  }

  /// Extract validation errors from API response
  static String _extractValidationErrors(dynamic errorData) {
    if (errorData == null) return 'Validation error. Please check your input.';

    if (errorData is Map<String, dynamic>) {
      final errors = errorData['errors'];
      if (errors == null) {
        // Try to get message directly
        if (errorData['message'] != null) {
          return errorData['message'].toString();
        }
        return 'Validation error. Please check your input.';
      }

      if (errors is Map) {
        // Format: { "field": ["error1", "error2"] }
        final errorMessages = <String>[];
        errors.forEach((key, value) {
          if (value is List) {
            errorMessages.addAll(value.map((e) => e.toString()));
          } else {
            errorMessages.add(value.toString());
          }
        });

        if (errorMessages.isEmpty) {
          return 'Validation error. Please check your input.';
        }

        // Return first error message (or combine if needed)
        return errorMessages.first;
      }

      if (errors is List) {
        return errors.map((e) => e.toString()).join(', ');
      }

      return errors.toString();
    }

    return 'Validation error. Please check your input.';
  }

  /// Handle generic Exception and return user-friendly error message
  static String handleException(dynamic error) {
    if (error is DioException) {
      return handleDioException(error);
    }

    if (error is Exception) {
      final errorString = error.toString();
      
      // Remove "Exception: " prefix if present
      if (errorString.startsWith('Exception: ')) {
        return errorString.substring(11);
      }
      
      return errorString;
    }

    return error.toString();
  }

  /// Get error type from DioException
  static ErrorType getErrorType(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      switch (statusCode) {
        case 401:
          return ErrorType.unauthorized;
        case 403:
          return ErrorType.forbidden;
        case 404:
          return ErrorType.notFound;
        case 422:
          return ErrorType.validation;
        case 500:
        case 502:
        case 503:
        case 504:
          return ErrorType.server;
        default:
          return ErrorType.server;
      }
    }

    // Network errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ErrorType.network;
      default:
        return ErrorType.unknown;
    }
  }

  /// Show error snackbar using GetX
  static void showErrorSnackbar(String message, {String? title}) {
    Get.snackbar(
      title ?? 'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Show error dialog using GetX
  static Future<void> showErrorDialog(String message, {String? title}) {
    return Get.dialog(
      AlertDialog(
        title: Text(title ?? 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Handle error and show snackbar
  static void handleError(dynamic error, {String? title, bool showDialog = false}) {
    final errorMessage = handleException(error);
    
    if (showDialog) {
      showErrorDialog(errorMessage, title: title);
    } else {
      showErrorSnackbar(errorMessage, title: title);
    }
  }

  /// Log error for debugging (in production, use proper logging)
  static void logError(dynamic error, {String? context}) {
    // In production, use proper logging service (e.g., Firebase Crashlytics)
    if (context != null) {
      debugPrint('Error in $context: $error');
    } else {
      debugPrint('Error: $error');
    }
  }
}
