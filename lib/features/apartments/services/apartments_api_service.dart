import 'package:my_havenly_application/core/models/api_response.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/apartments/endpoints/apartments_endpoints.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';

/// Apartments API Service
/// Low-level API service for apartment endpoints
/// Handles only HTTP requests, no business logic
/// 
/// Endpoints:
/// - GET /apartment - List apartments
/// - GET /apartment/:id - Get apartment details
/// - POST /apartment - Create apartment
/// - PUT /apartment/:id - Update apartment
/// - DELETE /apartment/:id - Delete apartment
class ApartmentsApiService {
  /// Get apartments list (paginated)
  /// 
  /// GET /apartment
  /// Query parameters: page, perPage, keyword, filters[][name], filters[][operation], filters[][value], orders[][name], orders[][direction]
  /// 
  /// Returns [ApiResponse<ApartmentModel>] with paginated apartments
  /// Throws [ApiException] on error
  Future<ApiResponse<ApartmentModel>> getApartments({
    int page = 1,
    int perPage = 10,
    String? keyword,
    Map<String, dynamic>? filters,
    Map<String, String>? orders, // { 'name': 'price', 'direction': 'asc' }
  }) async {
    try {
      // Build query parameters using QueryBuilder
      final queryBuilder = QueryBuilder()
          .pagination(page: page, perPage: perPage)
          .keyword(keyword);

      // Add filters
      // Note: filters parameter is already in query parameters format from Repository
      // If filters come as Map<String, dynamic> with filter structure, parse them
      if (filters != null && filters.isNotEmpty) {
        // Check if filters are already in query parameter format
        // (from ApartmentFilterModel.toQueryParams())
        if (filters.containsKey('filters[0][name]')) {
          // Already in query parameter format - add directly
          filters.forEach((key, value) {
            queryBuilder.param(key, value);
          });
        } else {
          // Convert to query parameter format
          filters.forEach((name, value) {
            // Handle different filter value types
            if (value is Map && value.containsKey('operation') && value.containsKey('value')) {
              final operation = value['operation'] as String;
              final filterValue = value['value'];
              queryBuilder.filter(name, operation, filterValue);
            } else {
              // Simple filter (default to 'eq')
              queryBuilder.filter(name, 'eq', value);
            }
          });
        }
      }

      // Add orders
      if (orders != null && orders.isNotEmpty) {
        orders.forEach((name, direction) {
          queryBuilder.order(name, direction);
        });
      }

      // Call API
      return await ApiService.getPaginated<ApartmentModel>(
        path: ApartmentsEndpoints.list,
        queryParameters: queryBuilder.build(),
        fromJson: (json) => ApartmentModel.fromJson(json),
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
  /// Throws [ApiException] on error
  Future<ApiResponse<ApartmentModel>> getAvailableApartments() async {
    try {
      return await ApiService.getPaginated<ApartmentModel>(
        path: ApartmentsEndpoints.available,
        fromJson: (json) => ApartmentModel.fromJson(json),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get available apartments: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// Get apartment details by ID
  /// 
  /// GET /apartment/:id
  /// 
  /// Returns [ApartmentModel] with apartment details
  /// Throws [ApiException] on error
  Future<ApartmentModel> getApartmentDetails(int apartmentId) async {
    try {
      return await ApiService.get<ApartmentModel>(
        path: ApartmentsEndpoints.getDetails(apartmentId),
        fromJson: (json) => ApartmentModel.fromJson(json),
      );
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
  /// POST /apartment
  /// Body: Apartment data (title, description, price, etc.)
  /// 
  /// Returns [ApartmentModel] with created apartment
  /// Throws [ApiException] on error
  Future<ApartmentModel> createApartment(Map<String, dynamic> data) async {
    try {
      return await ApiService.post<ApartmentModel>(
        path: ApartmentsEndpoints.create,
        data: data,
        fromJson: (json) => ApartmentModel.fromJson(json),
      );
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
  /// PUT /apartment/:id
  /// Body: Partial apartment data (all fields optional)
  /// 
  /// Returns [ApartmentModel] with updated apartment
  /// Throws [ApiException] on error
  Future<ApartmentModel> updateApartment(
    int apartmentId,
    Map<String, dynamic> data,
  ) async {
    try {
      return await ApiService.put<ApartmentModel>(
        path: ApartmentsEndpoints.update(apartmentId),
        data: data,
        fromJson: (json) => ApartmentModel.fromJson(json),
      );
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
  /// DELETE /apartment/:id
  /// 
  /// Returns void on success
  /// Throws [ApiException] on error
  Future<void> deleteApartment(int apartmentId) async {
    try {
      await ApiService.delete(path: ApartmentsEndpoints.delete(apartmentId));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to delete apartment: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
