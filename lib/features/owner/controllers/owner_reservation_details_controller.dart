import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservations_repository.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_modifications_repository.dart';

class OwnerReservationDetailsController extends BaseController {
  final int reservationId;
  final Rxn<ReservationModel> reservation = Rxn<ReservationModel>();
  final ReservationsRepository _reservationsRepository =
      Get.find<ReservationsRepository>();
  final ReservationModificationsRepository _modificationsRepository =
      Get.find<ReservationModificationsRepository>();

  OwnerReservationDetailsController({required this.reservationId});

  @override
  void onInit() {
    super.onInit();
    if (reservationId <= 0) {
      setError('Invalid reservation ID. Please select a valid reservation.'.tr);
      return;
    }
    loadReservationDetails();
  }

  Future<void> loadReservationDetails() async {
    try {
      setLoading(true);
      clearError();

      final reservationDetails = await _reservationsRepository
          .getReservationDetails(reservationId);
      reservation.value = reservationDetails;
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        errorMessage.value ?? 'Failed to load reservation details'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.actionTextColor,
      );
    } finally {
      setLoading(false);
    }
  }

  bool canRequestModification() {
    // Owners cannot request modifications
    return false;
  }

  Future<bool> requestModification({
    DateTime? requestedStartDate,
    DateTime? requestedEndDate,
    String? note,
    bool isCancellation = false,
  }) async {
    try {
      setLoading(true);
      clearError();

      await _modificationsRepository.requestModification(
        reservationId: reservationId,
        requestedStartDate: requestedStartDate,
        requestedEndDate: requestedEndDate,
        note: note,
        isCancellation: isCancellation,
      );

      Get.snackbar(
        'Success'.tr,
        isCancellation
            ? 'Cancellation request sent successfully'.tr
            : 'Modification request sent successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await loadReservationDetails();

      return true;
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        errorMessage.value ?? 'Failed to request modification'.tr,
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

  int calculateDays() {
    final res = reservation.value;
    if (res == null) return 0;

    try {
      final start = DateTime.parse(res.startDate);
      final end = DateTime.parse(res.endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }

  double? calculateTotalPrice() {
    final res = reservation.value;

    if (res?.totalAmount != null && res!.totalAmount! > 0) {
      return res.totalAmount;
    }

    if (res?.apartment == null) return null;

    final days = calculateDays();
    if (days <= 0) return null;

    return res!.apartment!.price * days;
  }

  @override
  Future<void> refresh() async {
    await loadReservationDetails();
  }
}
