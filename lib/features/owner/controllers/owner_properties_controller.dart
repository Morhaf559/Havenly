import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/core/routes/app_routes.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartment_media_repository.dart';
import 'package:my_havenly_application/features/profile/models/property.dart';

class OwnerPropertiesController extends BaseController {
  final RxList<Property> properties = <Property>[].obs;
  final RxList<Property> allProperties =
      <Property>[].obs; // All loaded properties for filtering
  final RxBool isLoadingProperties = false.obs;
  final RxString propertiesErrorMessage = ''.obs;
  final RxString searchText = ''.obs;

  final AuthStateController _authStateController =
      Get.find<AuthStateController>();
  final ApartmentsRepository _apartmentsRepository =
      Get.find<ApartmentsRepository>();
  final ApartmentMediaRepository _mediaRepository =
      Get.find<ApartmentMediaRepository>();

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  Future<void> loadProperties() async {
    try {
      isLoadingProperties.value = true;
      propertiesErrorMessage.value = '';
      clearError();

      debugPrint(
        'OwnerPropertiesController: Loading owner properties from API...',
      );

      final currentUser = _authStateController.user;
      final userId = currentUser?.id;

      if (userId == null) {
        debugPrint('OwnerPropertiesController: User ID is null');
        throw Exception('Unable to get user ID');
      }

      debugPrint('OwnerPropertiesController: User ID: $userId');

      // Fetch apartments with user_id filter using ApartmentsRepository
      debugPrint(
        'OwnerPropertiesController: Fetching apartments with filter: user_id=$userId',
      );
      final filter = ApartmentFilterModel(customFilters: {'user_id': userId});
      final response = await _apartmentsRepository.getApartments(
        page: 1,
        perPage: 100,
        filters: filter,
      );

      debugPrint(
        'OwnerPropertiesController: API Response - Total: ${response.total}, Data length: ${response.data.length}',
      );

      final apartments = response.data;

      final locale = Get.locale?.languageCode ?? 'ar';
      
      // First, create properties with images from apartment model
      final propertiesList = apartments.map((apartment) {
        final title = apartment.getLocalizedTitle(locale) ?? 'No Title';
        final imageUrl = apartment.mainImage ?? '';
        
        return Property(
          id: apartment.id,
          name: title,
          location: apartment.city ?? 'غير محدد',
          imageUrl: imageUrl,
        );
      }).toList();
      
      // Then, load missing images in parallel (but limit concurrency)
      final propertiesWithImages = await _loadMissingImages(propertiesList);
      
      allProperties.value = propertiesWithImages;

      _applySearchFilter();

      debugPrint(
        'OwnerPropertiesController: Properties loaded successfully: ${allProperties.length} properties',
      );
    } catch (e, stackTrace) {
      propertiesErrorMessage.value = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      handleError(e, title: 'Error loading properties');
      debugPrint('OwnerPropertiesController: Error loading properties: $e');
      debugPrint('OwnerPropertiesController: Stack trace: $stackTrace');
      properties.value = [];
      allProperties.value = [];
    } finally {
      isLoadingProperties.value = false;
    }
  }

  void updateSearchText(String text) {
    searchText.value = text;
    _applySearchFilter();
  }

  void _applySearchFilter() {
    if (searchText.value.isEmpty) {
      properties.value = allProperties;
      return;
    }

    final searchLower = searchText.value.toLowerCase();
    properties.value = allProperties.where((property) {
      return property.name.toLowerCase().contains(searchLower) ||
          property.location.toLowerCase().contains(searchLower);
    }).toList();
  }

  void clearSearch() {
    searchText.value = '';
    _applySearchFilter();
  }

  /// Load missing images for properties in parallel (with concurrency limit)
  /// Only loads images for properties that don't have an image URL
  Future<List<Property>> _loadMissingImages(List<Property> properties) async {
    final propertiesNeedingImages = properties.where((p) => p.imageUrl.isEmpty).toList();
    
    if (propertiesNeedingImages.isEmpty) {
      return properties;
    }

    // Load images in parallel, but limit concurrency to avoid overwhelming the API
    const maxConcurrency = 5;
    final results = <Property>[];
    
    for (int i = 0; i < propertiesNeedingImages.length; i += maxConcurrency) {
      final batch = propertiesNeedingImages.skip(i).take(maxConcurrency).toList();
      
      final batchResults = await Future.wait(
        batch.map((property) async {
          try {
            // Try to get main photo first
            final mainPhoto = await _mediaRepository.getMainPhoto(property.id);
            if (mainPhoto != null && mainPhoto.url != null && mainPhoto.url!.isNotEmpty) {
              return Property(
                id: property.id,
                name: property.name,
                location: property.location,
                imageUrl: mainPhoto.url!,
              );
            }
            
            // If no main photo, try to get first photo
            final photos = await _mediaRepository.getPhotos(property.id);
            if (photos.isNotEmpty && photos.first.url != null && photos.first.url!.isNotEmpty) {
              return Property(
                id: property.id,
                name: property.name,
                location: property.location,
                imageUrl: photos.first.url!,
              );
            }
            
            // No photos found, return original property
            return property;
          } catch (e) {
            // If error getting photos, return original property
            debugPrint('OwnerPropertiesController: Error getting photos for apartment ${property.id}: $e');
            return property;
          }
        }),
      );
      
      results.addAll(batchResults);
    }
    
    // Update properties list with loaded images
    final updatedProperties = properties.map((property) {
      if (property.imageUrl.isNotEmpty) {
        return property; // Keep properties that already have images
      }
      
      // Find updated property from results
      final updated = results.firstWhere(
        (p) => p.id == property.id,
        orElse: () => property,
      );
      return updated;
    }).toList();
    
    return updatedProperties;
  }

  void onViewPropertyDetails(Property property) {
    Get.toNamed(
      AppRoutes.apartmentDetails,
      arguments: {'apartmentId': property.id, 'showBookingButton': false},
    );
  }

  void onEditPropertyPressed(Property property) async {
    await Get.toNamed('/apartments/edit/${property.id}');

    loadProperties();
  }

  void onManagePhotosPressed(Property property) {
    Get.toNamed('/apartments/${property.id}/photos');
  }

  void onViewRequestsPressed(Property property) {
    Get.toNamed(AppRoutes.ownerReservationRequests, arguments: property.id);
  }

  @override
  Future<void> refresh() async {
    await loadProperties();
  }
}
