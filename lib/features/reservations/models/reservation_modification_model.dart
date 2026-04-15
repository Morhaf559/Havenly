class ReservationModificationModel {
  final int id;
  final int reservationId;
  final String? type;
  final String? oldValue;
  final String? newValue;
  final String? requestedStartDate;
  final String? requestedEndDate;
  final String? status;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReservationModificationModel({
    required this.id,
    required this.reservationId,
    this.type,
    this.oldValue,
    this.newValue,
    this.requestedStartDate,
    this.requestedEndDate,
    this.status,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory ReservationModificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? createdAtValue;
    final createdAtData = json['created_at'];
    if (createdAtData != null) {
      if (createdAtData is String) {
        try {
          createdAtValue = DateTime.parse(createdAtData);
        } catch (e) {
          createdAtValue = null;
        }
      }
    }

    DateTime? updatedAtValue;
    final updatedAtData = json['updated_at'];
    if (updatedAtData != null) {
      if (updatedAtData is String) {
        try {
          updatedAtValue = DateTime.parse(updatedAtData);
        } catch (e) {
          updatedAtValue = null;
        }
      }
    }

    // Extract reservation_id - could be directly in json or inside reservation object
    int? reservationIdValue;
    if (json['reservation_id'] != null) {
      reservationIdValue = json['reservation_id'] is int
          ? json['reservation_id'] as int
          : int.tryParse(json['reservation_id'].toString());
    } else if (json['reservation'] != null &&
        json['reservation'] is Map<String, dynamic>) {
      final reservationMap = json['reservation'] as Map<String, dynamic>;
      if (reservationMap['reservation_id'] != null) {
        reservationIdValue = reservationMap['reservation_id'] is int
            ? reservationMap['reservation_id'] as int
            : int.tryParse(reservationMap['reservation_id'].toString());
      }
    }

    if (reservationIdValue == null) {
      throw Exception(
          'ReservationModificationModel: reservation_id is required but was null');
    }

    // Extract old_value and new_value from response
    final oldValue = json['old_value']?.toString();
    final newValue = json['new_value']?.toString();

    return ReservationModificationModel(
      id: json['id'] as int,
      reservationId: reservationIdValue,
      type: json['type'] as String?,
      oldValue: oldValue,
      newValue: newValue,
      requestedStartDate: json['requested_start_date'] as String?,
      requestedEndDate: json['requested_end_date'] as String?,
      status: json['status'] as String?,
      note: json['note'] as String?,
      createdAt: createdAtValue,
      updatedAt: updatedAtValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservation_id': reservationId,
      if (type != null) 'type': type,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (requestedStartDate != null)
        'requested_start_date': requestedStartDate,
      if (requestedEndDate != null) 'requested_end_date': requestedEndDate,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Check if modification is for date change
  bool isDateModification() {
    return type?.toLowerCase() == 'date';
  }

  /// Check if modification is for cancellation
  bool isCancellation() {
    return type?.toLowerCase() == 'cancel';
  }

  String getStatusText() {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      default:
        return status ?? 'غير محدد';
    }
  }

  bool isPending() {
    return status?.toLowerCase() == 'pending';
  }

  bool isAccepted() {
    return status?.toLowerCase() == 'accepted';
  }

  bool isRejected() {
    return status?.toLowerCase() == 'rejected';
  }
}
