import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String errorMessage = 'An error occurred';

    if (err.response?.data != null) {
      final responseData = err.response!.data;
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            responseData['message'] as String? ??
            responseData['error'] as String? ??
            errorMessage;
      } else if (responseData is String) {
        errorMessage = responseData;
      }
    } else {
      errorMessage = err.message ?? errorMessage;
    }

    final apiException = ExceptionHelper.fromDioException(err);
    if (errorMessage != 'An error occurred' &&
        errorMessage != apiException.message) {
      final statusCode = err.response?.statusCode;
      if (statusCode == 401) {
        final authException = AuthenticationException(
          message: errorMessage,
          statusCode: statusCode,
          originalError: err,
        );
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: err.response,
            type: err.type,
            error: authException,
            message: errorMessage,
          ),
        );
        return;
      }
    }

    if (kDebugMode) {
      debugPrint(
        '🔴 Error Interceptor: Converting DioException to ApiException',
      );
      debugPrint('   Type: ${apiException.runtimeType}');
      debugPrint('   Message: ${apiException.message}');
      if (apiException is ServerException && apiException.statusCode != null) {
        debugPrint('   Status Code: ${apiException.statusCode}');
      }
    }
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        message: apiException.message,
      ),
    );
  }
}
