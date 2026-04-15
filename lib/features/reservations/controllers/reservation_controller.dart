import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/utils/status_enums.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservations_repository.dart';

class ReservationController extends BaseController {
  final ReservationsRepository _repository = Get.find<ReservationsRepository>();

  final RxList<ReservationModel> reservations = <ReservationModel>[].obs;
  final RxList<ReservationModel> allReservations = <ReservationModel>[].obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReservations();
  }

  Future<void> fetchReservations({String? statusFilter}) async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getReservations(status: statusFilter);
      allReservations.value = result;
      reservations.value = result;
    } catch (e) {
      handleError(e, title: 'Error loading reservations');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchMyReservations() async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getMyReservations();
      allReservations.value = result;
      _applyFilters(); // Apply current filter
    } catch (e) {
      handleError(e, title: 'Error loading my reservations');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getActiveReservations() async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getActiveReservations();
      allReservations.value = result;
      reservations.value = result;
      selectedStatus.value = ReservationStatus.active;
    } catch (e) {
      handleError(e, title: 'Error loading active reservations');
    } finally {
      setLoading(false);
    }
  }

  Future<void> getCompletedReservations() async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getCompletedReservations();
      allReservations.value = result;
      reservations.value = result;
      selectedStatus.value = ReservationStatus.completed;
    } catch (e) {
      handleError(e, title: 'Error loading completed reservations');
    } finally {
      setLoading(false);
    }
  }

  void _applyFilters() {
    List<ReservationModel> filtered = List.from(allReservations);

    if (selectedStatus.value != 'all') {
      filtered = filtered.where((reservation) {
        return reservation.status?.toLowerCase() ==
            selectedStatus.value.toLowerCase();
      }).toList();
    }

    reservations.value = filtered;
  }

  List<ReservationModel> get filteredReservations {
    return reservations;
  }

  Future<ReservationModel?> getReservation(int id) async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getReservationDetails(id);
      return result;
    } catch (e) {
      handleError(e, title: 'Error loading reservation details');
      return null;
    } finally {
      setLoading(false);
    }
  }

  void setFilterStatus(String status) {
    selectedStatus.value = status;
    _applyFilters();
  }

  @override
  Future<void> refresh() async {
    await fetchMyReservations();
  }
}
