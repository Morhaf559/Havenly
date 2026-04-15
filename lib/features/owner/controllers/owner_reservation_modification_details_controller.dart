import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_modification_model.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_modifications_repository.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservations_repository.dart';
import 'owner_dashboard_controller.dart';

class OwnerReservationModificationDetailsController extends BaseController {
  final int modificationId;
  final Rxn<ReservationModificationModel> modification =
      Rxn<ReservationModificationModel>();
  final Rxn<ReservationModel> reservation = Rxn<ReservationModel>();

  final ReservationModificationsRepository _modificationsRepository =
      Get.find<ReservationModificationsRepository>();
  final ReservationsRepository _reservationsRepository =
      Get.find<ReservationsRepository>();

  OwnerReservationModificationDetailsController({required this.modificationId});

  @override
  void onInit() {
    super.onInit();
    // Validate modificationId before loading
    if (modificationId <= 0) {
      setError(
        'Invalid modification ID. Please select a valid modification.'.tr,
      );
      return;
    }
    loadModificationDetails();
  }

  Future<void> loadModificationDetails() async {
    try {
      setLoading(true);
      clearError();

      final modificationDetails = await _modificationsRepository
          .getModificationDetails(modificationId);
      modification.value = modificationDetails;

      if (modificationDetails.reservationId > 0) {
        try {
          final reservationDetails = await _reservationsRepository
              .getReservationDetails(modificationDetails.reservationId);
          reservation.value = reservationDetails;
        } catch (e) {
          debugPrint('Could not load reservation details: $e');
        }
      }
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        errorMessage.value ?? 'Failed to load modification details'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.actionTextColor,
      );
    } finally {
      setLoading(false);
    }
  }

  Future<bool> acceptModification() async {
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

      await Future.delayed(const Duration(milliseconds: 500));
      await loadModificationDetails();

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

  Future<bool> rejectModification() async {
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

      await loadModificationDetails();

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

  @override
  Future<void> refresh() async {
    await loadModificationDetails();
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
