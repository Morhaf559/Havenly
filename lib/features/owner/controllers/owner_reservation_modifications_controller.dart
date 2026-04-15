import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_modification_model.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_modifications_repository.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservations_repository.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'owner_dashboard_controller.dart';

class OwnerReservationModificationsController extends BaseController {
  final RxList<ReservationModificationModel> modifications =
      <ReservationModificationModel>[].obs;
  final RxList<ReservationModificationModel> allModifications =
      <ReservationModificationModel>[].obs;
  final RxString selectedFilter = 'all'.obs; // all, pending, accepted, rejected
  final RxList<int> ownerApartmentIds = <int>[].obs;
  final RxMap<int, int> reservationToApartmentMap =
      <int, int>{}.obs; // Map reservationId -> apartmentId
  final RxMap<int, ReservationModel> reservationsCache =
      <int, ReservationModel>{}.obs; // Cache reservations by ID

  final AuthStateController _authStateController =
      Get.find<AuthStateController>();
  final ApartmentsRepository _apartmentsRepository =
      Get.find<ApartmentsRepository>();
  final ReservationModificationsRepository _modificationsRepository =
      Get.find<ReservationModificationsRepository>();
  final ReservationsRepository _reservationsRepository =
      Get.find<ReservationsRepository>();

  @override
  void onInit() {
    super.onInit();
    loadModifications();
  }

  Future<void> loadModifications() async {
    try {
      setLoading(true);
      clearError();

      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (userId == null) {
        allModifications.clear();
        modifications.clear();
        ownerApartmentIds.clear();
        reservationToApartmentMap.clear();
        reservationsCache.clear();
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
        allModifications.clear();
        modifications.clear();
        reservationToApartmentMap.clear();
        reservationsCache.clear();
        return;
      }

      final receivedMods = await _modificationsRepository
          .getReceivedModifications();

      allModifications.value = receivedMods;

      final ownerReservations = await _reservationsRepository
          .getMyApartmentReservations();

      reservationToApartmentMap.clear();
      reservationsCache.clear();
      for (var reservation in ownerReservations) {
        reservationToApartmentMap[reservation.id] = reservation.apartmentId;
        reservationsCache[reservation.id] = reservation;
      }

      _applyFilters();
    } catch (e) {
      setErrorFromException(e);
      allModifications.clear();
      modifications.clear();
    } finally {
      setLoading(false);
    }
  }

  void _applyFilters() {
    List<ReservationModificationModel> filtered = allModifications;

    if (selectedFilter.value != 'all') {
      filtered = filtered.where((modification) {
        return modification.status?.toLowerCase() ==
            selectedFilter.value.toLowerCase();
      }).toList();
    }

    modifications.value = filtered;
  }

  void setFilterStatus(String status) {
    selectedFilter.value = status;
    _applyFilters();
  }

  Future<bool> acceptModification(int modificationId) async {
    try {
      setLoading(true);
      clearError();

      await _modificationsRepository.acceptModification(modificationId);

      Get.snackbar(
        'Success'.tr,
        'Modification request accepted successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

      await loadModifications();

      _refreshDashboardStatistics();

      return true;
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        errorMessage.value ?? 'Failed to accept modification request'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: Icon(Icons.error, color: Colors.white),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> rejectModification(int modificationId) async {
    try {
      setLoading(true);
      clearError();

      await _modificationsRepository.rejectModification(modificationId);

      Get.snackbar(
        'Success'.tr,
        'Modification request rejected successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.info, color: Colors.white),
      );

      await loadModifications();

      _refreshDashboardStatistics();

      return true;
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        errorMessage.value ?? 'Failed to reject modification request'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: Icon(Icons.error, color: Colors.white),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  int? getApartmentIdForModification(
    ReservationModificationModel modification,
  ) {
    return reservationToApartmentMap[modification.reservationId];
  }

  ReservationModel? getReservationForModification(
    ReservationModificationModel modification,
  ) {
    return reservationsCache[modification.reservationId];
  }

  @override
  Future<void> refresh() async {
    await loadModifications();
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
