import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/reservations/endpoints/reservations_endpoints.dart';
import 'package:my_havenly_application/features/reservations/models/reservation_model.dart';

class ReservationsApiService {
  Future<List<ReservationModel>> getReservations() async {
    try {
      return await ApiService.getList<ReservationModel>(
        path: ReservationsEndpoints.reservationsList,
        fromJson: (json) => ReservationModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get reservations: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<ReservationModel> getReservationDetails(int id) async {
    try {
      return await ApiService.get<ReservationModel>(
        path: ReservationsEndpoints.reservationDetails(id),
        fromJson: (json) => ReservationModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get reservation details: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModel>> getMyApartmentReservations() async {
    try {
      return await ApiService.getList<ReservationModel>(
        path: ReservationsEndpoints.myApartmentReservations,
        fromJson: (json) => ReservationModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get my apartment reservations: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<List<ReservationModel>> getMyReservations() async {
    try {
      return await ApiService.getList<ReservationModel>(
        path: ReservationsEndpoints.myReservations,
        fromJson: (json) => ReservationModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get my reservations: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
