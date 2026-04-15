import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/services/data_refresh_service.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_photo_model.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartment_media_repository.dart';
import 'package:my_havenly_application/features/governorates/controllers/governorate_controller.dart';

/// Edit Apartment Controller
/// Manages form state and submission for editing an existing apartment
/// Uses ApartmentsRepository for data operations (handles string→number, localization)
/// Uses ApartmentMediaRepository for photo operations (isolated logic)
class EditApartmentController extends BaseController {
  final ApartmentsRepository _repository = Get.find<ApartmentsRepository>();
  final ApartmentMediaRepository _mediaRepository = Get.find<ApartmentMediaRepository>();
  final int apartmentId;

  // Form Controllers
  final titleArController = TextEditingController();
  final titleEnController = TextEditingController();
  final descriptionArController = TextEditingController();
  final descriptionEnController = TextEditingController();
  final priceController = TextEditingController();
  final currencyController = TextEditingController();
  final cityArController = TextEditingController();
  final cityEnController = TextEditingController();
  final addressArController = TextEditingController();
  final addressEnController = TextEditingController();
  final numberOfRoomsController = TextEditingController();
  final numberOfBathroomsController = TextEditingController();
  final areaController = TextEditingController();
  final floorController = TextEditingController();

  // Selected images (new images to upload)
  final RxList<File> newImages = <File>[].obs;
  
  // Existing photos from API
  final RxList<ApartmentPhotoModel> existingPhotos = <ApartmentPhotoModel>[].obs;
  
  // Selected governorate ID
  final Rx<int?> selectedGovernorateId = Rx<int?>(null);

  // Apartment data
  final Rx<ApartmentModel?> apartment = Rx<ApartmentModel?>(null);

  EditApartmentController({required this.apartmentId});

  @override
  void onInit() {
    super.onInit();
    loadApartmentData();
  }

  @override
  void onClose() {
    titleArController.dispose();
    titleEnController.dispose();
    descriptionArController.dispose();
    descriptionEnController.dispose();
    priceController.dispose();
    currencyController.dispose();
    cityArController.dispose();
    cityEnController.dispose();
    addressArController.dispose();
    addressEnController.dispose();
    numberOfRoomsController.dispose();
    numberOfBathroomsController.dispose();
    areaController.dispose();
    floorController.dispose();
    super.onClose();
  }

  /// Load apartment data and photos
  Future<void> loadApartmentData() async {
    try {
      setLoading(true);
      clearError();

      // Load apartment details using repository
      final apartmentData = await _repository.getApartmentDetails(apartmentId);
      apartment.value = apartmentData;

      // Load photos using repository (isolated logic)
      final photos = await _mediaRepository.getPhotos(apartmentId);
      existingPhotos.value = photos;

      // Pre-fill form fields
      _fillFormFields(apartmentData);
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'Error'.tr,
        'Failed to load apartment data: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setLoading(false);
    }
  }

