import 'package:get_storage/get_storage.dart';

class StorageKeys {
  static const String token = 'token';
  static const String user = 'user';
  static const String themeMode = 'theme_mode';
}

class StorageService {
  static final GetStorage _storage = GetStorage();
  static T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  static Future<void> write(String key, dynamic value) async {
    await _storage.write(key, value);
  }

  static Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  static Future<void> clear() async {
    await _storage.erase();
  }
}
