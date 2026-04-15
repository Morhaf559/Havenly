import 'package:get/get.dart';
import 'package:my_havenly_application/features/reservations/services/reservation_requests_api_service.dart';
import 'package:my_havenly_application/features/reservations/services/reservations_api_service.dart';
import 'package:my_havenly_application/features/reservations/services/reservation_modifications_api_service.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_requests_repository.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservations_repository.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_modifications_repository.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_request_controller.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_controller.dart';
import 'package:my_havenly_application/features/reservations/controllers/reservation_modification_controller.dart';

class ReservationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ReservationRequestsApiService>(
      ReservationRequestsApiService(),
      permanent: true,
    );
    Get.put<ReservationsApiService>(ReservationsApiService(), permanent: true);
    Get.put<ReservationModificationsApiService>(
      ReservationModificationsApiService(),
      permanent: true,
    );

    Get.put<ReservationRequestsRepository>(
      ReservationRequestsRepository(),
      permanent: true,
    );
    Get.put<ReservationsRepository>(ReservationsRepository(), permanent: true);
    Get.put<ReservationModificationsRepository>(
      ReservationModificationsRepository(),
      permanent: true,
    );

    Get.lazyPut<ReservationRequestController>(
      () => ReservationRequestController(),
      fenix: true,
    );
    Get.lazyPut<ReservationController>(
      () => ReservationController(),
      fenix: true,
    );
    Get.lazyPut<ReservationModificationController>(
      () => ReservationModificationController(),
      fenix: true,
    );
  }
}
