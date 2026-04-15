import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../storage/storage_service.dart';
import '../theme/app_theme.dart';

class ThemeController extends GetxController {
  static const String _themeModeKey = StorageKeys.themeMode;
  final _themeMode = ThemeMode.system.obs;

  ThemeMode get themeMode => _themeMode.value;
  String get themeModeString => _themeMode.value.toString().split('.').last;

  bool get isDarkMode {
    if (_themeMode.value == ThemeMode.dark) return true;
    if (_themeMode.value == ThemeMode.light) return false;
    return Get.isDarkMode;
  }

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  ThemeData get lightTheme => AppTheme.lightTheme;

  ThemeData get darkTheme => AppTheme.darkTheme;
  void _loadThemeMode() {
    try {
      final savedThemeMode = StorageService.read<String>(_themeModeKey);
      if (savedThemeMode != null && savedThemeMode.isNotEmpty) {
        final parsedMode = _parseThemeMode(savedThemeMode);
        if (parsedMode != null) {
          _themeMode.value = parsedMode;
        } else {
          _themeMode.value = ThemeMode.system;
        }
      } else {
        _themeMode.value = ThemeMode.system;
      }
      _applyThemeMode();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ ThemeController: Error loading theme mode: $e');
        debugPrint('   Falling back to system theme mode');
      }
      _themeMode.value = ThemeMode.system;
      _applyThemeMode();
    }
  }

  ThemeMode? _parseThemeMode(String mode) {
    if (mode.isEmpty) return null;

    switch (mode.toLowerCase().trim()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        if (kDebugMode) {
          debugPrint('⚠️ ThemeController: Invalid theme mode: $mode');
        }
        return null;
    }
  }

  void _applyThemeMode() {
    Get.changeThemeMode(_themeMode.value);
    Get.forceAppUpdate();
  }

  Future<void> setLightMode() async {
    _themeMode.value = ThemeMode.light;
    await StorageService.write(_themeModeKey, 'light');
    _applyThemeMode();
  }

  Future<void> setDarkMode() async {
    _themeMode.value = ThemeMode.dark;
    await StorageService.write(_themeModeKey, 'dark');
    _applyThemeMode();
  }

  Future<void> setSystemMode() async {
    _themeMode.value = ThemeMode.system;
    await StorageService.write(_themeModeKey, 'system');
    _applyThemeMode();
  }

  Future<void> toggleTheme() async {
    if (_themeMode.value == ThemeMode.light) {
      await setDarkMode();
    } else if (_themeMode.value == ThemeMode.dark) {
      await setLightMode();
    } else {
      if (Get.isDarkMode) {
        await setLightMode();
      } else {
        await setDarkMode();
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    await StorageService.write(_themeModeKey, themeModeString);
    _applyThemeMode();
  }
}
