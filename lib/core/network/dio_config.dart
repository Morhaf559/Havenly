import 'package:dio/dio.dart';
import 'package:my_havenly_application/core/config/api_config.dart';
import 'package:my_havenly_application/core/network/interceptors/auth_interceptor.dart';
import 'package:my_havenly_application/core/network/interceptors/language_interceptor.dart';
import 'package:my_havenly_application/core/network/interceptors/logging_interceptor.dart';
import 'package:my_havenly_application/core/network/interceptors/error_interceptor.dart';

class DioConfig {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    dio.interceptors.add(LoggingInterceptor());

    dio.interceptors.add(LanguageInterceptor());
    dio.interceptors.add(AuthInterceptor());

    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }

  static void reset() {
    _instance = null;
  }
}
