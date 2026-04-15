import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/models/user_model.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/storage/storage_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';

class AuthStateController extends GetxController {
  static const String _tokenKey = StorageKeys.token;
  static const String _userKey = StorageKeys.user;
  final _token = RxString('');
  final _user = Rx<UserModel?>(null);
  final _isLoading = false.obs;
  String? get token => _token.value.isEmpty ? null : _token.value;
  UserModel? get user => _user.value;
  bool get isLoggedIn {
    final currentToken = token;
    return currentToken != null && currentToken.isNotEmpty && user != null;
  }

  @Deprecated(
    'Role-based access control is not used. All users can add and manage apartments.',
  )
  bool get isOwner => user?.isOwner ?? false;
  @Deprecated(
    'Role-based access control is not used. All users can add and manage apartments.',
  )
  bool get isTenant => user?.isTenant ?? false;
  bool get isLoading => _isLoading.value;
  RxBool get isLoggedInRx {
    final currentToken = token;
    return (currentToken != null && currentToken.isNotEmpty && user != null)
        .obs;
  }

  Rx<UserModel?> get userRx => _user;
  @Deprecated(
    'Role-based access control is not used. All users can add and manage apartments.',
  )
  RxBool get isOwnerRx => (user?.isOwner ?? false).obs;

  final RxBool _isStateLoaded = false.obs;
  bool get isStateLoaded => _isStateLoaded.value;

  @override
  void onInit() {
    super.onInit();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    try {
      final storedToken = StorageService.read<String>(_tokenKey);
      if (storedToken != null && storedToken.isNotEmpty) {
        _token.value = storedToken;
      } else {
        _token.value = '';
      }
      final storedUserJson = StorageService.read<Map<String, dynamic>>(
        _userKey,
      );
      if (storedUserJson != null) {
        try {
          _user.value = UserModel.fromJson(storedUserJson);
        } catch (e) {
          if (kDebugMode) {
            debugPrint('AuthStateController: Failed to parse stored user: $e');
          }
          await StorageService.remove(_userKey);
        }
      }
      _isStateLoaded.value = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthStateController: Error loading auth state: $e');
      }
      _isStateLoaded.value = true;
    }
  }

  Future<void> ensureAuthStateLoaded() async {
    if (!_isStateLoaded.value) {
      await _loadAuthState();
    }
  }

  Future<void> setAuthState({
    required String newToken,
    required UserModel newUser,
  }) async {
    try {
      _token.value = newToken.isNotEmpty ? newToken : '';
      _user.value = newUser;
      
      await StorageService.write(_tokenKey, newToken);
      await StorageService.write(_userKey, newUser.toJson());
      
      if (kDebugMode) {
        debugPrint('AuthStateController: Auth state saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthStateController: Error setting auth state: $e');
      }
      rethrow;
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    try {
      _user.value = updatedUser;
      await StorageService.write(_userKey, updatedUser.toJson());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthStateController: Error updating user: $e');
      }
      rethrow;
    }
  }

  Future<void> syncAuthState() async {
    if (!isLoggedIn) return;

    _isLoading.value = true;
    try {
      final userData = await ApiService.get<Map<String, dynamic>>(
        path: '/auth/me',
        fromJson: (json) => json,
      );
      Map<String, dynamic> userJson;
      if (userData['data'] != null) {
        final data = userData['data'] as Map<String, dynamic>;
        if (data['user'] != null) {
          userJson = data['user'] as Map<String, dynamic>;
        } else {
          userJson = data;
        }
      } else {
        userJson = userData;
      }

      final updatedUser = UserModel.fromJson(userJson);
      await updateUser(updatedUser);
    } on AuthenticationException {
      await logout();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthStateController: Error syncing auth state: $e');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> clearAuthState() async {
    try {
      _token.value = '';
      _user.value = null;
      _isStateLoaded.value = false;
      await StorageService.remove(_tokenKey);
      await StorageService.remove(_userKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthStateController: Error clearing auth state: $e');
      }
    }
  }

  Future<void> logout() async {
    try {
      _isLoading.value = true;
      try {
        await ApiService.postVoid(path: '/auth/logout');
      } catch (e) {
        if (kDebugMode) {
          debugPrint('AuthStateController: Logout API call failed: $e');
        }
      }
      await clearAuthState();
      await Future.delayed(const Duration(milliseconds: 100));
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthStateController: Error during logout: $e');
      }
      await clearAuthState();
      await Future.delayed(const Duration(milliseconds: 100));
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> validateToken() async {
    if (!isLoggedIn) {
      return false;
    }

    try {
      await ApiService.get<Map<String, dynamic>>(
        path: '/auth/me',
        fromJson: (json) => json,
      );
      return true;
    } on AuthenticationException {
      await logout();
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthStateController: Token validation error: $e');
      }
      return true;
    }
  }
}
