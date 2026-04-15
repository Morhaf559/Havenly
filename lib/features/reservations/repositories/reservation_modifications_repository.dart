import 'package:get/get.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/core/utils/status_enums.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_modification_model.dart';
import 'package:my_havenly_application/features/reservations/services/reservation_modifications_api_service.dart';

class ReservationModificationsRepository {
  final ReservationModificationsApiService _apiService =
      Get.find<ReservationModificationsApiService>();
  Future<List<ReservationModificationModel>> getModifications() async {
    try {
      final modifications = await _apiService.getModifications();
      return modifications
          .map((modification) => _normalizeModification(modification))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get modifications: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModificationModel>> getReceivedModifications() async {
    try {
      final modifications = await _apiService.getReceivedModifications();
      return modifications
          .map((modification) => _normalizeModification(modification))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get received modifications: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModificationModel>> getOwnerSentModifications() async {
    try {
      final modifications = await _apiService.getOwnerSentModifications();
      return modifications
          .map((modification) => _normalizeModification(modification))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get owner sent modifications: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModificationModel>>
  getTenantSentModifications() async {
    try {
      final modifications = await _apiService.getTenantSentModifications();
      return modifications
          .map((modification) => _normalizeModification(modification))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get tenant sent modifications: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModificationModel>>
  getTenantReceivedModifications() async {
    try {
      final modifications = await _apiService.getTenantReceivedModifications();
      return modifications
          .map((modification) => _normalizeModification(modification))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get tenant received modifications: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModificationModel> requestModification({
    required int reservationId,
    dynamic requestedStartDate,
    dynamic requestedEndDate,
    String? note,
    bool isCancellation = false,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (isCancellation) {
        // Request cancellation
        data['type'] = ReservationModificationType.cancel;
      } else if (requestedStartDate != null && requestedEndDate != null) {
        // Request date change (both dates)
        data['type'] = ReservationModificationType.date;
        data['start_date'] = _formatDateForApi(requestedStartDate);
        data['end_date'] = _formatDateForApi(requestedEndDate);

        // Validate dates
        final startDateParsed = DateHelper.parseDate(data['start_date']);
        final endDateParsed = DateHelper.parseDate(data['end_date']);
        if (startDateParsed == null || endDateParsed == null) {
          throw ValidationException(
            message: 'Invalid date format',
            errors: {},
          );
        }
        if (!DateHelper.isValidDateRange(startDateParsed, endDateParsed)) {
          throw ValidationException(
            message: 'Start date must be before or equal to end date',
            errors: {},
          );
        }
      } else {
        // Legacy support: single date modification
        if (requestedStartDate == null && requestedEndDate == null) {
          throw ValidationException(
            message: 'At least one date (start or end) must be provided, or request cancellation',
            errors: {},
          );
        }

        String type;
        String newValueString;

        if (requestedStartDate != null) {
          type = ReservationModificationType.startDate;
          newValueString = _formatDateForApi(requestedStartDate);
        } else {
          type = ReservationModificationType.endDate;
          newValueString = _formatDateForApi(requestedEndDate);
        }

        final parsedDate = DateHelper.parseDate(newValueString);
        if (parsedDate == null) {
          throw ValidationException(
            message: 'Invalid date format',
            errors: {},
          );
        }

        data['type'] = type;
        data['new_value'] = newValueString;
      }

      if (note != null && note.isNotEmpty) {
        data['note'] = note;
      }

      final modification = await _apiService.createModificationRequest(
        reservationId,
        data,
      );
      return _normalizeModification(modification);
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to request modification: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModificationModel> getModificationDetails(int id) async {
    try {
      final modification = await _apiService.getModificationDetails(id);
      return _normalizeModification(modification);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get modification details: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModificationModel>> getReservationModifications(
    int reservationId,
  ) async {
    try {
      final modifications = await _apiService.getReservationModifications(
        reservationId,
      );
      return modifications
          .map((modification) => _normalizeModification(modification))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get reservation modifications: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModificationModel> acceptModification(int id) async {
    try {
      final modification = await _apiService.acceptModification(id);
      return _normalizeModification(modification);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to accept modification: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModificationModel> rejectModification(int id) async {
    try {
      final modification = await _apiService.rejectModification(id);
      return _normalizeModification(modification);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to reject modification: ${e.toString()}',
        originalError: e,
      );
    }
  }

  ReservationModificationModel _normalizeModification(
    ReservationModificationModel modification,
  ) {
    return modification;
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
