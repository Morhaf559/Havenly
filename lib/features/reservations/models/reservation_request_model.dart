import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';

class ReservationRequestModel {
  final int id;
  final int apartmentId;
  final int? userId;
  final String startDate;
  final String endDate;
  final String? note;
  final String? status;
  final ApartmentModel? apartment;
  final double? totalAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReservationRequestModel({
    required this.id,
    required this.apartmentId,
    this.userId,
    required this.startDate,
    required this.endDate,
    this.note,
    this.status,
    this.apartment,
    this.totalAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory ReservationRequestModel.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic idValue) {
      if (idValue == null) return null;
      if (idValue is int) return idValue;
      if (idValue is String) return int.tryParse(idValue);
      return null;
    }

    final id = parseId(json['id']) ?? parseId(json['reservation_request_id']);

    if (id == null || id <= 0) {
      throw Exception(
        'ReservationRequest ID is required but was null or invalid',
      );
    }

    int? apartmentId;
    if (json['apartment_id'] != null) {
      if (json['apartment_id'] is int) {
        apartmentId = json['apartment_id'] as int;
      } else if (json['apartment_id'] is String) {
        apartmentId = int.tryParse(json['apartment_id'] as String);
      }
    } else if (json['apartment'] != null &&
        json['apartment'] is Map<String, dynamic>) {
      final apartmentData = json['apartment'] as Map<String, dynamic>;
      if (apartmentData['id'] != null) {
        if (apartmentData['id'] is int) {
          apartmentId = apartmentData['id'] as int;
        } else if (apartmentData['id'] is String) {
          apartmentId = int.tryParse(apartmentData['id'] as String);
        }
      }
    }

    int? userId;
    if (json['user_id'] != null) {
      if (json['user_id'] is int) {
        userId = json['user_id'] as int;
      } else if (json['user_id'] is String) {
        userId = int.tryParse(json['user_id'] as String);
      }
    } else if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      final userData = json['user'] as Map<String, dynamic>;
      if (userData['id'] != null) {
        if (userData['id'] is int) {
          userId = userData['id'] as int;
        } else if (userData['id'] is String) {
          userId = int.tryParse(userData['id'] as String);
        }
      }
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

    return ReservationRequestModel(
      id: id,
      apartmentId: apartmentId ?? 0,
      userId: userId,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      note: json['note'] as String?,
      status: json['status'] as String?,
      apartment: json['apartment'] != null
          ? ApartmentModel.fromJson(json['apartment'] as Map<String, dynamic>)
          : null,
      totalAmount: totalAmountValue,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      if (userId != null) 'user_id': userId,
      'start_date': startDate,
      'end_date': endDate,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (apartment != null) 'apartment': apartment!.toJson(),
      if (totalAmount != null) 'total_amount': totalAmount,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  String getStatusText() {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
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

  bool isCancelled() {
    return status?.toLowerCase() == 'cancelled';
  }

  bool canBeCancelled() {
    return isPending();
  }
}
