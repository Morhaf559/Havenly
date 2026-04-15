/// Apartments Endpoints
/// Centralized endpoint definitions for Apartments Feature
/// 
/// This file contains all API endpoint paths used in the Apartments feature.
/// This ensures consistency and makes it easy to update endpoints in one place.
/// 
/// Usage:
/// ```dart
/// final response = await ApiService.get(
///   path: ApartmentsEndpoints.list,
///   queryParameters: {...},
/// );
/// ```
class ApartmentsEndpoints {
  ApartmentsEndpoints._(); // Private constructor to prevent instantiation

  /// Base path for apartments endpoints
  static const String basePath = '/apartment';

  // ============================================================================
  // List & Search Endpoints
  // ============================================================================

  /// GET /apartment
  /// Get apartments list (paginated)
  /// 
  /// Query parameters:
  ///   - page: int (page number, 1-indexed)
  ///   - perPage: int (items per page)
  ///   - keyword: string (search keyword)
  ///   - filters[0][name]: string
  ///   - filters[0][operation]: string (only 'eq' supported)
  ///   - filters[0][value]: string
  ///   - orders[0][name]: string (e.g., 'price')
  ///   - orders[0][direction]: string ('asc' or 'desc')
  /// 
  /// Response: { data: [ApartmentModel], page, perPage, lastPage, total }
  /// Auth: Required for some filters (Bearer token)
  static const String list = basePath;

  /// GET /apartments/available
  /// Get available apartments only
  /// 
  /// Response: { data: [ApartmentModel], page, perPage, lastPage, total }
  /// Auth: Optional (Bearer token)
  /// Note: Similar to list endpoint with status='available' filter
  static const String available = '/apartments/available';

  // ============================================================================
  // Details Endpoint
  // ============================================================================

  /// GET /apartment/:id
  /// Get apartment details by ID
  /// 
  /// Path parameters:
  ///   - id: int (apartment ID)
  /// 
  /// Response: ApartmentModel
  /// Auth: Optional (Bearer token)
  /// 
  /// Example: getDetails(5) => '/apartment/5'
  static String getDetails(int apartmentId) => '$basePath/$apartmentId';

  // ============================================================================
  // Owner CRUD Endpoints
  // ============================================================================

  /// POST /apartment
  /// Create a new apartment (Owner only)
  /// 
  /// Body: {
  ///   title: { en: "...", ar: "..." },
  ///   description: { en: "...", ar: "..." },
  ///   price: string (e.g., "300.00"),
  ///   currency: string (e.g., "$"),
  ///   governorate: int (ID),
  ///   city: { en: "...", ar: "..." } or int (ID),
  ///   address: { en: "...", ar: "..." },
  ///   number_of_room: string (e.g., "4"),
  ///   number_of_bathroom: string (e.g., "2"),
  ///   area: string (e.g., "160"),
  ///   floor: string (e.g., "1")
  /// }
  /// Response: ApartmentModel
  /// Auth: Required (Bearer token)
  static const String create = basePath;

  /// PUT /apartment/:id
  /// Update an existing apartment (Owner only)
  /// 
  /// Path parameters:
  ///   - id: int (apartment ID)
  /// 
  /// Body: Partial update (all fields optional)
  /// Response: ApartmentModel
  /// Auth: Required (Bearer token)
  /// 
  /// Example: update(5, {...}) => '/apartment/5'
  static String update(int apartmentId) => '$basePath/$apartmentId';

  /// DELETE /apartment/:id
  /// Delete an apartment (Owner only)
  /// 
  /// Path parameters:
  ///   - id: int (apartment ID)
  /// 
  /// Response: 200 OK (void)
  /// Auth: Required (Bearer token)
  /// 
  /// Example: delete(5) => '/apartment/5'
  static String delete(int apartmentId) => '$basePath/$apartmentId';

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Build endpoint with dynamic path segment
  /// 
  /// Example: buildPath('apartments', id: 5) => '/apartment/apartments/5'
  static String buildPath(String path, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) {
      return '$basePath/$path';
    }

    String result = '$basePath/$path';
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value.toString());
      result = result.replaceAll('{$key}', value.toString());
    });

    return result;
  }
}
