import 'package:get/get.dart';
import 'controllers/owner_dashboard_controller.dart';
import 'controllers/owner_properties_controller.dart';
import 'controllers/owner_reservation_requests_controller.dart';
import 'controllers/owner_active_reservations_controller.dart';
import 'controllers/owner_reservation_modifications_controller.dart';
import '../reservations/bindings/reservations_binding.dart';
import '../apartments/bindings/apartments_binding.dart';

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    final apartmentsBinding = ApartmentsBinding();
    apartmentsBinding.dependencies();
    final reservationsBinding = ReservationsBinding();
    reservationsBinding.dependencies();

    Get.lazyPut<OwnerDashboardController>(() => OwnerDashboardController());
    Get.lazyPut<OwnerPropertiesController>(() => OwnerPropertiesController());
    Get.lazyPut<OwnerReservationRequestsController>(
      () => OwnerReservationRequestsController(),
    );
    Get.lazyPut<OwnerActiveReservationsController>(
      () => OwnerActiveReservationsController(),
    );
    Get.lazyPut<OwnerReservationModificationsController>(
      () => OwnerReservationModificationsController(),
    );
  }
}
