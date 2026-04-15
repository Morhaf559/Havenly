import 'package:dio/dio.dart';
import 'package:my_havenly_application/core/config/api_config.dart';
import 'package:my_havenly_application/core/network/interceptors/auth_interceptor.dart';
import 'package:my_havenly_application/core/network/interceptors/language_interceptor.dart';
import 'package:my_havenly_application/core/network/interceptors/logging_interceptor.dart';
import 'package:my_havenly_application/core/network/interceptors/error_interceptor.dart';

class DioClient {
  static Dio? _instance;
  static Dio get instance {
    _instance ??= Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _instance!.interceptors.add(LoggingInterceptor());

    _instance!.interceptors.add(LanguageInterceptor());
    _instance!.interceptors.add(AuthInterceptor());

    _instance!.interceptors.add(ErrorInterceptor());

    return _instance!;
  }
}
