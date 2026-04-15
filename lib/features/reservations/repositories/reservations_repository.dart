import 'package:get/get.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/core/utils/status_enums.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';
import 'package:my_havenly_application/features/reservations/services/reservations_api_service.dart';

class ReservationsRepository {
  final ReservationsApiService _apiService = Get.find<ReservationsApiService>();
  Future<List<ReservationModel>> getReservations({String? status}) async {
    try {
      final reservations = await _apiService.getReservations();

      // Filter by status if provided
      var filteredReservations = reservations;
      if (status != null && status.isNotEmpty) {
        if (!ReservationStatus.isValid(status)) {
          throw ValidationException(
            message: 'Invalid reservation status: $status',
            errors: {},
          );
        }

        filteredReservations = reservations
            .where(
              (reservation) =>
                  reservation.status?.toLowerCase() == status.toLowerCase(),
            )
            .toList();
      }

      return filteredReservations
          .map((reservation) => _normalizeReservation(reservation))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to get reservations: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModel> getReservationDetails(int id) async {
    try {
      final reservation = await _apiService.getReservationDetails(id);
      return _normalizeReservation(reservation);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get reservation details: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModel>> getActiveReservations() async {
    return getReservations(status: ReservationStatus.active);
  }

  Future<List<ReservationModel>> getCompletedReservations() async {
    return getReservations(status: ReservationStatus.completed);
  }

  Future<List<ReservationModel>> getCancelledReservations() async {
    return getReservations(status: ReservationStatus.cancelled);
  }

  Future<List<ReservationModel>> getMyApartmentReservations() async {
    try {
      final reservations = await _apiService.getMyApartmentReservations();
      return reservations
          .map((reservation) => _normalizeReservation(reservation))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to get my apartment reservations: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModel>> getMyReservations() async {
    try {
      final reservations = await _apiService.getMyReservations();
      return reservations
          .map((reservation) => _normalizeReservation(reservation))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to get my apartment reservations: ${e.toString()}',
        originalError: e,
      );
    }
  }

  ReservationModel _normalizeReservation(ReservationModel reservation) {
    return reservation;
  }
}
