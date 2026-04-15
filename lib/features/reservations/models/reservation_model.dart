import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';

class ReservationModel {
  final int id;
  final int? reservationRequestId;
  final int apartmentId;
  final int? userId;
  final String startDate;
  final String endDate;
  final String? status;
  final ApartmentModel? apartment;
  final double? totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReservationModel({
    required this.id,
    this.reservationRequestId,
    required this.apartmentId,
    this.userId,
    required this.startDate,
    required this.endDate,
    this.status,
    this.apartment,
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    int? idValue;
    if (json['id'] != null) {
      idValue = json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString());
    } else if (json['reservation_id'] != null) {
      idValue = json['reservation_id'] is int
          ? json['reservation_id'] as int
          : int.tryParse(json['reservation_id'].toString());
    }

    if (idValue == null) {
      throw Exception('Reservation ID is required but was null');
    }

    int? apartmentIdValue;
    if (json['apartment_id'] != null) {
      apartmentIdValue = json['apartment_id'] is int
          ? json['apartment_id'] as int
          : int.tryParse(json['apartment_id'].toString());
    } else if (json['apartment'] != null && json['apartment'] is Map) {
      final apartmentMap = json['apartment'] as Map<String, dynamic>;
      if (apartmentMap['id'] != null) {
        apartmentIdValue = apartmentMap['id'] is int
            ? apartmentMap['id'] as int
            : int.tryParse(apartmentMap['id'].toString());
      }
    }

    if (apartmentIdValue == null) {
      throw Exception('Apartment ID is required but was null');
    }

    int? userIdValue;
    if (json['user_id'] != null) {
      userIdValue = json['user_id'] is int
          ? json['user_id'] as int
          : int.tryParse(json['user_id'].toString());
    } else if (json['user'] != null && json['user'] is Map) {
      final userMap = json['user'] as Map<String, dynamic>;
      if (userMap['id'] != null) {
        userIdValue = userMap['id'] is int
            ? userMap['id'] as int
            : int.tryParse(userMap['id'].toString());
      }
    }

    String? startDateValue;
    if (json['start_date'] != null) {
      startDateValue = json['start_date'].toString();
    }

    String? endDateValue;
    if (json['end_date'] != null) {
      endDateValue = json['end_date'].toString();
    }

    if (startDateValue == null || endDateValue == null) {
      throw Exception('Start date and end date are required');
    }

    double? totalAmountValue;
    if (json['total_amount'] != null) {
      if (json['total_amount'] is double) {
        totalAmountValue = json['total_amount'] as double;
      } else if (json['total_amount'] is int) {
        totalAmountValue = (json['total_amount'] as int).toDouble();
      } else if (json['total_amount'] is String) {
        totalAmountValue = double.tryParse(json['total_amount'] as String);
      }
    }

    DateTime? createdAtValue;
    if (json['created_at'] != null) {
      try {
        if (json['created_at'] is String) {
          createdAtValue = DateTime.tryParse(json['created_at'] as String);
        }
      } catch (e) {
        createdAtValue = null;
      }
    }

    DateTime? updatedAtValue;
    if (json['updated_at'] != null) {
      try {
        if (json['updated_at'] is String) {
          updatedAtValue = DateTime.tryParse(json['updated_at'] as String);
        }
      } catch (e) {
        updatedAtValue = null;
      }
    }

    return ReservationModel(
      id: idValue,
      reservationRequestId: json['reservation_request_id'] != null
          ? (json['reservation_request_id'] is int
                ? json['reservation_request_id'] as int
                : int.tryParse(json['reservation_request_id'].toString()))
          : null,
      apartmentId: apartmentIdValue,
      userId: userIdValue,
      startDate: startDateValue,
      endDate: endDateValue,
      status: json['status'] as String?,
      apartment: json['apartment'] != null && json['apartment'] is Map
          ? ApartmentModel.fromJson(json['apartment'] as Map<String, dynamic>)
          : null,
      totalAmount: totalAmountValue,
      createdAt: createdAtValue,
      updatedAt: updatedAtValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (reservationRequestId != null)
        'reservation_request_id': reservationRequestId,
      'apartment_id': apartmentId,
      if (userId != null) 'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      if (status != null) 'status': status,
      if (apartment != null) 'apartment': apartment!.toJson(),
      if (totalAmount != null) 'total_amount': totalAmount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  String getStatusText() {
    switch (status?.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status ?? 'غير محدد';
    }
  }

  bool isActive() {
    return status?.toLowerCase() == 'active';
  }

  bool isCompleted() {
    return status?.toLowerCase() == 'completed';
  }

  bool isCancelled() {
    return status?.toLowerCase() == 'cancelled';
  }
}