  /// Pre-fill form fields with apartment data
  void _fillFormFields(ApartmentModel apartmentData) {
    // Title
    if (apartmentData.title != null) {
      titleArController.text = apartmentData.title!['ar'] as String? ?? '';
      titleEnController.text = apartmentData.title!['en'] as String? ?? '';
    }

    // Description
    if (apartmentData.description != null) {
      descriptionArController.text = apartmentData.description!['ar'] as String? ?? '';
      descriptionEnController.text = apartmentData.description!['en'] as String? ?? '';
    }

    // Price
    priceController.text = apartmentData.price.toString();

    // Currency
    currencyController.text = apartmentData.currency ?? '';

    // Governorate
    if (apartmentData.governorate != null) {
      // Try to parse governorate as int (it might be an ID)
      final governorateId = int.tryParse(apartmentData.governorate!);
      if (governorateId != null) {
        selectedGovernorateId.value = governorateId;
      } else {
        // If governorate is a string (name), find its ID from GovernorateController
        try {
          if (Get.isRegistered<GovernorateController>()) {
            final governorateController = Get.find<GovernorateController>();
            final governorateName = apartmentData.governorate!;
            // Find governorate by name (check both Arabic and English)
            try {
              final matchingGovernorate = governorateController.governorates.firstWhere(
                (gov) => gov.getLocalizedName('ar') == governorateName ||
                         gov.getLocalizedName('en') == governorateName,
              );
              selectedGovernorateId.value = matchingGovernorate.id;
            } catch (e) {
              // No matching governorate found, skip
              debugPrint('EditApartmentController: Could not find governorate ID for name: $governorateName');
            }
          }
        } catch (e) {
          // If governorate controller is not available or error occurs, skip
          debugPrint('EditApartmentController: Could not find governorate ID: $e');
        }
      }
    }

    // City
    if (apartmentData.city != null) {
      // City might be a string or a Map
      if (apartmentData.city is Map) {
        final cityMap = apartmentData.city as Map<String, dynamic>;
        cityArController.text = cityMap['ar'] as String? ?? '';
        cityEnController.text = cityMap['en'] as String? ?? '';
      } else {
        // If city is a string, set it for both languages
        final cityStr = apartmentData.city as String;
        cityArController.text = cityStr;
        cityEnController.text = cityStr;
      }
    }

    // Address
    if (apartmentData.address != null) {
      addressArController.text = apartmentData.address!['ar'] as String? ?? '';
      addressEnController.text = apartmentData.address!['en'] as String? ?? '';
    }

    // Number of rooms
    if (apartmentData.numberOfRoom != null) {
      numberOfRoomsController.text = apartmentData.numberOfRoom.toString();
    }

    // Number of bathrooms
    if (apartmentData.numberOfBathroom != null) {
      numberOfBathroomsController.text = apartmentData.numberOfBathroom.toString();
    }

    // Area
    if (apartmentData.area != null) {
      areaController.text = apartmentData.area.toString();
    }

    // Floor
    if (apartmentData.floor != null) {
      floorController.text = apartmentData.floor.toString();
    }
  }

  /// Add new image to upload
  void addImage(File image) {
    newImages.add(image);
  }

  /// Remove new image
  void removeNewImage(int index) {
    if (index >= 0 && index < newImages.length) {
      newImages.removeAt(index);
    }
  }

