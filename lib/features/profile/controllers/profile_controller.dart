import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/core/models/user_model.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/profile/repositories/profile_repository.dart';

class ProfileController extends BaseController {
  final ProfileRepository _repository = Get.find<ProfileRepository>();
  final AuthStateController _authStateController =
      Get.find<AuthStateController>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = _authStateController.user;
    ever(_authStateController.isLoggedInRx, (bool isLoggedIn) {
      if (isLoggedIn) {
        user.value = _authStateController.user;
      } else {
        user.value = null;
      }
    });
    ever(_authStateController.userRx, (UserModel? updatedUser) {
      if (updatedUser != null) {
        user.value = updatedUser;
      }
    });
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      setLoading(true);
      clearError();

      final profile = await _repository.getProfile();

      user.value = profile;

      _authStateController.updateUser(profile);
    } catch (e) {
      handleError(e, title: 'Error loading profile');
    } finally {
      setLoading(false);
    }
  }

  @override
  Future<void> refresh() async {
    await loadProfile();
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void navigateToEdit() {
    Get.toNamed(AppRoutes.profileEdit);
  }

  Future<void> logout() async {
    try {
      final authStateController = Get.find<AuthStateController>();
      await authStateController.logout();
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to logout: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
