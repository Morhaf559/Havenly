import 'package:get/get.dart';
import 'package:my_havenly_application/features/profile/controllers/profile_controller.dart';
import 'package:my_havenly_application/features/profile/controllers/profile_edit_controller.dart';
import 'package:my_havenly_application/features/profile/services/profile_api_service.dart';
import 'package:my_havenly_application/features/profile/repositories/profile_repository.dart';
import 'package:my_havenly_application/features/apartments/bindings/apartments_binding.dart';
import 'package:my_havenly_application/features/media/bindings/media_binding.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    final apartmentsBinding = ApartmentsBinding();
    apartmentsBinding.dependencies();
    final mediaBinding = MediaBinding();
    mediaBinding.dependencies();

    Get.lazyPut<ProfileApiService>(() => ProfileApiService());
    Get.lazyPut<ProfileRepository>(() => ProfileRepository());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ProfileEditController>(() => ProfileEditController());
  }
}
