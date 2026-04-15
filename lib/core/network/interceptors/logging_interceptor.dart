import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  final bool logRequest;
  final bool logResponse;
  final bool logError;
  final bool logRequestHeaders;
  final bool logResponseHeaders;
  final bool logRequestData;
  final bool logResponseData;

  LoggingInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
    this.logRequestHeaders = true,
    this.logResponseHeaders = false,
    this.logRequestData = true,
    this.logResponseData = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!logRequest || !kDebugMode) {
      super.onRequest(options, handler);
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('🌐 REQUEST [${options.method}] → ${options.uri}');
    debugPrint('───────────────────────────────────────────────────────────');

    if (logRequestHeaders && options.headers.isNotEmpty) {
      debugPrint('📋 Headers:');
      options.headers.forEach((key, value) {
        if (key.toLowerCase() == 'authorization') {
          debugPrint('   $key: Bearer ******');
        } else {
          debugPrint('   $key: $value');
        }
      });
    }

    if (logRequestData && options.data != null) {
      debugPrint('📦 Request Data:');
      if (options.data is FormData) {
        debugPrint('   FormData (multipart/form-data)');
        final formData = options.data as FormData;
        if (formData.fields.isNotEmpty) {
          debugPrint('   Fields:');
          formData.fields.forEach((entry) {
            debugPrint('     ${entry.key}: ${entry.value}');
          });
        }
        if (formData.files.isNotEmpty) {
          debugPrint('   Files: ${formData.files.length} file(s)');
          formData.files.forEach((entry) {
            debugPrint('     ${entry.key}: ${entry.value.filename ?? "file"}');
          });
        }
      } else {
        debugPrint('   ${_formatJson(options.data)}');
      }
    }

    if (options.queryParameters.isNotEmpty) {
      debugPrint('🔍 Query Parameters:');
      options.queryParameters.forEach((key, value) {
        debugPrint('   $key: $value');
      });
    }

    debugPrint('═══════════════════════════════════════════════════════════');

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!logResponse || !kDebugMode) {
      super.onResponse(response, handler);
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint(
      '✅ RESPONSE [${response.statusCode}] ← ${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    debugPrint('───────────────────────────────────────────────────────────');

    if (logResponseHeaders && response.headers.map.isNotEmpty) {
      debugPrint('📋 Response Headers:');
      response.headers.map.forEach((key, value) {
        debugPrint('   $key: ${value.join(", ")}');
      });
    }

    if (logResponseData && response.data != null) {
      debugPrint('📦 Response Data:');
      debugPrint('   ${_formatJson(response.data)}');
    }

    debugPrint('═══════════════════════════════════════════════════════════');

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!logError || !kDebugMode) {
      super.onError(err, handler);
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint(
      '❌ ERROR [${err.response?.statusCode ?? 'N/A'}] ← ${err.requestOptions.method} ${err.requestOptions.uri}',
    );
    debugPrint('───────────────────────────────────────────────────────────');

    debugPrint('🔴 Error Type: ${err.type}');
    debugPrint('🔴 Error Message: ${err.message}');

    if (err.response != null) {
      debugPrint('📦 Error Response Data:');
      debugPrint('   ${_formatJson(err.response!.data)}');
    }

    if (err.requestOptions.data != null) {
      debugPrint('📦 Request Data that caused error:');
      debugPrint('   ${_formatJson(err.requestOptions.data)}');
    }

    debugPrint('📜 Stack Trace:');
    debugPrint('   ${err.stackTrace}');

    debugPrint('═══════════════════════════════════════════════════════════');

    super.onError(err, handler);
  }

  String _formatJson(dynamic data) {
    try {
      if (data is String) {
        return data;
      } else if (data is Map || data is List) {
        const encoder = JsonEncoder.withIndent('   ');
        return encoder.convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return data.toString();
    }
  }
}
