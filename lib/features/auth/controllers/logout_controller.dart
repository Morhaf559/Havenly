import 'package:get/get.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/auth/repositories/auth_repository.dart';

class LogoutController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final isLoading = false.obs;

  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _authRepository.logout();

      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Unexpected error during logout. Please try again.'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
      );

      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
  }
}
