import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_request_model.dart';
import 'package:my_havenly_application/features/reservations/repositories/reservation_requests_repository.dart';
import 'owner_dashboard_controller.dart';

class OwnerReservationRequestDetailsController extends BaseController {
  final int requestId;
  final Rxn<ReservationRequestModel> request = Rxn<ReservationRequestModel>();
  final ReservationRequestsRepository _requestsRepository =
      Get.find<ReservationRequestsRepository>();

  OwnerReservationRequestDetailsController({required this.requestId});

  @override
  void onInit() {
    super.onInit();
    // Validate requestId before loading
    if (requestId <= 0) {
      setError(
        'Invalid reservation request ID. Please select a valid request.'.tr,
      );
      return;
    }
    loadRequestDetails();
  }

  Future<void> loadRequestDetails() async {
    try {
      setLoading(true);
      clearError();

      final requestDetails = await _requestsRepository
          .getReservationRequestDetails(requestId);
      request.value = requestDetails;
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        errorMessage.value ?? 'Failed to load reservation request details'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.snackBarTheme.backgroundColor,
        colorText: Get.theme.snackBarTheme.actionTextColor,
      );
    } finally {
      setLoading(false);
    }
  }

  Future<bool> acceptRequest() async {
    try {
      setLoading(true);
      clearError();

      await _requestsRepository.acceptReservationRequest(requestId);

      Get.snackbar(
        'Success'.tr,
        'Reservation request accepted successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      await loadRequestDetails();

      _refreshDashboardStatistics();

      return true;
    } catch (e) {
      setErrorFromException(e);
      Get.snackbar(
        'Error'.tr,
        errorMessage.value ?? 'Failed to accept reservation request'.tr,
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

  Future<bool> rejectRequest() async {
    try {
      setLoading(true);
      clearError();

      await _requestsRepository.rejectReservationRequest(requestId);

      Get.snackbar(
        'Success'.tr,
        'Reservation request rejected successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: Icon(Icons.info, color: Colors.white),
      );

      await loadRequestDetails();

      _refreshDashboardStatistics();

      return true;
    } catch (e) {
      setErrorFromException(e);
      final userMessage =
          errorMessage.value ?? 'Failed to reject reservation request'.tr;
      Get.snackbar(
        'Error'.tr,
        userMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: Icon(Icons.error, color: Colors.white),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  int calculateDays() {
    final req = request.value;
    if (req == null) return 0;

    try {
      final start = DateTime.parse(req.startDate);
      final end = DateTime.parse(req.endDate);
      return end.difference(start).inDays;
    } catch (e) {
      return 0;
    }
  }

  double? calculateTotalPrice() {
    final req = request.value;

    if (req?.totalAmount != null && req!.totalAmount! > 0) {
      return req.totalAmount;
    }

    if (req?.apartment == null) return null;

    final days = calculateDays();
    if (days <= 0) return null;

    return req!.apartment!.price * days;
  }

  @override
  Future<void> refresh() async {
    await loadRequestDetails();
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
