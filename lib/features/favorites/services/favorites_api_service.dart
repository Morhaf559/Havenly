import 'package:my_havenly_application/core/network/api_service.dart';
import 'package:my_havenly_application/core/network/exceptions/api_exception.dart';
import 'package:my_havenly_application/features/favorites/endpoints/favorites_endpoints.dart';
import 'package:my_havenly_application/features/favorites/models/favorite_model.dart';

class FavoritesApiService {
  Future<List<FavoriteModel>> getFavorites() async {
    try {
      return await ApiService.getList<FavoriteModel>(
        path: FavoritesEndpoints.list,
        fromJson: (json) => FavoriteModel.fromJson(json),
      );
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
      await ApiService.postVoid(
        path: FavoritesEndpoints.addFavorite(apartmentId),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to add favorite: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<void> removeFavorite(int apartmentId) async {
    try {
      await ApiService.delete(
        path: FavoritesEndpoints.removeFavorite(apartmentId),
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException(
        message: 'Failed to remove favorite: ${e.toString()}',
        originalError: e,
      );
    }
  }
}
