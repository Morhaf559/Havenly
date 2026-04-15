import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservations_repository.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';

class OwnerActiveReservationsController extends BaseController {
  final RxList<ReservationModel> reservations = <ReservationModel>[].obs;
  final RxList<ReservationModel> allReservations = <ReservationModel>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final RxList<int> ownerApartmentIds = <int>[].obs;

  final AuthStateController _authStateController =
      Get.find<AuthStateController>();
  final ApartmentsRepository _apartmentsRepository =
      Get.find<ApartmentsRepository>();
  final ReservationsRepository _reservationsRepository =
      Get.find<ReservationsRepository>();

  @override
  void onInit() {
    super.onInit();
    loadOwnerReservations();
  }

  Future<void> loadOwnerReservations() async {
    try {
      setLoading(true);
      clearError();

      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (userId == null) {
        allReservations.clear();
        reservations.clear();
        ownerApartmentIds.clear();
        return;
      }

      final filter = ApartmentFilterModel(customFilters: {'user_id': userId});
      final apartmentsResponse = await _apartmentsRepository.getApartments(
        page: 1,
        perPage: 100,
        filters: filter,
      );

      ownerApartmentIds.value = apartmentsResponse.data
          .map((apt) => apt.id)
          .toList();

      if (ownerApartmentIds.isEmpty) {
        allReservations.clear();
        reservations.clear();
        return;
      }

      final ownerReservs = await _reservationsRepository
          .getMyApartmentReservations();

      allReservations.value = ownerReservs;
      _applyFilters();
    } catch (e) {
      setErrorFromException(e);
      allReservations.clear();
      reservations.clear();
    } finally {
      setLoading(false);
    }
  }

  void _applyFilters() {
    List<ReservationModel> filtered = allReservations;

    if (selectedFilter.value != 'all') {
      filtered = filtered.where((reservation) {
        return reservation.status?.toLowerCase() ==
            selectedFilter.value.toLowerCase();
      }).toList();
    }

    reservations.value = filtered;
  }

  void setFilterStatus(String status) {
    selectedFilter.value = status;
    _applyFilters();
  }

  @override
  Future<void> refresh() async {
    await loadOwnerReservations();
  }
}
