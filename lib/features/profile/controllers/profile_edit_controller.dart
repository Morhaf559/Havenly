import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/core/utils/date_helper.dart';
import 'package:my_havenly_application/core/services/data_refresh_service.dart';
import 'package:my_havenly_application/features/profile/repositories/profile_repository.dart';
import 'package:my_havenly_application/features/media/repositories/media_repository.dart';
import 'package:my_havenly_application/features/media/endpoints/media_endpoints.dart';
import 'package:my_havenly_application/features/profile/controllers/profile_controller.dart';

class ProfileEditController extends BaseController {
  final ProfileRepository _repository = Get.find<ProfileRepository>();
  final MediaRepository _mediaRepository = Get.find<MediaRepository>();
  final AuthStateController _authStateController =
      Get.find<AuthStateController>();
  final ImagePicker _imagePicker = ImagePicker();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();
  final dateOfBirthController = TextEditingController();

  final Rx<File?> selectedPersonalPhoto = Rx<File?>(null);
  final Rx<File?> selectedIdPhoto = Rx<File?>(null);

  final Rx<DateTime?> selectedDateOfBirth = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeForm();
  }

  void _initializeForm() {
    final user = _authStateController.user;
    if (user != null) {
      firstNameController.text = user.firstName ?? '';
      lastNameController.text = user.lastName ?? '';
      phoneController.text = user.phone ?? '';
      usernameController.text = user.username ?? '';

      if (user.dateOfBirth != null) {
        final date = DateHelper.parseDate(user.dateOfBirth!);
        if (date != null) {
          selectedDateOfBirth.value = date;
          dateOfBirthController.text = DateHelper.formatForDisplay(date);
        }
      }
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    dateOfBirthController.dispose();
    super.onClose();
  }

  Future<void> pickImage({
    required ImageSource source,
    bool isPersonalPhoto = true,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        if (isPersonalPhoto) {
          selectedPersonalPhoto.value = File(pickedFile.path);
        } else {
          selectedIdPhoto.value = File(pickedFile.path);
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to pick image: ${e.toString()}'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          selectedDateOfBirth.value ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDateOfBirth.value = picked;
      dateOfBirthController.text = DateHelper.formatForDisplay(picked);
    }
  }

  String? validateForm() {
    if (firstNameController.text.trim().isEmpty &&
        lastNameController.text.trim().isEmpty) {
      return 'First name or last name is required'.tr;
    }
    if (phoneController.text.trim().isNotEmpty) {
      // Basic phone validation (can be enhanced)
      if (phoneController.text.trim().length < 10) {
        return 'Phone number must be at least 10 digits'.tr;
      }
    }
    return null;
  }

  Future<void> updateProfile() async {
    try {
      final validationError = validateForm();
      if (validationError != null) {
        Get.snackbar(
          'Error'.tr,
          validationError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setLoading(true);
      clearError();

      int? personalPhotoId;

      if (selectedPersonalPhoto.value != null) {
        final uploadResult = await _mediaRepository.uploadSingle(
          file: selectedPersonalPhoto.value!,
          type: MediaEndpoints.typeImage,
          forType: MediaEndpoints.purposePersonalPhoto,
        );
        personalPhotoId = uploadResult.id;
      }

      // ID Photo cannot be changed - removed from edit functionality
      // if (selectedIdPhoto.value != null) {
      //   final uploadResult = await _mediaRepository.uploadSingle(
      //     file: selectedIdPhoto.value!,
      //     type: MediaEndpoints.typeImage,
      //     forType: MediaEndpoints.purposeIdPhoto,
      //   );
      //   idPhotoId = uploadResult.id;
      // }
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final phone = phoneController.text.trim();
      final username = usernameController.text.trim();
      final dateOfBirth = selectedDateOfBirth.value != null
          ? DateHelper.formatForApi(selectedDateOfBirth.value!)
          : null;
      final updatedUser = await _repository.updateProfile(
        firstName: firstName.isNotEmpty ? firstName : null,
        lastName: lastName.isNotEmpty ? lastName : null,
        phone: phone.isNotEmpty ? phone : null,
        username: username.isNotEmpty ? username : null,
        dateOfBirth: dateOfBirth,
        idPhoto: null, // ID Photo cannot be changed
        personalPhoto: personalPhotoId,
      );
      await _authStateController.updateUser(updatedUser);
      try {
        final profileController = Get.find<ProfileController>();
        profileController.user.value = updatedUser;
        await profileController.refreshProfile();
      } catch (e) {
        debugPrint('ProfileController not found: $e');
      }
      selectedPersonalPhoto.value = null;
      Get.snackbar(
        'Success'.tr,
        'Profile updated successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to profile tab and refresh data
      DataRefreshService.navigateToProfileAndRefresh(animate: false);
    } catch (e) {
      handleError(e, title: 'Error updating profile');
    } finally {
      setLoading(false);
    }
  }

  void cancelEdit() {
    Get.back();
  }

  String getCurrentProfileImageUrl() {
    final user = _authStateController.user;
    if (user?.personalPhoto?.url != null &&
        user!.personalPhoto!.url!.isNotEmpty) {
      return user.personalPhoto!.url!;
    }
    return '';
  }

  String? getCurrentIdPhotoUrl() {
    final user = _authStateController.user;
    return user?.idPhoto?.url;
  }
}
