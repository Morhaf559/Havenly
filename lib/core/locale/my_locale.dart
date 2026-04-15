import 'package:get/get.dart';
import 'ar_locale.dart';
import 'en_locale.dart';

 
class MyLocale implements Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': ArLocale.translations,
    'en': EnLocale.translations,
  };
}
