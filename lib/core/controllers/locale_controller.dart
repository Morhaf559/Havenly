import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';

class LocaleController extends GetxController {
  static const String _localeKey = 'lang';

  static const Locale defaultLocale = englishLocale;

  static const Locale arabicLocale = Locale('ar', 'SY');
  static const Locale englishLocale = Locale('en', 'US');
  final _currentLocale = defaultLocale.obs;

  Locale get currentLocale => _currentLocale.value;
  String get currentLanguageCode => _currentLocale.value.languageCode;

  bool get isArabic => _currentLocale.value.languageCode == 'ar';
  bool get isEnglish => _currentLocale.value.languageCode == 'en';
  String get localeName {
    try {
      final localeCode = _currentLocale.value.languageCode;
      if (localeCode == 'ar') {
        final translations = Get.find<Translations>();
        if (translations.keys.containsKey('ar') &&
            translations.keys['ar']!.containsKey('arabic')) {
          return translations.keys['ar']!['arabic']!;
        }
        return 'العربية';
      } else if (localeCode == 'en') {
        final translations = Get.find<Translations>();
        if (translations.keys.containsKey('en') &&
            translations.keys['en']!.containsKey('english')) {
          return translations.keys['en']!['english']!;
        }
        return 'English';
      }
    } catch (e) {}

    switch (_currentLocale.value.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'English';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadLocale();
  }

  void _loadLocale() {
    try {
      final savedLocale = StorageService.read<String>(_localeKey);
      if (savedLocale != null && savedLocale.isNotEmpty) {
        final parsedLocale = _parseLocale(savedLocale);
        if (parsedLocale != null) {
          _currentLocale.value = parsedLocale;
        } else {
          _currentLocale.value = _getDeviceLocaleOrDefault();
        }
      } else {
        _currentLocale.value = _getDeviceLocaleOrDefault();
      }
      _applyLocale();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ LocaleController: Error loading locale: $e');
        debugPrint('   Falling back to default locale: English');
      }
      _currentLocale.value = defaultLocale;
      _applyLocale();
    }
  }

  Locale _getDeviceLocaleOrDefault() {
    try {
      final deviceLocale = Get.deviceLocale;
      if (deviceLocale != null) {
        final deviceLangCode = deviceLocale.languageCode.toLowerCase();
        if (deviceLangCode == 'ar') {
          return arabicLocale;
        } else if (deviceLangCode == 'en') {
          return englishLocale;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ LocaleController: Error getting device locale: $e');
      }
    }

    return defaultLocale;
  }

  Locale? _parseLocale(String localeString) {
    if (localeString.isEmpty) return null;

    switch (localeString.toLowerCase().trim()) {
      case 'ar':
      case 'ar_sy':
      case 'ar-sy':
      case 'arabic':
        return arabicLocale;
      case 'en':
      case 'en_us':
      case 'en-us':
      case 'english':
        return englishLocale;
      default:
        if (kDebugMode) {
          debugPrint('⚠️ LocaleController: Invalid locale: $localeString');
        }
        return null;
    }
  }

  void _applyLocale() {
    Get.updateLocale(_currentLocale.value);
  }

  Future<void> setArabic() async {
    _currentLocale.value = arabicLocale;
    await StorageService.write(_localeKey, 'ar');
    _applyLocale();
  }

  Future<void> setEnglish() async {
    _currentLocale.value = englishLocale;
    await StorageService.write(_localeKey, 'en');
    _applyLocale();
  }

  Future<void> toggleLocale() async {
    if (isArabic) {
      await setEnglish();
    } else {
      await setArabic();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == 'ar' || locale.languageCode == 'en') {
      _currentLocale.value = locale;
      await StorageService.write(_localeKey, locale.languageCode);
      _applyLocale();
    }
  }

  Future<void> setLocaleByCode(String languageCode) async {
    switch (languageCode.toLowerCase()) {
      case 'ar':
        await setArabic();
        break;
      case 'en':
        await setEnglish();
        break;
      default:
        break;
    }
  }

  static List<Locale> get supportedLocales => [arabicLocale, englishLocale];
}
