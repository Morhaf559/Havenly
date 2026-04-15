import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/reservations/endpoints/reservations_endpoints.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_request_model.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';

class ReservationRequestsApiService {
  Future<List<ReservationRequestModel>> getReservationRequests() async {
    try {
      return await ApiService.getList<ReservationRequestModel>(
        path: ReservationsEndpoints.reservationRequestsList,
        fromJson: (json) => ReservationRequestModel.fromJson(json),
      );
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
      return await ApiService.getList<ReservationRequestModel>(
        path: ReservationsEndpoints.reservationRequestsSend,
        fromJson: (json) => ReservationRequestModel.fromJson(json),
      );
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
      return await ApiService.getList<ReservationRequestModel>(
        path: ReservationsEndpoints.reservationRequestsReceive,
        fromJson: (json) => ReservationRequestModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get received reservation requests: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationRequestModel> createReservationRequest(
    Map<String, dynamic> data,
  ) async {
    try {
      return await ApiService.post<ReservationRequestModel>(
        path: ReservationsEndpoints.reservationRequestsCreate,
        data: data,
        fromJson: (json) => ReservationRequestModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to create reservation request: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationRequestModel> getReservationRequestDetails(int id) async {
    try {
      return await ApiService.get<ReservationRequestModel>(
        path: ReservationsEndpoints.reservationRequestDetails(id),
        fromJson: (json) => ReservationRequestModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get reservation request details: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationRequestModel> updateReservationRequest(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      return await ApiService.put<ReservationRequestModel>(
        path: ReservationsEndpoints.updateReservationRequest(id),
        data: data,
        fromJson: (json) => ReservationRequestModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to update reservation request: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> cancelReservationRequest(int id) async {
    try {
      await ApiService.delete(
        path: ReservationsEndpoints.cancelReservationRequest(id),
      );
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
      return await ApiService.post<ReservationModel>(
        path: ReservationsEndpoints.acceptReservationRequest(id),
        fromJson: (json) => ReservationModel.fromJson(json),
      );
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
      return await ApiService.post<ReservationRequestModel>(
        path: ReservationsEndpoints.rejectReservationRequest(id),
        fromJson: (json) => ReservationRequestModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to reject reservation request: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
