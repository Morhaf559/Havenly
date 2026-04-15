import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../controllers/locale_controller.dart';

class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final localeController = Get.find<LocaleController>();
      final languageCode = localeController.currentLanguageCode;
      options.headers['Accept-Language'] = languageCode;

      if (kDebugMode) {
        debugPrint('🌐 Language Interceptor: Accept-Language = $languageCode');
        debugPrint('   Endpoint: ${options.method} ${options.uri}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Language Interceptor: LocaleController not found, defaulting to Arabic',
        );
      }
      options.headers['Accept-Language'] = 'ar';
    }

    super.onRequest(options, handler);
  }
}
