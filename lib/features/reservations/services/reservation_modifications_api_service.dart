import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/reservations/endpoints/reservations_endpoints.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_modification_model.dart';

class ReservationModificationsApiService {
  Future<List<ReservationModificationModel>> getModifications() async {
    try {
      return await ApiService.getList<ReservationModificationModel>(
        path: ReservationsEndpoints.modificationsList,
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get reservation modifications: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModificationModel>> getReceivedModifications() async {
    try {
      return await ApiService.getList<ReservationModificationModel>(
        path: ReservationsEndpoints.modificationsReceive,
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
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
      return await ApiService.getList<ReservationModificationModel>(
        path: ReservationsEndpoints.modificationsOwnerSend,
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
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
      return await ApiService.getList<ReservationModificationModel>(
        path: ReservationsEndpoints.modificationsTenantSend,
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
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
      return await ApiService.getList<ReservationModificationModel>(
        path: ReservationsEndpoints.modificationsTenantReceive,
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get tenant received modifications: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModificationModel> createModificationRequest(
    int reservationId,
    Map<String, dynamic> data,
  ) async {
    try {
      return await ApiService.post<ReservationModificationModel>(
        path: ReservationsEndpoints.reservationModifications(reservationId),
        data: data,
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to create modification request: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModificationModel> getModificationDetails(int id) async {
    try {
      return await ApiService.get<ReservationModificationModel>(
        path: ReservationsEndpoints.modificationDetails(id),
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
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
      return await ApiService.getList<ReservationModificationModel>(
        path: ReservationsEndpoints.reservationModifications(reservationId),
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
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
      return await ApiService.post<ReservationModificationModel>(
        path: ReservationsEndpoints.acceptModification(id),
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
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
      return await ApiService.post<ReservationModificationModel>(
        path: ReservationsEndpoints.rejectModification(id),
        fromJson: (json) => ReservationModificationModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to reject modification: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
