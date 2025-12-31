import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleController extends GetxController {
  Locale initialLang = GetStorage().read('lang') == null
      ? Get.deviceLocale!
      : Locale(GetStorage().read('lang'));
  void ChangeLang(String CodeLang) {
    Locale locale = Locale(CodeLang);
    GetStorage().write('lang', CodeLang);
    Get.updateLocale(locale);
  }
}
