import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_request_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_requests_repository.dart';

class ReservationRequestController extends BaseController {
  final ReservationRequestsRepository _repository =
      Get.find<ReservationRequestsRepository>();

  final RxList<ReservationRequestModel> requests =
      <ReservationRequestModel>[].obs;
  final RxString selectedStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSentReservationRequests();
  }

  Future<void> fetchReservationRequests() async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getReservationRequests();
      requests.value = result;
    } catch (e) {
      handleError(e, title: 'Error loading reservation requests');
    } finally {
      setLoading(false);
    }
  }

  Future<void> fetchSentReservationRequests() async {
    try {
      setLoading(true);
      clearError();

      final result = await _repository.getSentReservationRequests();
      requests.value = result;
    } catch (e) {
      handleError(e, title: 'Error loading reservation requests');
    } finally {
      setLoading(false);
    }
  }

  List<ReservationRequestModel> get filteredRequests {
    if (selectedStatus.value == 'all') {
      return requests;
    }
    return requests.where((request) {
      return request.status?.toLowerCase() ==
          selectedStatus.value.toLowerCase();
    }).toList();
  }

  Future<bool> createReservationRequest({
    required int apartmentId,
    required dynamic startDate,
    required dynamic endDate,
    String? note,
  }) async {
    try {
      setLoading(true);
      clearError();

      await _repository.createReservationRequest(
        apartmentId: apartmentId,
        startDate: startDate,
        endDate: endDate,
        note: note,
      );

      await fetchSentReservationRequests();
      return true;
    } catch (e) {
      handleError(e, title: 'Error creating reservation request');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> updateReservationRequest({
    required int id,
    int? apartmentId,
    dynamic startDate,
    dynamic endDate,
    String? note,
  }) async {
    try {
      setLoading(true);
      clearError();

      await _repository.updateReservationRequest(
        id: id,
        apartmentId: apartmentId,
        startDate: startDate,
        endDate: endDate,
        note: note,
      );

      await fetchSentReservationRequests();
      return true;
    } catch (e) {
      handleError(e, title: 'Error updating reservation request');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> cancelReservationRequest(int id) async {
    try {
      setLoading(true);
      clearError();

      await _repository.cancelReservationRequest(id);
      await fetchSentReservationRequests();
      return true;
    } catch (e) {
      handleError(e, title: 'Error cancelling reservation request');
      return false;
    } finally {
      setLoading(false);
    }
  }

  void setFilterStatus(String status) {
    selectedStatus.value = status;
  }

  @override
  Future<void> refresh() async {
    await fetchSentReservationRequests();
  }
}
