class ReservationRequestStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';
  static const String cancelled = 'cancelled';

  /// Get display text for status
  static String displayText(String status, {String? locale}) {
    final localeCode = locale ?? 'en';
    switch (status.toLowerCase()) {
      case pending:
        return localeCode == 'ar' ? 'قيد الانتظار' : 'Pending';
      case accepted:
        return localeCode == 'ar' ? 'مقبول' : 'Accepted';
      case rejected:
        return localeCode == 'ar' ? 'مرفوض' : 'Rejected';
      case cancelled:
        return localeCode == 'ar' ? 'ملغي' : 'Cancelled';
      default:
        return status;
    }
  }

  /// Check if status is valid
  static bool isValid(String status) {
    return [
      pending,
      accepted,
      rejected,
      cancelled,
    ].contains(status.toLowerCase());
  }

  /// Get all statuses
  static List<String> get all => [pending, accepted, rejected, cancelled];
}

class ReservationStatus {
  static const String active = 'active';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';

  /// Get display text for status
  static String displayText(String status, {String? locale}) {
    final localeCode = locale ?? 'en';
    switch (status.toLowerCase()) {
      case active:
        return localeCode == 'ar' ? 'نشط' : 'Active';
      case completed:
        return localeCode == 'ar' ? 'مكتمل' : 'Completed';
      case cancelled:
        return localeCode == 'ar' ? 'ملغي' : 'Cancelled';
      default:
        return status;
    }
  }

  /// Check if status is valid
  static bool isValid(String status) {
    return [active, completed, cancelled].contains(status.toLowerCase());
  }

  /// Get all statuses
  static List<String> get all => [active, completed, cancelled];
}

class ReservationModificationStatus {
  static const String pending = 'pending';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';

  /// Get display text for status
  static String displayText(String status, {String? locale}) {
    final localeCode = locale ?? 'en';
    switch (status.toLowerCase()) {
      case pending:
        return localeCode == 'ar' ? 'قيد الانتظار' : 'Pending';
      case accepted:
        return localeCode == 'ar' ? 'مقبول' : 'Accepted';
      case rejected:
        return localeCode == 'ar' ? 'مرفوض' : 'Rejected';
      default:
        return status;
    }
  }

  /// Check if status is valid
  static bool isValid(String status) {
    return [pending, accepted, rejected].contains(status.toLowerCase());
  }

  /// Get all statuses
  static List<String> get all => [pending, accepted, rejected];
}

/// Modification Type Enums
class ReservationModificationType {
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String both = 'both'; // For changing both dates (deprecated)
  static const String date = 'date'; // For changing both start and end dates
  static const String cancel = 'cancel'; // For cancelling reservation

  /// Get display text for type
  static String displayText(String type, {String? locale}) {
    final localeCode = locale ?? 'en';
    switch (type.toLowerCase()) {
      case startDate:
        return localeCode == 'ar' ? 'تاريخ البدء' : 'Start Date';
      case endDate:
        return localeCode == 'ar' ? 'تاريخ الانتهاء' : 'End Date';
      case both:
        return localeCode == 'ar' ? 'كلاهما' : 'Both';
      case date:
        return localeCode == 'ar' ? 'تعديل التاريخين' : 'Change Dates';
      case cancel:
        return localeCode == 'ar' ? 'إلغاء الحجز' : 'Cancel Reservation';
      default:
        return type;
    }
  }

  /// Check if type is valid
  static bool isValid(String type) {
    return [
      startDate,
      endDate,
      both,
      date,
      cancel,
    ].contains(type.toLowerCase());
  }

  /// Get all types
  static List<String> get all => [
        startDate,
        endDate,
        both,
        date,
        cancel,
      ];
}
