import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_requests_repository.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservations_repository.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_modifications_repository.dart';

class OwnerDashboardController extends BaseController {
  final RxInt totalApartments = 0.obs;
  final RxInt pendingRequests = 0.obs;
  final RxInt activeReservations = 0.obs;
  final RxInt pendingModifications = 0.obs;

  final AuthStateController _authStateController =
      Get.find<AuthStateController>();
  final ApartmentsRepository _apartmentsRepository =
      Get.find<ApartmentsRepository>();
  final ReservationRequestsRepository _requestsRepository =
      Get.find<ReservationRequestsRepository>();
  final ReservationsRepository _reservationsRepository =
      Get.find<ReservationsRepository>();
  final ReservationModificationsRepository _modificationsRepository =
      Get.find<ReservationModificationsRepository>();

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      setLoading(true);
      clearError();

      await Future.wait([
        _loadTotalApartments(),
        _loadPendingRequests(),
        _loadActiveReservations(),
        _loadPendingModifications(),
      ]);
    } catch (e) {
      setErrorFromException(e);
    } finally {
      setLoading(false);
    }
  }

  Future<void> _loadTotalApartments() async {
    try {
      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (userId == null) {
        debugPrint('OwnerDashboardController: User ID is null');
        totalApartments.value = 0;
        return;
      }

      debugPrint(
        'OwnerDashboardController: Loading apartments for user_id: $userId',
      );

      final filter = ApartmentFilterModel(customFilters: {'user_id': userId});
      final response = await _apartmentsRepository.getApartments(
        page: 1,
        perPage: 100,
        filters: filter,
      );

      debugPrint(
        'OwnerDashboardController: Got ${response.data.length} apartments, total: ${response.total}',
      );

      totalApartments.value = response.total;
    } catch (e) {
      debugPrint('OwnerDashboardController: Error loading apartments: $e');
      totalApartments.value = 0;
    }
  }

  Future<void> _loadPendingRequests() async {
    try {
      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (userId == null) {
        pendingRequests.value = 0;
        return;
      }

      final receivedRequests = await _requestsRepository
          .getReceivedReservationRequests();

      pendingRequests.value = receivedRequests.length;
    } catch (e) {
      debugPrint(
        'OwnerDashboardController: Error loading reservation requests: $e',
      );
      pendingRequests.value = 0;
    }
  }

  Future<void> _loadActiveReservations() async {
    try {
      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (userId == null) {
        activeReservations.value = 0;
        return;
      }

      final ownerReservations = await _reservationsRepository
          .getMyApartmentReservations();

      final activeCount = ownerReservations.where((reservation) {
        return reservation.status == null ||
            reservation.status!.toLowerCase() == 'active' ||
            reservation.status!.toLowerCase() == 'confirmed';
      }).length;

      activeReservations.value = activeCount;
    } catch (e) {
      debugPrint(
        'OwnerDashboardController: Error loading active reservations: $e',
      );
      activeReservations.value = 0;
    }
  }

  Future<void> _loadPendingModifications() async {
    try {
      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (userId == null) {
        pendingModifications.value = 0;
        return;
      }

      final receivedModifications = await _modificationsRepository
          .getReceivedModifications();

      final pendingCount = receivedModifications.where((modification) {
        return modification.status?.toLowerCase() == 'pending';
      }).length;

      pendingModifications.value = pendingCount;
    } catch (e) {
      debugPrint(
        'OwnerDashboardController: Error loading pending modifications: $e',
      );
      pendingModifications.value = 0;
    }
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }
}
