import 'package:get/get.dart';
import 'package:my_havenly_application/features/main/controllers/main_navigation_controller.dart';
import 'package:my_havenly_application/features/home/bindings/home_binding.dart';
import 'package:my_havenly_application/features/apartments/bindings/apartments_binding.dart';
import 'package:my_havenly_application/features/favorites/bindings/favorites_binding.dart';
import 'package:my_havenly_application/features/reservations/bindings/reservations_binding.dart';
import 'package:my_havenly_application/features/owner/owner_binding.dart';
import 'package:my_havenly_application/features/notifications/bindings/notifications_binding.dart';
import 'package:my_havenly_application/features/profile/bindings/profile_binding.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    final apartmentsBinding = ApartmentsBinding();
    apartmentsBinding.dependencies();

    final homeBinding = HomeBinding();
    homeBinding.dependencies();

    final favoritesBinding = FavoritesBinding();
    favoritesBinding.dependencies();

    final reservationsBinding = ReservationsBinding();
    reservationsBinding.dependencies();

    final ownerBinding = OwnerBinding();
    ownerBinding.dependencies();

    final notificationsBinding = NotificationsBinding();
    notificationsBinding.dependencies();

    final profileBinding = ProfileBinding();
    profileBinding.dependencies();

    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
  }
}
