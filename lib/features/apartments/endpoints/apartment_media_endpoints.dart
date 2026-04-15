/// Apartment Media Endpoints
/// Centralized endpoint definitions for Apartment Media Feature
/// 
/// This file contains all API endpoint paths used for apartment photo management.
/// This ensures consistency and makes it easy to update endpoints in one place.
/// 
/// Usage:
/// ```dart
/// final response = await ApiService.getList(
///   path: ApartmentMediaEndpoints.getPhotos(5),
///   fromJson: (json) => ApartmentPhotoModel.fromJson(json),
/// );
/// ```
class ApartmentMediaEndpoints {
  ApartmentMediaEndpoints._(); // Private constructor to prevent instantiation

  /// Base path for apartment media endpoints
  /// Pattern: /apartment/:id/photo
  static String basePath(int apartmentId) => '/apartment/$apartmentId/photo';

  // ============================================================================
  // Photo Management Endpoints
  // ============================================================================

  /// GET /apartment/:id/photo
  /// Get all photos for an apartment
  /// 
  /// Path parameters:
  ///   - id: int (apartment ID)
  /// 
  /// Response: List<ApartmentPhotoModel> or { data: [ApartmentPhotoModel] }
  /// Auth: Optional (Bearer token)
  /// 
  /// Example: getPhotos(5) => '/apartment/5/photo'
  static String getPhotos(int apartmentId) => basePath(apartmentId);

  /// POST /apartment/:id/photo
  /// Upload a photo for an apartment
  /// 
  /// Path parameters:
  ///   - id: int (apartment ID)
  /// 
  /// Body: multipart/form-data with:
  ///   - media[0][medium]: file (required)
  ///   - media[0][type]: string (required, "1" for image)
  ///   - media[0][for]: string (required, "apartment-photo")
  /// 
  /// Response: { "data": [{ "medium": {...}, "order": 1, "is_main": 1 }] }
  /// Auth: Required (Bearer token)
  /// 
  /// Example: uploadPhoto(5) => '/apartment/5/photo'
  static String uploadPhoto(int apartmentId) => basePath(apartmentId);

  /// DELETE /apartment/:id/photo/:photoId
  /// Delete a photo from an apartment
  /// 
  /// Path parameters:
  ///   - id: int (apartment ID)
  ///   - photoId: int (photo ID)
  /// 
  /// Response: 200 OK (void)
  /// Auth: Required (Bearer token)
  /// 
  /// Example: deletePhoto(5, 10) => '/apartment/5/photo/10'
  static String deletePhoto(int apartmentId, int photoId) =>
      '${basePath(apartmentId)}/$photoId';

  /// PUT /apartment/:id/photo/:photoId/main
  /// Set a photo as the main photo
  /// 
  /// Path parameters:
  ///   - id: int (apartment ID)
  ///   - photoId: int (photo ID)
  /// 
  /// Response: ApartmentPhotoModel (updated photo with is_main: true)
  /// Auth: Required (Bearer token)
  /// 
  /// Example: setMainPhoto(5, 10) => '/apartment/5/photo/10/main'
  static String setMainPhoto(int apartmentId, int photoId) =>
      '${basePath(apartmentId)}/$photoId/main';

  /// GET /apartment/:id/photo/main
  /// Get the main photo for an apartment
  /// 
  /// Path parameters:
  ///   - id: int (apartment ID)
  /// 
  /// Response: ApartmentPhotoModel or 404 if not found
  /// Auth: Optional (Bearer token)
  /// 
  /// Example: getMainPhoto(5) => '/apartment/5/photo/main'
  static String getMainPhoto(int apartmentId) =>
      '${basePath(apartmentId)}/main';
}
