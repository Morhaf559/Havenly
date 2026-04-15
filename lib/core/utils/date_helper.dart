/// Date Helper
/// Utility class for parsing and formatting dates
/// Handles various date formats from the API
/// 
/// Usage:
/// ```dart
/// // Parse date from API response
/// final date = DateHelper.parseDate('2026-03-16');
/// 
/// // Format date for API request
/// final formatted = DateHelper.formatForApi(DateTime.now());
/// 
/// // Parse multiple date formats
/// final date1 = DateHelper.parseDate('2026-03-16');
/// final date2 = DateHelper.parseDate('2026-3-16'); // Handles single-digit months
/// ```
class DateHelper {
  /// Parse date string to DateTime
  /// 
  /// Supports multiple formats:
  /// - ISO 8601: '2026-03-16T00:00:00Z'
  /// - Date only: '2026-03-16'
  /// - Date with single-digit month/day: '2026-3-16'
  /// - Date with time: '2026-03-16 12:00:00'
  /// 
  /// Returns [DateTime?] (null if parsing fails)
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      // Try ISO 8601 format first
      final dateTime = DateTime.tryParse(dateString);
      if (dateTime != null) {
        return dateTime;
      }

      // Try date-only format (YYYY-MM-DD or YYYY-M-D)
      final dateOnlyRegex = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$');
      final match = dateOnlyRegex.firstMatch(dateString.trim());
      if (match != null) {
        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        return DateTime(year, month, day);
      }

      // Try date with time format (YYYY-MM-DD HH:MM:SS)
      final dateTimeRegex = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})\s+(\d{1,2}):(\d{1,2}):(\d{1,2})$');
      final timeMatch = dateTimeRegex.firstMatch(dateString.trim());
      if (timeMatch != null) {
        final year = int.parse(timeMatch.group(1)!);
        final month = int.parse(timeMatch.group(2)!);
        final day = int.parse(timeMatch.group(3)!);
        final hour = int.parse(timeMatch.group(4)!);
        final minute = int.parse(timeMatch.group(5)!);
        final second = int.parse(timeMatch.group(6)!);
        return DateTime(year, month, day, hour, minute, second);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Format DateTime for API request
  /// 
  /// Format: YYYY-MM-DD (e.g., '2026-03-16')
  /// 
  /// Returns formatted date string
  static String formatForApi(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Format DateTime for display
  /// 
  /// Format: Based on locale
  /// Default: YYYY-MM-DD
  /// 
  /// Returns formatted date string
  static String formatForDisplay(DateTime date, {String? locale}) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    if (locale == 'ar') {
      // Arabic format: DD/MM/YYYY
      return '$day/$month/$year';
    }

    // Default format: YYYY-MM-DD
    return '$year-$month-$day';
  }

  /// Parse date range (start and end dates)
  /// 
  /// Returns [Map] with 'start' and 'end' DateTime objects
  /// Returns null if either date fails to parse
  static Map<String, DateTime>? parseDateRange({
    required String? startDate,
    required String? endDate,
  }) {
    final start = parseDate(startDate);
    final end = parseDate(endDate);

    if (start == null || end == null) {
      return null;
    }

    return {
      'start': start,
      'end': end,
    };
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  /// Check if date range is valid (start before end)
  static bool isValidDateRange(DateTime start, DateTime end) {
    return start.isBefore(end) || start.isAtSameMomentAs(end);
  }

  /// Calculate number of days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Get relative date string (Today, Tomorrow, Yesterday, or formatted date)
  static String getRelativeDateString(DateTime date, {String? locale}) {
    if (isToday(date)) {
      return locale == 'ar' ? 'اليوم' : 'Today';
    } else if (isTomorrow(date)) {
      return locale == 'ar' ? 'غداً' : 'Tomorrow';
    } else if (isYesterday(date)) {
      return locale == 'ar' ? 'أمس' : 'Yesterday';
    } else {
      return DateHelper.formatForDisplay(date, locale: locale);
    }
  }
}
