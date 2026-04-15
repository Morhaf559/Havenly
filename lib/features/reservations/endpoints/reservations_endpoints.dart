class ReservationsEndpoints {
  ReservationsEndpoints._();
  static const String reservationRequestsBase = '/reservation-requests';

  static const String reservationRequestsList = reservationRequestsBase;
  static const String reservationRequestsSend = '$reservationRequestsBase/send';

  static const String reservationRequestsReceive =
      '$reservationRequestsBase/receive';
  static const String reservationRequestsCreate = reservationRequestsBase;
  static String reservationRequestDetails(int id) =>
      '$reservationRequestsBase/$id';
  static String updateReservationRequest(int id) =>
      '$reservationRequestsBase/$id';
  static String cancelReservationRequest(int id) =>
      '$reservationRequestsBase/$id';
  static String acceptReservationRequest(int id) =>
      '$reservationRequestsBase/$id/accept';

  static String rejectReservationRequest(int id) =>
      '$reservationRequestsBase/$id/reject';
  static const String reservationsBase = '/reservations';
  static const String reservationsList = reservationsBase;
  static String reservationDetails(int id) => '$reservationsBase/$id';
  static const String myApartmentReservations =
      '$reservationsBase/my-apartment-reservations';
  static const String myReservations = '$reservationsBase/my-reservations';

  static const String modificationsBase = '/reservation-modifications';

  static const String modificationsList = modificationsBase;

  static const String modificationsReceive = '$modificationsBase/owner-receive';
  static const String modificationsOwnerSend = '$modificationsBase/owner-send';

  static const String modificationsTenantSend =
      '$modificationsBase/tenant-send';

  static const String modificationsTenantReceive =
      '$modificationsBase/tenant-receive';
  static const String modificationsCreate = modificationsBase;

  static String modificationDetails(int id) => '$modificationsBase/$id';

  static String reservationModifications(int reservationId) =>
      '$reservationsBase/$reservationId/modifications';
  static String acceptModification(int id) => '/modifications/$id/accept';
  static String rejectModification(int id) => '/modifications/$id/reject';
}
