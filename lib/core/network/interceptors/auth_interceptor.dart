import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:my_havenly_application/core/storage/storage_service.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = StorageService.read<String>(StorageKeys.token);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      if (kDebugMode) {
        debugPrint('🔐 Auth Interceptor: Token added to request');
        debugPrint('   Endpoint: ${options.method} ${options.uri}');
      }
    } else {
      if (kDebugMode && _requiresAuth(options.path)) {
        debugPrint(
          '⚠️ Auth Interceptor: No token found for endpoint: ${options.path}',
        );
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        debugPrint('🔴 Auth Interceptor: Received 401 Unauthorized');
        debugPrint(
          '   Endpoint: ${err.requestOptions.method} ${err.requestOptions.uri}',
        );
        debugPrint('   This might indicate an invalid or expired token');
      }
      StorageService.remove(StorageKeys.token);
    }

    super.onError(err, handler);
  }

  bool _requiresAuth(String path) {
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/reset-password',
    ];

    return !publicEndpoints.any((endpoint) => path.contains(endpoint));
  }
}
