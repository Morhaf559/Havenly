/// Apartment Filter Model
/// Represents filter criteria for apartment searches
/// 
/// Supports:
/// - Simple filters (key-value pairs)
/// - Complex filters with operations
/// - Multiple filters
/// 
/// Usage:
/// ```dart
/// final filter = ApartmentFilterModel(
///   governorate: 1,
///   minPrice: 100,
///   maxPrice: 500,
/// );
/// ```
class ApartmentFilterModel {
  // Location filters
  final int? governorate;
  final String? city;

  // Price filters
  final double? minPrice;
  final double? maxPrice;

  // Property filters
  final int? minRooms;
  final int? maxRooms;
  final int? minBathrooms;
  final int? maxBathrooms;
  final int? minArea;
  final int? maxArea;
  final int? floor;

  // Status filter
  final String? status;

  // Custom filters (for extensibility)
  final Map<String, dynamic>? customFilters;

  ApartmentFilterModel({
    this.governorate,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.minRooms,
    this.maxRooms,
    this.minBathrooms,
    this.maxBathrooms,
    this.minArea,
    this.maxArea,
    this.floor,
    this.status,
    this.customFilters,
  });

  /// Check if filter has any criteria
  bool get isEmpty {
    return governorate == null &&
        city == null &&
        minPrice == null &&
        maxPrice == null &&
        minRooms == null &&
        maxRooms == null &&
        minBathrooms == null &&
        maxBathrooms == null &&
        minArea == null &&
        maxArea == null &&
        floor == null &&
        status == null &&
        (customFilters == null || customFilters!.isEmpty);
  }

  /// Check if filter has any criteria
  bool get isNotEmpty => !isEmpty;

  /// Convert to Map for API query parameters
  /// 
  /// Note: Backend only supports 'eq' operation
  /// For range filters (min/max), we need to handle client-side or convert to multiple 'eq' filters
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    int filterIndex = 0;

    // Governorate filter
    if (governorate != null) {
      params['filters[$filterIndex][name]'] = 'governorate';
      params['filters[$filterIndex][operation]'] = 'eq';
      params['filters[$filterIndex][value]'] = governorate.toString();
      filterIndex++;
    }

    // City filter (if string)
    if (city != null && city!.isNotEmpty) {
      params['filters[$filterIndex][name]'] = 'city';
      params['filters[$filterIndex][operation]'] = 'eq';
      params['filters[$filterIndex][value]'] = city!;
      filterIndex++;
    }

    // Status filter
    if (status != null && status!.isNotEmpty) {
      params['filters[$filterIndex][name]'] = 'status';
      params['filters[$filterIndex][operation]'] = 'eq';
      params['filters[$filterIndex][value]'] = status!;
      filterIndex++;
    }

    // Floor filter
    if (floor != null) {
      params['filters[$filterIndex][name]'] = 'floor';
      params['filters[$filterIndex][operation]'] = 'eq';
      params['filters[$filterIndex][value]'] = floor.toString();
      filterIndex++;
    }

    // Note: Price, rooms, bathrooms, area min/max filters
    // Backend only supports 'eq', so we'll filter client-side for these
    // Or they should be implemented as server-side filters if backend supports them

    // Custom filters
    if (customFilters != null && customFilters!.isNotEmpty) {
      customFilters!.forEach((key, value) {
        if (value != null) {
          params['filters[$filterIndex][name]'] = key;
          params['filters[$filterIndex][operation]'] = 'eq';
          params['filters[$filterIndex][value]'] = value.toString();
          filterIndex++;
        }
      });
    }

    return params;
  }

  /// Convert to simple Map (for storage/display)
  Map<String, dynamic> toMap() {
    return {
      'governorate': governorate,
      'city': city,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRooms': minRooms,
      'maxRooms': maxRooms,
      'minBathrooms': minBathrooms,
      'maxBathrooms': maxBathrooms,
      'minArea': minArea,
      'maxArea': maxArea,
      'floor': floor,
      'status': status,
      if (customFilters != null) 'customFilters': customFilters,
    };
  }

  /// Create from Map
  factory ApartmentFilterModel.fromMap(Map<String, dynamic> map) {
    return ApartmentFilterModel(
      governorate: map['governorate'] != null
          ? (map['governorate'] is int
              ? map['governorate'] as int
              : int.tryParse(map['governorate'].toString()))
          : null,
      city: map['city'] as String?,
      minPrice: map['minPrice'] != null
          ? (map['minPrice'] is num
              ? (map['minPrice'] as num).toDouble()
              : double.tryParse(map['minPrice'].toString()))
          : null,
      maxPrice: map['maxPrice'] != null
          ? (map['maxPrice'] is num
              ? (map['maxPrice'] as num).toDouble()
              : double.tryParse(map['maxPrice'].toString()))
          : null,
      minRooms: map['minRooms'] != null
          ? (map['minRooms'] is int
              ? map['minRooms'] as int
              : int.tryParse(map['minRooms'].toString()))
          : null,
      maxRooms: map['maxRooms'] != null
          ? (map['maxRooms'] is int
              ? map['maxRooms'] as int
              : int.tryParse(map['maxRooms'].toString()))
          : null,
      minBathrooms: map['minBathrooms'] != null
          ? (map['minBathrooms'] is int
              ? map['minBathrooms'] as int
              : int.tryParse(map['minBathrooms'].toString()))
          : null,
      maxBathrooms: map['maxBathrooms'] != null
          ? (map['maxBathrooms'] is int
              ? map['maxBathrooms'] as int
              : int.tryParse(map['maxBathrooms'].toString()))
          : null,
      minArea: map['minArea'] != null
          ? (map['minArea'] is int
              ? map['minArea'] as int
              : int.tryParse(map['minArea'].toString()))
          : null,
      maxArea: map['maxArea'] != null
          ? (map['maxArea'] is int
              ? map['maxArea'] as int
              : int.tryParse(map['maxArea'].toString()))
          : null,
      floor: map['floor'] != null
          ? (map['floor'] is int
              ? map['floor'] as int
              : int.tryParse(map['floor'].toString()))
          : null,
      status: map['status'] as String?,
      customFilters: map['customFilters'] != null
          ? Map<String, dynamic>.from(map['customFilters'] as Map)
          : null,
    );
  }

  /// Copy with method for immutability
  ApartmentFilterModel copyWith({
    int? governorate,
    String? city,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    int? maxRooms,
    int? minBathrooms,
    int? maxBathrooms,
    int? minArea,
    int? maxArea,
    int? floor,
    String? status,
    Map<String, dynamic>? customFilters,
  }) {
    return ApartmentFilterModel(
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRooms: minRooms ?? this.minRooms,
      maxRooms: maxRooms ?? this.maxRooms,
      minBathrooms: minBathrooms ?? this.minBathrooms,
      maxBathrooms: maxBathrooms ?? this.maxBathrooms,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      floor: floor ?? this.floor,
      status: status ?? this.status,
      customFilters: customFilters ?? this.customFilters,
    );
  }

  /// Clear all filters
  ApartmentFilterModel clear() {
    return ApartmentFilterModel();
  }

  @override
  String toString() {
    return 'ApartmentFilterModel(${toMap()})';
  }
}
