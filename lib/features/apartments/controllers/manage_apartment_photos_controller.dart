import 'dart:io';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_photo_model.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartment_media_repository.dart';

/// Manage Apartment Photos Controller
/// Handles apartment photos management operations
/// Uses ApartmentMediaRepository for all data operations
class ManageApartmentPhotosController extends BaseController {
  final ApartmentMediaRepository _repository = Get.find<ApartmentMediaRepository>();

  final int apartmentId;
  
  // Photos list
  final RxList<ApartmentPhotoModel> photos = <ApartmentPhotoModel>[].obs;
  
  // Main photo
  final Rx<ApartmentPhotoModel?> mainPhoto = Rx<ApartmentPhotoModel?>(null);

  ManageApartmentPhotosController({required this.apartmentId});

  @override
  void onInit() {
    super.onInit();
    loadPhotos();
  }

  /// Load all photos for the apartment
  /// Uses Repository (isolated logic)
  Future<void> loadPhotos() async {
    try {
      setLoading(true);
      clearError();

      // Load all photos and main photo using repository convenience method
      final result = await _repository.getPhotosWithMain(apartmentId);

      photos.value = result['photos'] as List<ApartmentPhotoModel>;
      mainPhoto.value = result['mainPhoto'] as ApartmentPhotoModel?;

      // If no main photo found but photos exist, set first one as main
      if (mainPhoto.value == null && photos.isNotEmpty) {
        mainPhoto.value = photos.firstWhere(
          (photo) => photo.isMain,
          orElse: () => photos.first,
        );
      }
    } catch (e) {
      handleError(e, title: 'Error loading photos');
    } finally {
      setLoading(false);
    }
  }

  /// Upload a new photo
  /// Uses Repository (isolated logic)
  Future<bool> uploadPhoto(File imageFile) async {
    try {
      setLoading(true);
      clearError();

      await _repository.uploadPhoto(
        apartmentId,
        imageFile,
      );

      // Reload photos to get updated list
      await loadPhotos();

      Get.snackbar(
        'Success'.tr,
        'Photo uploaded successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      handleError(e, title: 'Error uploading photo');
      Get.snackbar(
        'Error'.tr,
        'Failed to upload photo'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Delete a photo
  /// Uses Repository (isolated logic)
  Future<bool> deletePhoto(int photoId) async {
    try {
      setLoading(true);
      clearError();

      await _repository.deletePhoto(apartmentId, photoId);

      // Remove from local list
      photos.removeWhere((photo) => photo.id == photoId);

      // If deleted photo was main, update main photo
      if (mainPhoto.value?.id == photoId) {
        mainPhoto.value = photos.isNotEmpty ? photos.first : null;
      }

      Get.snackbar(
        'Success'.tr,
        'Photo deleted successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      handleError(e, title: 'Error deleting photo');
      Get.snackbar(
        'Error'.tr,
        'Failed to delete photo'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Set a photo as main
  /// Uses Repository (isolated logic)
  Future<bool> setMainPhoto(int photoId) async {
    try {
      setLoading(true);
      clearError();

      final updatedPhoto = await _repository.setMainPhoto(
        apartmentId,
        photoId,
      );

      // Update main photo
      mainPhoto.value = updatedPhoto;

      // Update isMain status in photos list
      for (var i = 0; i < photos.length; i++) {
        if (photos[i].id == photoId) {
          photos[i] = updatedPhoto;
        } else if (photos[i].isMain) {
          // Create a new instance without isMain
          photos[i] = ApartmentPhotoModel(
            id: photos[i].id,
            name: photos[i].name,
            url: photos[i].url,
            extension: photos[i].extension,
            type: photos[i].type,
            forType: photos[i].forType,
            isMain: false,
            createdAt: photos[i].createdAt,
            createdBy: photos[i].createdBy,
          );
        }
      }

      Get.snackbar(
        'Success'.tr,
        'Main photo updated successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
        duration: const Duration(seconds: 2),
      );

      return true;
    } catch (e) {
      handleError(e, title: 'Error setting main photo');
      Get.snackbar(
        'Error'.tr,
        'Failed to set main photo'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Check if a photo is the main photo
  bool isMainPhoto(int photoId) {
    return mainPhoto.value?.id == photoId;
  }
}

