import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/services/data_refresh_service.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartment_media_repository.dart';

class AddApartmentController extends BaseController {
  final ApartmentsRepository _repository = Get.find<ApartmentsRepository>();
  final ApartmentMediaRepository _mediaRepository =
      Get.find<ApartmentMediaRepository>();
  final titleArController = TextEditingController();
  final titleEnController = TextEditingController();
  final descriptionArController = TextEditingController();
  final descriptionEnController = TextEditingController();
  final priceController = TextEditingController();
  final currencyController = TextEditingController(text: '\$');
  final cityArController = TextEditingController();
  final cityEnController = TextEditingController();
  final addressArController = TextEditingController();
  final addressEnController = TextEditingController();
  final numberOfRoomsController = TextEditingController();
  final numberOfBathroomsController = TextEditingController();
  final areaController = TextEditingController();
  final floorController = TextEditingController();

  final RxList<File> selectedImages = <File>[].obs;

  final Rx<int?> selectedGovernorateId = Rx<int?>(null);

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

  void addImage(File image) {
    selectedImages.add(image);
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void setGovernorate(int? governorateId) {
    selectedGovernorateId.value = governorateId;
  }

  String? validateForm() {
    if (titleArController.text.trim().isEmpty &&
        titleEnController.text.trim().isEmpty) {
      return 'Title is required in Arabic or English'.tr;
    }
    if (priceController.text.trim().isEmpty) {
      return 'Price is required'.tr;
    }
    if (double.tryParse(priceController.text.trim()) == null) {
      return 'Price must be a number'.tr;
    }
    if (selectedGovernorateId.value == null) {
      return 'Governorate is required'.tr;
    }
    if (cityArController.text.trim().isEmpty &&
        cityEnController.text.trim().isEmpty) {
      return 'City is required in Arabic or English'.tr;
    }
    if (addressArController.text.trim().isEmpty &&
        addressEnController.text.trim().isEmpty) {
      return 'Address is required in Arabic or English'.tr;
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
    if (selectedImages.isEmpty) {
      return 'At least one image is required'.tr;
    }
    return null;
  }

  /// Build apartment data map for API
  Map<String, dynamic> _buildApartmentData() {
    final Map<String, dynamic> data = {};

    // Title (multi-language)
    final title = <String, String>{};
    if (titleArController.text.trim().isNotEmpty) {
      title['ar'] = titleArController.text.trim();
    }
    if (titleEnController.text.trim().isNotEmpty) {
      title['en'] = titleEnController.text.trim();
    }
    if (title.isNotEmpty) {
      data['title'] = title;
    }

    // Description (multi-language)
    final description = <String, String>{};
    if (descriptionArController.text.trim().isNotEmpty) {
      description['ar'] = descriptionArController.text.trim();
    }
    if (descriptionEnController.text.trim().isNotEmpty) {
      description['en'] = descriptionEnController.text.trim();
    }
    if (description.isNotEmpty) {
      data['description'] = description;
    }

    if (priceController.text.trim().isNotEmpty) {
      data['price'] = priceController.text.trim();
    }

    if (currencyController.text.trim().isNotEmpty) {
      data['currency'] = currencyController.text.trim();
    }

    if (selectedGovernorateId.value != null) {
      data['governorate'] = selectedGovernorateId.value!;
    }

    final city = <String, String>{};
    if (cityArController.text.trim().isNotEmpty) {
      city['ar'] = cityArController.text.trim();
    }
    if (cityEnController.text.trim().isNotEmpty) {
      city['en'] = cityEnController.text.trim();
    }
    if (city.isNotEmpty) {
      data['city'] = city;
    }

    // Address (multi-language)
    final address = <String, String>{};
    if (addressArController.text.trim().isNotEmpty) {
      address['ar'] = addressArController.text.trim();
    }
    if (addressEnController.text.trim().isNotEmpty) {
      address['en'] = addressEnController.text.trim();
    }
    if (address.isNotEmpty) {
      data['address'] = address;
    }

    // Number of rooms
    if (numberOfRoomsController.text.trim().isNotEmpty) {
      data['number_of_room'] = numberOfRoomsController.text.trim();
    }

    // Number of bathrooms
    if (numberOfBathroomsController.text.trim().isNotEmpty) {
      data['number_of_bathroom'] = numberOfBathroomsController.text.trim();
    }

    // Area
    if (areaController.text.trim().isNotEmpty) {
      data['area'] = areaController.text.trim();
    }

    // Floor
    if (floorController.text.trim().isNotEmpty) {
      data['floor'] = floorController.text.trim();
    }

    return data;
  }

  /// Submit form (create apartment and upload images)
  Future<bool> submit() async {
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

      // Create apartment using repository
      final apartment = await _repository.createApartment(apartmentData);

      // Upload images using repository (isolated logic)
      if (selectedImages.isNotEmpty) {
        try {
          // Upload all photos at once (better progress tracking)
          await _mediaRepository.uploadMultiplePhotos(
            apartment.id,
            selectedImages,
          );

          // Set first image as main photo
          try {
            final photos = await _mediaRepository.getPhotos(apartment.id);
            if (photos.isNotEmpty) {
              await _mediaRepository.setMainPhoto(
                apartment.id,
                photos.first.id,
              );
            }
          } catch (e) {
            // Log error but don't fail the whole operation
            // Error logged but operation continues
          }
        } catch (e) {
          // Log error but don't fail the whole operation
          // Error logged but operation continues
        }
      }

      // Close add apartment screen first
      Get.back();

      // Navigate to Dashboard and refresh data using centralized service
      // This will navigate to MainWrapperScreen and switch to Dashboard tab
      DataRefreshService.navigateToDashboardAndRefresh(animate: false);

      // Show success message after navigation and data refresh
      // Delay ensures navigation is complete and data is refreshed
      Future.delayed(const Duration(milliseconds: 600), () {
        Get.snackbar(
          'Success'.tr,
          'Apartment added successfully'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      });

      return true;
    } catch (e) {
      setError(e.toString());
      Get.snackbar(
        'Error'.tr,
        'Failed to add apartment: ${e.toString()}'.tr,
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
