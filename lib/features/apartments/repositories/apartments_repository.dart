import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/models/api_response.dart';
import 'package:my_havenly_application/core/controllers/locale_controller.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'package:my_havenly_application/features/apartments/services/apartments_api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';

/// Apartments Repository
/// Business logic layer for apartment operations
/// Handles string→number conversion and localization parsing
///
/// Responsibilities:
/// - Convert string values to numbers (price, area, rooms, etc.)
/// - Parse localized fields (title, description, address, city)
/// - Coordinate between ApartmentsApiService and controllers
/// - Filter apartments (client-side and server-side)
///
/// Architectural Principle:
/// - Repository handles all data transformation
/// - Controllers receive clean, typed data
class ApartmentsRepository {
  final ApartmentsApiService _apiService = Get.find<ApartmentsApiService>();
  final LocaleController _localeController = Get.find<LocaleController>();

  /// Get apartments list with filters and pagination
  ///
  /// [page] - Page number (1-indexed)
  /// [perPage] - Items per page
  /// [keyword] - Search keyword
  /// [filters] - Filter criteria
  /// [sortBy] - Sort field (e.g., 'price', 'created_at')
  /// [sortDirection] - Sort direction ('asc' or 'desc')
  ///
  /// Returns [ApiResponse<ApartmentModel>] with parsed apartments
  /// Note: All string→number conversions and localization parsing are handled here
  /// Throws [ApiException] on error
  Future<ApiResponse<ApartmentModel>> getApartments({
    int page = 1,
    int perPage = 10,
    String? keyword,
    ApartmentFilterModel? filters,
    String? sortBy,
    String? sortDirection = 'desc',
  }) async {
    try {
      // Convert filters to simple Map (ApiService will use QueryBuilder)
      // Note: Backend only supports 'eq' operation
      final queryFilters = <String, dynamic>{};
      if (filters != null && filters.isNotEmpty) {
        // Convert ApartmentFilterModel to simple Map for QueryBuilder
        if (filters.governorate != null) {
          queryFilters['governorate'] = filters.governorate;
        }
        if (filters.city != null && filters.city!.isNotEmpty) {
          queryFilters['city'] = filters.city;
        }
        if (filters.status != null && filters.status!.isNotEmpty) {
          queryFilters['status'] = filters.status;
        }
        if (filters.floor != null) {
          queryFilters['floor'] = filters.floor;
        }
        // Note: min/max filters are handled client-side in _applyClientSideFilters
        // Backend supports 'eq' operation, and potentially 'ne' (not equal) for excluding
        // Custom filters can contain either simple values or Map with operation and value
        if (filters.customFilters != null &&
            filters.customFilters!.isNotEmpty) {
          filters.customFilters!.forEach((key, value) {
            // Check if value is a Map with operation and value (for 'ne' operation)
            if (value is Map &&
                value.containsKey('operation') &&
                value.containsKey('value')) {
              // This will be handled by ApiService which supports Map format
              queryFilters[key] = value;
            } else {
              // Simple filter (default to 'eq')
              queryFilters[key] = value;
            }
          });
        }
      }

      // Build orders map
      final orders = <String, String>{};
      if (sortBy != null && sortBy.isNotEmpty) {
        orders[sortBy] = sortDirection ?? 'desc';
      }

      // Call API service
      final response = await _apiService.getApartments(
        page: page,
        perPage: perPage,
        keyword: keyword,
        filters: queryFilters.isNotEmpty ? queryFilters : null,
        orders: orders.isNotEmpty ? orders : null,
      );

      // Parse and normalize apartments (handle string→number, localization)
      final parsedApartments = response.data.map((apartment) {
        return _parseApartment(apartment);
      }).toList();

      // Apply client-side filtering in the correct order:
      // 1. First apply keyword search (if Backend doesn't filter properly)
      // 2. Then apply range filters (min/max) that Backend doesn't support
      // This ensures both search and filters work together correctly

      // Step 1: Apply keyword filter (client-side fallback if Backend doesn't filter)
      // Only apply if keyword is provided and not empty
      // Note: This is a fallback - Backend should handle keyword search, but we apply it
      // client-side to ensure it works even if Backend has issues
      List<ApartmentModel> keywordFilteredApartments = parsedApartments;
      if (keyword != null && keyword.trim().isNotEmpty) {
        final beforeCount = keywordFilteredApartments.length;
        keywordFilteredApartments = _applyKeywordFilter(
          parsedApartments,
          keyword,
        );
        final afterCount = keywordFilteredApartments.length;
        if (kDebugMode) {
          debugPrint(
            'ApartmentsRepository: Keyword filter applied: $beforeCount -> $afterCount (keyword: "$keyword")',
          );
        }
      }

      // Step 2: Apply client-side range filters (min/max price, rooms, etc.)
      // Backend only supports 'eq' operation, so we filter client-side for ranges
      // Also handles city filter as fallback if Backend doesn't filter properly
      final beforeFilterCount = keywordFilteredApartments.length;
      final filteredApartments = _applyClientSideFilters(
        keywordFilteredApartments,
        filters,
      );
      final afterFilterCount = filteredApartments.length;
      if (kDebugMode && filters != null && filters.isNotEmpty) {
        debugPrint(
          'ApartmentsRepository: Client-side filters applied: $beforeFilterCount -> $afterFilterCount',
        );
      }

      // Calculate adjusted pagination info
      // If we filtered client-side, we need to adjust total
      // But keep original pagination info from Backend for consistency
      final adjustedTotal = filteredApartments.length;
      final adjustedLastPage = (adjustedTotal / perPage).ceil();

      // Return filtered response with adjusted pagination
      return ApiResponse<ApartmentModel>(
        data: filteredApartments,
        page: response.page,
        perPage: response.perPage,
        lastPage: adjustedLastPage > 0 ? adjustedLastPage : 1,
        total: adjustedTotal,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get apartments: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get available apartments
  ///
  /// GET /apartments/available
  ///
  /// Returns [ApiResponse<ApartmentModel>] with available apartments
  /// Note: All string→number conversions and localization parsing are handled here
  /// Throws [ApiException] on error
  Future<ApiResponse<ApartmentModel>> getAvailableApartments() async {
    try {
      // Call API service
      final response = await _apiService.getAvailableApartments();

      // Parse and normalize apartments (handle string→number, localization)
      final parsedApartments = response.data.map((apartment) {
        return _parseApartment(apartment);
      }).toList();

      // Return normalized response
      return ApiResponse<ApartmentModel>(
        data: parsedApartments,
        page: response.page,
        perPage: response.perPage,
        lastPage: response.lastPage,
        total: response.total,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw UnknownException(
        message: 'Failed to get available apartments: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get apartment details by ID
  ///
  /// [apartmentId] - Apartment ID
  ///
  /// Returns [ApartmentModel] with parsed apartment
  /// Note: All string→number conversions and localization parsing are handled here
  /// Throws [ApiException] on error
  Future<ApartmentModel> getApartmentDetails(int apartmentId) async {
    try {
      final apartment = await _apiService.getApartmentDetails(apartmentId);
      return _parseApartment(apartment);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get apartment details: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Create a new apartment (Owner only)
  ///
  /// [data] - Apartment data (raw from form)
  /// Note: Repository handles conversion (number→string for API, localization)
  ///
  /// Returns [ApartmentModel] with created apartment
  /// Throws [ApiException] on error
  Future<ApartmentModel> createApartment(Map<String, dynamic> data) async {
    try {
      // Prepare data for API (convert numbers to strings, ensure localization)
      final preparedData = _prepareApartmentDataForApi(data);

      final apartment = await _apiService.createApartment(preparedData);
      return _parseApartment(apartment);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to create apartment: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Update an existing apartment (Owner only)
  ///
  /// [apartmentId] - Apartment ID
  /// [data] - Partial apartment data (raw from form)
  /// Note: Repository handles conversion (number→string for API, localization)
  ///
  /// Returns [ApartmentModel] with updated apartment
  /// Throws [ApiException] on error
  Future<ApartmentModel> updateApartment(
    int apartmentId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Prepare data for API (convert numbers to strings, ensure localization)
      final preparedData = _prepareApartmentDataForApi(data);

      final apartment = await _apiService.updateApartment(
        apartmentId,
        preparedData,
      );
      return _parseApartment(apartment);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to update apartment: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Delete an apartment (Owner only)
  ///
  /// [apartmentId] - Apartment ID
  ///
  /// Returns void on success
  /// Throws [ApiException] on error
  Future<void> deleteApartment(int apartmentId) async {
    try {
      await _apiService.deleteApartment(apartmentId);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to delete apartment: ${e.toString()}',
        originalError: e,
      );
    }
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Parse and normalize apartment data
  /// Handles string→number conversion and localization parsing
  /// Also loads main image if not present
  ///
  /// Note: ApartmentModel.fromJson already handles most conversions,
  /// but this method ensures additional normalization if needed
  ApartmentModel _parseApartment(ApartmentModel apartment) {
    // ApartmentModel.fromJson already handles:
    // - String→number conversion for price, area, rooms, bathrooms, floor
    // - Localized fields parsing (title, description, address)
    // - Main image extraction from photos array

    // If mainImage is still null, try to load it (async, but don't block)
    // This is handled lazily in ApartmentCardWidget if needed

    return apartment;
  }

  /// Apply keyword filter on client-side (fallback if Backend doesn't filter)
  /// Searches in title, description, city, and address
  List<ApartmentModel> _applyKeywordFilter(
    List<ApartmentModel> apartments,
    String? keyword,
  ) {
    if (keyword == null || keyword.isEmpty) {
      return apartments;
    }

    final lowerKeyword = keyword.toLowerCase().trim();
    if (lowerKeyword.isEmpty) {
      return apartments;
    }

    return apartments.where((apartment) {
      // Search in title
      final title =
          apartment.getLocalizedTitle(_localeController.currentLanguageCode) ??
          '';
      if (title.toLowerCase().contains(lowerKeyword)) {
        return true;
      }

      // Search in description
      final description =
          apartment.getLocalizedDescription(
            _localeController.currentLanguageCode,
          ) ??
          '';
      if (description.toLowerCase().contains(lowerKeyword)) {
        return true;
      }

      // Search in city
      if (apartment.city != null &&
          apartment.city!.toLowerCase().contains(lowerKeyword)) {
        return true;
      }

      // Search in address (can be Map or String)
      final address =
          apartment.getLocalizedAddress(
            _localeController.currentLanguageCode,
          ) ??
          '';
      if (address.toLowerCase().contains(lowerKeyword)) {
        return true;
      }

      // Search in governorate
      if (apartment.governorate != null &&
          apartment.governorate!.toLowerCase().contains(lowerKeyword)) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Apply client-side filters for range filters (min/max) and city
  /// Backend only supports 'eq' operation, so we filter client-side for ranges
  /// Also handles city filter as fallback if Backend doesn't filter properly
  List<ApartmentModel> _applyClientSideFilters(
    List<ApartmentModel> apartments,
    ApartmentFilterModel? filters,
  ) {
    if (filters == null || filters.isEmpty) {
      return apartments;
    }

    return apartments.where((apartment) {
      // City filter (client-side fallback if Backend doesn't filter properly)
      // Only apply if city filter is set and Backend might not have filtered it
      if (filters.city != null && filters.city!.isNotEmpty) {
        final apartmentCity = apartment.city?.toLowerCase().trim() ?? '';
        final filterCity = filters.city!.toLowerCase().trim();
        // Use contains for partial matching (more flexible)
        if (apartmentCity.isNotEmpty && !apartmentCity.contains(filterCity)) {
          return false;
        }
      }

      // Price filters (range filters - Backend doesn't support min/max)
      if (filters.minPrice != null && apartment.price < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && apartment.price > filters.maxPrice!) {
        return false;
      }

      // Room filters (range filters)
      if (filters.minRooms != null &&
          (apartment.numberOfRoom ?? 0) < filters.minRooms!) {
        return false;
      }
      if (filters.maxRooms != null &&
          (apartment.numberOfRoom ?? 0) > filters.maxRooms!) {
        return false;
      }

      // Bathroom filters (range filters)
      if (filters.minBathrooms != null &&
          (apartment.numberOfBathroom ?? 0) < filters.minBathrooms!) {
        return false;
      }
      if (filters.maxBathrooms != null &&
          (apartment.numberOfBathroom ?? 0) > filters.maxBathrooms!) {
        return false;
      }

      // Area filters (range filters)
      if (filters.minArea != null && (apartment.area ?? 0) < filters.minArea!) {
        return false;
      }
      if (filters.maxArea != null && (apartment.area ?? 0) > filters.maxArea!) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Prepare apartment data for API
  /// Converts numbers to strings and ensures localization structure
  ///
  /// Backend expects:
  /// - Price as string: "300.00"
  /// - Numbers as strings: "4", "160", "1"
  /// - Localized fields as Map: { "en": "...", "ar": "..." }
  Map<String, dynamic> _prepareApartmentDataForApi(Map<String, dynamic> data) {
    final prepared = <String, dynamic>{};

    // Current locale
    final currentLocale = _localeController.currentLanguageCode;

    data.forEach((key, value) {
      if (value == null) {
        return; // Skip null values
      }

      // Handle localized fields (title, description, address, city)
      if (key == 'title' ||
          key == 'description' ||
          key == 'address' ||
          key == 'city') {
        prepared[key] = _prepareLocalizedField(value, currentLocale);
      }
      // Handle numeric fields (convert to string for API)
      else if (key == 'price' || key == 'area' || key == 'floor') {
        prepared[key] = _prepareNumericField(value);
      }
      // Handle integer fields (convert to string for API)
      else if (key == 'number_of_room' || key == 'number_of_bathroom') {
        prepared[key] = _prepareIntegerField(value);
      }
      // Handle governorate (should be int or string)
      else if (key == 'governorate') {
        prepared[key] = value is int
            ? value
            : int.tryParse(value.toString()) ?? value;
      }
      // Keep other fields as-is
      else {
        prepared[key] = value;
      }
    });

    return prepared;
  }

  /// Prepare localized field for API
  /// Ensures structure: { "en": "...", "ar": "..." }
  ///
  /// Handles:
  /// - String → { currentLocale: string, ar: string }
  /// - Map → ensure both 'en' and 'ar' keys exist
  dynamic _prepareLocalizedField(dynamic value, String currentLocale) {
    if (value is String) {
      // Single string value - create localized map
      // If current locale is Arabic, set both ar and en
      // If current locale is English, set both en and ar
      if (currentLocale == 'ar') {
        return {'ar': value, 'en': value}; // Default to same value
      } else {
        return {'en': value, 'ar': value}; // Default to same value
      }
    } else if (value is Map<String, dynamic>) {
      // Already a map - ensure both locales exist
      final map = Map<String, dynamic>.from(value);
      if (!map.containsKey('ar')) {
        map['ar'] = map['en'] ?? map.values.first ?? '';
      }
      if (!map.containsKey('en')) {
        map['en'] = map['ar'] ?? map.values.first ?? '';
      }
      return map;
    }
    return value;
  }

  /// Prepare numeric field for API (convert to string)
  ///
  /// Handles: int, double, String → String
  String _prepareNumericField(dynamic value) {
    if (value is num) {
      return value.toString();
    } else if (value is String) {
      // Validate it's a valid number
      if (double.tryParse(value) != null) {
        return value;
      }
    }
    return value.toString();
  }

  /// Prepare integer field for API (convert to string)
  ///
  /// Handles: int, String → String
  String _prepareIntegerField(dynamic value) {
    if (value is int) {
      return value.toString();
    } else if (value is String) {
      // Validate it's a valid integer
      if (int.tryParse(value) != null) {
        return value;
      }
    }
    return value.toString();
  }
}
