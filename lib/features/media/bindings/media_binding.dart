import 'package:get/get.dart';
import 'package:my_havenly_application/features/media/repositories/media_repository.dart';
import 'package:my_havenly_application/features/media/services/media_api_service.dart';

class MediaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaApiService>(() => MediaApiService());

    Get.lazyPut<MediaRepository>(() => MediaRepository());
  }
}
