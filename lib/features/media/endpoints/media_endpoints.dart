class MediaEndpoints {
  MediaEndpoints._();

  static const String basePath = '/media';

  static const String uploadSingle = basePath;

  static const String uploadMultiple = '$basePath/store-many';

  static String getMedia(int mediaId) => '$basePath/$mediaId';

  static const String typeImage = '1';

  static const String typeDocument = '2';

  static const String purposePersonalPhoto = 'personal-photo';

  static const String purposeIdPhoto = 'id-photo';

  static const String purposeApartmentPhoto = 'apartment-photo';

  static String buildPath(String path, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) {
      return '$basePath/$path';
    }

    String result = '$basePath/$path';
    params.forEach((key, value) {
      result = result.replaceAll(':$key', value.toString());
      result = result.replaceAll('{$key}', value.toString());
    });

    return result;
  }
}
