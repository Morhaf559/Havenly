import 'package:get/get.dart';
import 'package:my_havenly_application/features/favorites/services/favorites_api_service.dart';
import 'package:my_havenly_application/features/favorites/repositories/favorites_repository.dart';
import 'package:my_havenly_application/features/favorites/controllers/favorite_controller.dart';

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoritesApiService>(
      () => FavoritesApiService(),
      fenix: true,
    );

    Get.lazyPut<FavoritesRepository>(
      () => FavoritesRepository(),
      fenix: true,
    );

    Get.lazyPut<FavoritesController>(
      () => FavoritesController(),
      fenix: true,
    );
  }
}
