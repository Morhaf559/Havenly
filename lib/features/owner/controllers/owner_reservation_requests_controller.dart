import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_requests_repository.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_request_model.dart';
import 'owner_dashboard_controller.dart';

class OwnerReservationRequestsController extends BaseController {
  final RxList<ReservationRequestModel> requests =
      <ReservationRequestModel>[].obs;
  final RxList<ReservationRequestModel> allRequests =
      <ReservationRequestModel>[].obs;
  final RxString selectedFilter = 'all'.obs;
  final Rx<int?> selectedApartmentId = Rx<int?>(null);
  final RxList<int> ownerApartmentIds = <int>[].obs;

  final AuthStateController _authStateController =
      Get.find<AuthStateController>();
  final ApartmentsRepository _apartmentsRepository =
      Get.find<ApartmentsRepository>();
  final ReservationRequestsRepository _requestsRepository =
      Get.find<ReservationRequestsRepository>();

  @override
  void onInit() {
    super.onInit();
    loadOwnerReservationRequests();
  }

  Future<void> loadOwnerReservationRequests({int? apartmentIdFilter}) async {
    try {
      setLoading(true);
      clearError();

      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (userId == null) {
        throw Exception('Unable to get user ID');
      }

      final filter = ApartmentFilterModel(customFilters: {'user_id': userId});
      final apartmentsResponse = await _apartmentsRepository.getApartments(
        page: 1,
        perPage: 100,
        filters: filter,
      );

      final apartmentIds = apartmentsResponse.data
          .map((apt) => apt.id)
          .toList();
      ownerApartmentIds.value = apartmentIds;

      if (apartmentIds.isEmpty) {
        allRequests.value = [];
        requests.value = [];
        return;
      }

      final receivedRequests = await _requestsRepository
          .getReceivedReservationRequests();

      final loadedRequests = apartmentIdFilter != null
          ? receivedRequests
                .where((request) => request.apartmentId == apartmentIdFilter)
                .toList()
          : receivedRequests;

      allRequests.value = loadedRequests;

      _applyFilters();
    } catch (e) {
      setErrorFromException(e);
      allRequests.value = [];
      requests.value = [];
    } finally {
      setLoading(false);
    }
  }

  void _applyFilters() {
    List<ReservationRequestModel> filtered = List.from(allRequests);

    if (selectedFilter.value != 'all') {
      filtered = filtered.where((request) {
        return request.status?.toLowerCase() ==
            selectedFilter.value.toLowerCase();
      }).toList();
    }
    final apartmentId = selectedApartmentId.value;
    if (apartmentId != null) {
      filtered = filtered.where((request) {
        return request.apartmentId == apartmentId;
      }).toList();
    }

    requests.value = filtered;
  }

  List<ReservationRequestModel> get filteredRequests {
    return requests;
  }

  void setFilterStatus(String status) {
    selectedFilter.value = status;
    _applyFilters();
  }

  void setApartmentFilter(int? apartmentId) {
    selectedApartmentId.value = apartmentId;
    _applyFilters();
  }

  void clearApartmentFilter() {
    selectedApartmentId.value = null;
    _applyFilters();
  }

  Future<bool> acceptRequest(int requestId) async {
    try {
      setLoading(true);
      clearError();

      await _requestsRepository.acceptReservationRequest(requestId);

      await loadOwnerReservationRequests();

      _refreshDashboardStatistics();

      Get.snackbar(
        'Success'.tr,
        'Reservation request accepted'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        'Failed to accept request'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> rejectRequest(int requestId) async {
    try {
      setLoading(true);
      clearError();

      await _requestsRepository.rejectReservationRequest(requestId);
      await loadOwnerReservationRequests();

      _refreshDashboardStatistics();

      Get.snackbar(
        'Success'.tr,
        'Reservation request rejected'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        'Failed to reject request'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> refresh() async {
    final apartmentId = selectedApartmentId.value;
    await loadOwnerReservationRequests(apartmentIdFilter: apartmentId);
  }

  void _refreshDashboardStatistics() {
    try {
      if (Get.isRegistered<OwnerDashboardController>()) {
        final dashboardController = Get.find<OwnerDashboardController>();
        dashboardController.refresh();
      }
    } catch (e) {}
  }
}
