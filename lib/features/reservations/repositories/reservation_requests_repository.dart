import 'package:get/get.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_request_model.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';
import 'package:my_havenly_application/features/reservations/services/reservation_requests_api_service.dart';

class ReservationRequestsRepository {
  final ReservationRequestsApiService _apiService =
      Get.find<ReservationRequestsApiService>();
  Future<List<ReservationRequestModel>> getReservationRequests() async {
    try {
      final requests = await _apiService.getReservationRequests();
      return requests.map((request) => _normalizeRequest(request)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get reservation requests: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationRequestModel>> getSentReservationRequests() async {
    try {
      final requests = await _apiService.getSentReservationRequests();
      return requests.map((request) => _normalizeRequest(request)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get sent reservation requests: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationRequestModel>> getReceivedReservationRequests() async {
    try {
      final requests = await _apiService.getReceivedReservationRequests();
      return requests.map((request) => _normalizeRequest(request)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get received reservation requests: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationRequestModel> createReservationRequest({
    required int apartmentId,
    required dynamic startDate,
    required dynamic endDate,
    String? note,
  }) async {
    try {
      final startDateString = _formatDateForApi(startDate);
      final endDateString = _formatDateForApi(endDate);

      final start = DateHelper.parseDate(startDateString);
      final end = DateHelper.parseDate(endDateString);

      if (start == null || end == null) {
        throw ValidationException(message: 'Invalid date format', errors: {});
      }

      if (!DateHelper.isValidDateRange(start, end)) {
        throw ValidationException(
          message: 'End date must be after start date',
          errors: {},
        );
      }

      final data = {
        'apartment_id': apartmentId,
        'start_date': startDateString,
        'end_date': endDateString,
        if (note != null && note.isNotEmpty) 'note': note,
      };

      final request = await _apiService.createReservationRequest(data);
      return _normalizeRequest(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to create reservation request: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationRequestModel> getReservationRequestDetails(int id) async {
    try {
      final request = await _apiService.getReservationRequestDetails(id);
      return _normalizeRequest(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get reservation request details: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationRequestModel> updateReservationRequest({
    required int id,
    int? apartmentId,
    dynamic startDate,
    dynamic endDate,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (apartmentId != null) {
        data['apartment_id'] = apartmentId;
      }

      if (startDate != null) {
        data['start_date'] = _formatDateForApi(startDate);
      }

      if (endDate != null) {
        data['end_date'] = _formatDateForApi(endDate);
      }

      if (note != null) {
        data['note'] = note;
      }

      if (data.containsKey('start_date') && data.containsKey('end_date')) {
        final start = DateHelper.parseDate(data['start_date']);
        final end = DateHelper.parseDate(data['end_date']);

        if (start != null && end != null) {
          if (!DateHelper.isValidDateRange(start, end)) {
            throw ValidationException(
              message: 'End date must be after start date',
              errors: {},
            );
          }
        }
      }

      final request = await _apiService.updateReservationRequest(id, data);
      return _normalizeRequest(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to update reservation request: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> cancelReservationRequest(int id) async {
    try {
      await _apiService.cancelReservationRequest(id);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to cancel reservation request: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModel> acceptReservationRequest(int id) async {
    try {
      final reservation = await _apiService.acceptReservationRequest(id);
      return reservation;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to accept reservation request: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationRequestModel> rejectReservationRequest(int id) async {
    try {
      final request = await _apiService.rejectReservationRequest(id);
      return _normalizeRequest(request);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to reject reservation request: ${e.toString()}',
        originalError: e,
      );
    }
  }

  ReservationRequestModel _normalizeRequest(ReservationRequestModel request) {
    return request;
  }

  String _formatDateForApi(dynamic date) {
    if (date is DateTime) {
      return DateHelper.formatForApi(date);
    } else if (date is String) {
      final parsed = DateHelper.parseDate(date);
      if (parsed != null) {
        return DateHelper.formatForApi(parsed);
      }
      return date;
    }
    throw ArgumentError('Date must be DateTime or String');
  }
}
