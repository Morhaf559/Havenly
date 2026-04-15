import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/controllers/base_controller.dart';
import 'package:my_havenly_application/core/controllers/auth_state_controller.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_filter_model.dart';
import 'package:my_havenly_application/features/apartments/repositories/apartments_repository.dart';
import 'package:my_havenly_application/features/favorites/repositories/favorites_repository.dart';

class FavoritesController extends BaseController {
  final FavoritesRepository _repository = Get.find<FavoritesRepository>();
  final AuthStateController _authStateController = Get.find<AuthStateController>();
  final ApartmentsRepository _apartmentsRepository = Get.find<ApartmentsRepository>();

  final RxSet<int> favoriteApartmentIds = <int>{}.obs;
  
  final RxList<ApartmentModel> favorites = <ApartmentModel>[].obs;
  
  Set<int>? _userApartmentIds;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites({bool forceRefresh = false}) async {
    try {
      if (forceRefresh || favorites.isEmpty) {
        setLoading(true);
      }
      clearError();
      
      await _loadUserApartmentIds();
      
      final favoriteModels = await _repository.getFavorites(forceRefresh: forceRefresh);
      
      final validFavorites = favoriteModels.where((f) => f.apartment != null).toList();
      
      final filteredFavorites = validFavorites.where((f) {
        final apartmentId = f.apartment?.id;
        if (apartmentId == null) return false;
        return !_isUserOwnApartment(apartmentId);
      }).toList();
      
      favoriteApartmentIds.clear();
      favoriteApartmentIds.addAll(
        filteredFavorites
            .where((f) => f.apartment?.id != null)
            .map((f) => f.apartment!.id),
      );
      
      favorites.value = filteredFavorites
          .map((f) => f.apartment!)
          .toList();
    } catch (e) {
      handleError(e, title: 'Error loading favorites');
      favorites.clear();
      favoriteApartmentIds.clear();
    } finally {
      setLoading(false);
    }
  }
  
  Future<void> _loadUserApartmentIds() async {
    final userId = _authStateController.user?.id;
    if (userId == null) {
      _userApartmentIds = <int>{};
      return;
    }
    
    if (_userApartmentIds != null) {
      return;
    }
    
    try {
      final userFilter = ApartmentFilterModel(
        customFilters: {'user_id': userId},
      );
      final userApartmentsResponse = await _apartmentsRepository.getApartments(
        page: 1,
        perPage: 100,
        filters: userFilter,
      );
      
      _userApartmentIds = userApartmentsResponse.data
          .map((apt) => apt.id)
          .toSet();
    } catch (e) {
      _userApartmentIds = <int>{};
    }
  }
  
  bool _isUserOwnApartment(int apartmentId) {
    return _userApartmentIds?.contains(apartmentId) ?? false;
  }

  @override
  Future<void> refresh() async {
    await loadFavorites(forceRefresh: true);
  }

  bool isFavorite(int apartmentId) {
    return favoriteApartmentIds.contains(apartmentId);
  }

  Future<bool> addFavorite(int apartmentId) async {
    try {
      await _loadUserApartmentIds();
      
      if (_isUserOwnApartment(apartmentId)) {
        Get.snackbar(
          'Error'.tr,
          'You cannot add your own apartment to favorites'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return false;
      }
      
      final wasAdded = !favoriteApartmentIds.contains(apartmentId);
      if (wasAdded) {
        favoriteApartmentIds.add(apartmentId);
      }

      await _repository.addFavorite(apartmentId);

      await loadFavorites(forceRefresh: true);

      return true;
    } catch (e) {
      favoriteApartmentIds.remove(apartmentId);
      
      handleError(e, title: 'Error adding favorite');
      Get.snackbar(
        'Error'.tr,
        'Failed to add favorite'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> removeFavorite(int apartmentId) async {
    try {
      favoriteApartmentIds.remove(apartmentId);
      favorites.removeWhere((apt) => apt.id == apartmentId);

      await _repository.removeFavorite(apartmentId);

      return true;
    } catch (e) {
      await loadFavorites(forceRefresh: true);
      
      handleError(e, title: 'Error removing favorite');
      Get.snackbar(
        'Error'.tr,
        'Failed to remove favorite'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  Future<bool> toggleFavorite(int apartmentId) async {
    final isCurrentlyFavorite = isFavorite(apartmentId);

    if (isCurrentlyFavorite) {
      return await removeFavorite(apartmentId);
    } else {
      return await addFavorite(apartmentId);
    }
  }

  Future<void> clearCache() async {
    favoriteApartmentIds.clear();
    favorites.clear();
    _userApartmentIds = null;
  }
}

