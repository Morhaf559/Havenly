class FavoritesEndpoints {
  FavoritesEndpoints._();

  static const String basePath = '/favorites';

  static const String list = basePath;

  static String addFavorite(int apartmentId) => '/apartment/$apartmentId/favorite';

  static String removeFavorite(int apartmentId) => '/apartment/$apartmentId/favorite';

  static String checkFavorite(int apartmentId) => '/apartment/$apartmentId/favorite';
}
