import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/favorites/models/favorite_model.dart';
import 'package:my_havenly_application/features/favorites/services/favorites_api_service.dart';

class FavoritesRepository {
  final FavoritesApiService _apiService = Get.find<FavoritesApiService>();

  Future<List<FavoriteModel>> getFavorites({bool forceRefresh = false}) async {
    try {
      final favorites = await _apiService.getFavorites();

      final validFavorites = favorites.where((f) => f.apartment != null).toList();

      return validFavorites;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to get favorites: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> addFavorite(int apartmentId) async {
    try {
      await _apiService.addFavorite(apartmentId);
      
      if (kDebugMode) {
        debugPrint('FavoritesRepository: Successfully added favorite $apartmentId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FavoritesRepository: Failed to add favorite $apartmentId: $e');
      }
      
      rethrow;
    }
  }

  Future<void> removeFavorite(int apartmentId) async {
    try {
      await _apiService.removeFavorite(apartmentId);

      if (kDebugMode) {
        debugPrint('FavoritesRepository: Successfully removed favorite $apartmentId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FavoritesRepository: Failed to remove favorite $apartmentId: $e');
      }
      
      rethrow;
    }
  }

  Future<bool> toggleFavorite(int apartmentId) async {
    try {
      await addFavorite(apartmentId);
      return true;
    } catch (e) {
      try {
        await removeFavorite(apartmentId);
        return false;
      } catch (e2) {
        rethrow;
      }
    }
  }
}
