import 'package:flutter/foundation.dart';
import 'package:my_havenly_application/core/models/api_response.dart';
import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';

/// Apartment Service
/// Handles apartment API calls
class ApartmentService {
  /// Get apartments list (paginated)
  /// GET /apartment
  /// Query parameters: page, keyword, filters[][name], filters[][operation], filters[][value]
  /// 
  /// [filters] can be:
  /// - Simple Map: {'user_id': 1} -> uses 'eq' operation (equal)
  /// 
  /// Note: Backend only supports 'eq' operation. For excluding user's apartments,
  /// use [excludeUserId] parameter which will filter client-side.
  /// 
  /// Examples:
  /// - Get user's apartments: filters: {'user_id': 1}  // uses 'eq'
  /// - Exclude user's apartments: excludeUserId: 1  // filters client-side
  static Future<ApiResponse<ApartmentModel>> getApartments({
    int? page,
    int? perPage,
    String? search,
    Map<String, dynamic>? filters,
    /// Exclude user ID: if provided, apartments belonging to this user will be excluded (client-side filtering)
    /// This is needed because backend only supports 'eq' operation, not 'ne'
    int? excludeUserId,
  }) async {
    final queryParameters = <String, dynamic>{};

    // Add pagination
    if (page != null) {
      queryParameters['page'] = page;
    }
    queryParameters['perPage'] = perPage ?? 10;

    // Add search keyword
    if (search != null && search.isNotEmpty) {
      queryParameters['keyword'] = search;
    }

    // Add filters (only 'eq' operation is supported by backend)
    // Remove excludeUserId from filters if it exists (we'll handle it separately)
    Map<String, dynamic> serverFilters = {};
    if (filters != null && filters.isNotEmpty) {
      filters.forEach((key, value) {
        // Skip user_id if it's meant for exclusion (has 'ne' operation)
        if (key == 'user_id' && value is Map && value['operation'] == 'ne') {
          // Don't add this to server filters - will be handled by excludeUserId
          return;
        }
        
        // Only add 'eq' filters to server
        if (value != null) {
          dynamic filterValue = value;
          
          // If value is a Map with operation, only use if operation is 'eq'
          if (value is Map && value.containsKey('operation') && value.containsKey('value')) {
            String operation = value['operation'] as String;
            if (operation != 'eq') {
              // Skip non-eq operations (backend doesn't support them)
              return;
            }
            filterValue = value['value'];
          }

          if (filterValue != null && filterValue.toString().isNotEmpty) {
            serverFilters[key] = filterValue;
          }
        }
      });
    }

    // Add server-side filters
    if (serverFilters.isNotEmpty) {
      int filterIndex = 0;
      serverFilters.forEach((key, value) {
        queryParameters['filters[$filterIndex][name]'] = key;
        queryParameters['filters[$filterIndex][operation]'] = 'eq'; // Backend only supports 'eq'
        queryParameters['filters[$filterIndex][value]'] = value.toString();
        filterIndex++;
      });
    }

    // Call API
    final response = await ApiService.getPaginated<ApartmentModel>(
      path: '/apartment',
      queryParameters: queryParameters,
      fromJson: (json) => ApartmentModel.fromJson(json),
    );

    // Client-side filtering: Exclude apartments belonging to excludeUserId
    // This is necessary because backend doesn't support 'ne' operation
    // Note: If backend doesn't support 'user_id' filter, this will fail gracefully
    if (excludeUserId != null && response.data.isNotEmpty) {
      try {
        // Try to get user's apartment IDs using 'user_id' filter
        // If backend doesn't support this filter, it will return empty list
        final userApartmentsResponse = await ApiService.getPaginated<ApartmentModel>(
          path: '/apartment',
          queryParameters: {
            'page': 1,
            'perPage': 100, // Get enough to cover all user's apartments
            'filters[0][name]': 'user_id',
            'filters[0][operation]': 'eq',
            'filters[0][value]': excludeUserId.toString(),
          },
          fromJson: (json) => ApartmentModel.fromJson(json),
        );
        
        // If backend returned user's apartments, filter them out
        if (userApartmentsResponse.data.isNotEmpty) {
          final userApartmentIds = userApartmentsResponse.data.map((apt) => apt.id).toSet();

          // Filter out user's apartments
          final filteredData = response.data.where((apartment) {
            return !userApartmentIds.contains(apartment.id);
          }).toList();

          // Return filtered response
          return ApiResponse<ApartmentModel>(
            data: filteredData,
            page: response.page,
            perPage: response.perPage,
            lastPage: response.lastPage,
            total: response.total > userApartmentsResponse.total 
                ? response.total - userApartmentsResponse.total 
                : 0, // Adjust total count
          );
        }
        // If user has no apartments (or backend doesn't support filter), return original response
        // This means we can't filter, so show all apartments (better than showing nothing)
        debugPrint('ApartmentService: User has no apartments or backend doesn\'t support user_id filter - showing all apartments');
        return response;
      } catch (e) {
        // If error getting user's apartments, return original response (better than failing completely)
        debugPrint('ApartmentService: Error getting user apartments for exclusion: $e');
        return response;
      }
    }

    return response;
  }

  /// Get apartment details
  /// GET /apartment/{id}
  static Future<ApartmentModel> getApartmentDetails(int id) async {
    return await ApiService.get<ApartmentModel>(
      path: '/apartment/$id',
      fromJson: (json) => ApartmentModel.fromJson(json),
    );
  }

  /// Create a new apartment
  /// POST /apartment
  /// Body: JSON with apartment data (title, description, price, currency, governorate, city, address, number_of_room, number_of_bathroom, area, floor)
  static Future<ApartmentModel> storeApartment(Map<String, dynamic> data) async {
    return await ApiService.post<ApartmentModel>(
      path: '/apartment',
      data: data,
      fromJson: (json) => ApartmentModel.fromJson(json),
    );
  }

  /// Update an existing apartment
  /// PUT /apartment/:id
  /// Body: JSON with apartment data (all fields optional - partial update)
  static Future<ApartmentModel> updateApartment(int id, Map<String, dynamic> data) async {
    return await ApiService.put<ApartmentModel>(
      path: '/apartment/$id',
      data: data,
      fromJson: (json) => ApartmentModel.fromJson(json),
    );
  }

  /// Delete an apartment
  /// DELETE /apartment/:id
  static Future<void> deleteApartment(int id) async {
    await ApiService.delete(
      path: '/apartment/$id',
    );
  }
}