  /// Delete existing photo
  /// Uses Repository (isolated logic)
  Future<void> deletePhoto(int photoId) async {
    try {
      setLoading(true);
      await _mediaRepository.deletePhoto(apartmentId, photoId);
      
      // Remove from list
      existingPhotos.removeWhere((photo) => photo.id == photoId);
      
      Get.snackbar(
        'Success'.tr,
        'Photo deleted successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      handleError(e, title: 'Error deleting photo');
      Get.snackbar(
        'Error'.tr,
        'Failed to delete photo: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setLoading(false);
    }
  }

  /// Set main photo
  /// Uses Repository (isolated logic)
  Future<void> setMainPhoto(int photoId) async {
    try {
      setLoading(true);
      await _mediaRepository.setMainPhoto(apartmentId, photoId);
      
      // Update photos list
      await loadApartmentData();
      
      Get.snackbar(
        'Success'.tr,
        'Main photo updated successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      handleError(e, title: 'Error setting main photo');
      Get.snackbar(
        'Error'.tr,
        'Failed to set main photo: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setLoading(false);
    }
  }

  /// Set selected governorate
  void setGovernorate(int? governorateId) {
    selectedGovernorateId.value = governorateId;
  }

  /// Validate form fields
  String? validateForm() {
    if (titleArController.text.trim().isEmpty && titleEnController.text.trim().isEmpty) {
      return 'Title is required in Arabic or English'.tr;
    }
    if (priceController.text.trim().isEmpty) {
      return 'Price is required'.tr;
    }
    if (double.tryParse(priceController.text.trim()) == null) {
      return 'Price must be a number'.tr;
    }
    if (numberOfRoomsController.text.trim().isNotEmpty) {
      if (int.tryParse(numberOfRoomsController.text.trim()) == null) {
        return 'Number of rooms must be a number'.tr;
      }
    }
    if (numberOfBathroomsController.text.trim().isNotEmpty) {
      if (int.tryParse(numberOfBathroomsController.text.trim()) == null) {
        return 'Number of bathrooms must be a number'.tr;
      }
    }
    if (areaController.text.trim().isNotEmpty) {
      if (double.tryParse(areaController.text.trim()) == null) {
        return 'Area must be a number'.tr;
      }
    }
    if (floorController.text.trim().isNotEmpty) {
      if (int.tryParse(floorController.text.trim()) == null) {
        return 'Floor must be a number'.tr;
      }
    }
    return null;
  }

  /// Build apartment data map for API (all fields - old + new)
  /// Sends all fields to ensure unchanged fields are preserved
  Map<String, dynamic> _buildApartmentData() {
    final Map<String, dynamic> data = {};

    // Title (multi-language) - always send if apartment has title
    final title = <String, String>{};
    final titleAr = titleArController.text.trim();
    final titleEn = titleEnController.text.trim();
    
    // Use current values if provided, otherwise use original values
    if (titleAr.isNotEmpty || titleEn.isNotEmpty) {
      title['ar'] = titleAr.isNotEmpty ? titleAr : (apartment.value?.title?['ar'] as String? ?? '');
      title['en'] = titleEn.isNotEmpty ? titleEn : (apartment.value?.title?['en'] as String? ?? '');
      data['title'] = title;
    } else if (apartment.value?.title != null) {
      // Keep original title if not changed
      data['title'] = apartment.value!.title;
    }

    // Description (multi-language)
    final description = <String, String>{};
    final descAr = descriptionArController.text.trim();
    final descEn = descriptionEnController.text.trim();
    
    if (descAr.isNotEmpty || descEn.isNotEmpty) {
      description['ar'] = descAr.isNotEmpty ? descAr : (apartment.value?.description?['ar'] as String? ?? '');
      description['en'] = descEn.isNotEmpty ? descEn : (apartment.value?.description?['en'] as String? ?? '');
      data['description'] = description;
    } else if (apartment.value?.description != null) {
      // Keep original description if not changed
      data['description'] = apartment.value!.description;
    }

    // Price - always send
    if (priceController.text.trim().isNotEmpty) {
      data['price'] = priceController.text.trim();
    } else if (apartment.value != null) {
      data['price'] = apartment.value!.price.toString();
    }

    // Currency
    if (currencyController.text.trim().isNotEmpty) {
      data['currency'] = currencyController.text.trim();
    } else if (apartment.value?.currency != null && apartment.value!.currency!.isNotEmpty) {
      data['currency'] = apartment.value!.currency;
    }

    // Governorate - always send if available
    if (selectedGovernorateId.value != null) {
      data['governorate'] = selectedGovernorateId.value!;
    } else if (apartment.value?.governorate != null) {
      // Try to parse governorate as int (it might be an ID)
      final governorateId = int.tryParse(apartment.value!.governorate!);
      if (governorateId != null) {
        data['governorate'] = governorateId;
      } else {
        // If governorate is a string (name), find its ID from GovernorateController
        try {
          if (Get.isRegistered<GovernorateController>()) {
            final governorateController = Get.find<GovernorateController>();
            final governorateName = apartment.value!.governorate!;
            // Find governorate by name (check both Arabic and English)
            try {
              final matchingGovernorate = governorateController.governorates.firstWhere(
                (gov) => gov.getLocalizedName('ar') == governorateName ||
                         gov.getLocalizedName('en') == governorateName,
              );
              data['governorate'] = matchingGovernorate.id;
            } catch (e) {
              // No matching governorate found, skip
              debugPrint('EditApartmentController: Could not find governorate ID for name: $governorateName');
            }
          }
        } catch (e) {
          // If governorate controller is not available or error occurs, skip
          debugPrint('EditApartmentController: Could not find governorate ID: $e');
        }
      }
    }

    // City (multi-language)
    final city = <String, String>{};
    final cityAr = cityArController.text.trim();
    final cityEn = cityEnController.text.trim();
    
    if (cityAr.isNotEmpty || cityEn.isNotEmpty) {
      // If city was originally a Map, preserve structure
      if (apartment.value?.city is Map) {
        final originalCity = apartment.value!.city as Map<String, dynamic>;
        city['ar'] = cityAr.isNotEmpty ? cityAr : (originalCity['ar'] as String? ?? '');
        city['en'] = cityEn.isNotEmpty ? cityEn : (originalCity['en'] as String? ?? '');
      } else {
        final cityStr = apartment.value?.city?.toString() ?? '';
        city['ar'] = cityAr.isNotEmpty ? cityAr : cityStr;
        city['en'] = cityEn.isNotEmpty ? cityEn : cityStr;
      }
      data['city'] = city;
    } else if (apartment.value?.city != null) {
      // Keep original city if not changed
      if (apartment.value!.city is Map) {
        data['city'] = apartment.value!.city;
      } else {
        // Convert string city to Map
        final cityStr = apartment.value!.city as String;
        data['city'] = {'ar': cityStr, 'en': cityStr};
      }
    }

    // Address (multi-language)
    final address = <String, String>{};
    final addrAr = addressArController.text.trim();
    final addrEn = addressEnController.text.trim();
    
    if (addrAr.isNotEmpty || addrEn.isNotEmpty) {
      address['ar'] = addrAr.isNotEmpty ? addrAr : (apartment.value?.address?['ar'] as String? ?? '');
      address['en'] = addrEn.isNotEmpty ? addrEn : (apartment.value?.address?['en'] as String? ?? '');
      data['address'] = address;
    } else if (apartment.value?.address != null) {
      // Keep original address if not changed
      data['address'] = apartment.value!.address;
    }

    // Number of rooms
    if (numberOfRoomsController.text.trim().isNotEmpty) {
      data['number_of_room'] = numberOfRoomsController.text.trim();
    } else if (apartment.value?.numberOfRoom != null) {
      data['number_of_room'] = apartment.value!.numberOfRoom.toString();
    }

    // Number of bathrooms
    if (numberOfBathroomsController.text.trim().isNotEmpty) {
      data['number_of_bathroom'] = numberOfBathroomsController.text.trim();
    } else if (apartment.value?.numberOfBathroom != null) {
      data['number_of_bathroom'] = apartment.value!.numberOfBathroom.toString();
    }

    // Area
    if (areaController.text.trim().isNotEmpty) {
      data['area'] = areaController.text.trim();
    } else if (apartment.value?.area != null) {
      data['area'] = apartment.value!.area.toString();
    }

    // Floor
    if (floorController.text.trim().isNotEmpty) {
      data['floor'] = floorController.text.trim();
    } else if (apartment.value?.floor != null) {
      data['floor'] = apartment.value!.floor.toString();
    }

    return data;
  }

  /// Update apartment
  Future<bool> updateApartment() async {
    try {
      // Validate form
      final validationError = validateForm();
      if (validationError != null) {
        setError(validationError);
        Get.snackbar(
          'Error'.tr,
          validationError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      setLoading(true);
      clearError();

      // Build apartment data (raw from form)
      // Repository will handle conversion (number→string, localization)
      final apartmentData = _buildApartmentData();

      // Update apartment using repository
      await _repository.updateApartment(apartmentId, apartmentData);

      // Upload new images using repository (isolated logic)
      if (newImages.isNotEmpty) {
        try {
          await _mediaRepository.uploadMultiplePhotos(
            apartmentId,
            newImages,
          );
        } catch (e) {
          // Error logged but operation continues
        }
      }

      Get.snackbar(
        'Success'.tr,
        'Apartment updated successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Close edit screen first
      Get.back();

      // Navigate to Dashboard and refresh data using centralized service
      DataRefreshService.navigateToDashboardAndRefresh(animate: false);
      
      return true;
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'Error'.tr,
        'Failed to update apartment: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Delete apartment
  Future<bool> deleteApartment() async {
    try {
      setLoading(true);
      clearError();

      // Delete apartment using repository
      await _repository.deleteApartment(apartmentId);

      Get.snackbar(
        'Success'.tr,
        'Apartment deleted successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Close edit screen first
      Get.back();

      // Navigate to Dashboard and refresh data using centralized service
      DataRefreshService.navigateToDashboardAndRefresh(animate: false);
      
      return true;
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'Error'.tr,
        'Failed to delete apartment: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }
}

