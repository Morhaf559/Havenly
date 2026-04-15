class ImageIdUploadModel {
  final int? id;
  final String? name;
  final String? url;
  final String? extension;
  final int? type;
  final String? forValue;
  final String? createdAt;
  final dynamic createdBy;

  ImageIdUploadModel({
    this.id,
    this.name,
    this.url,
    this.extension,
    this.type,
    this.forValue,
    this.createdAt,
    this.createdBy,
  });

  factory ImageIdUploadModel.fromJson(Map<String, dynamic> json) {
    try {
      return ImageIdUploadModel(
        id: json['id'] as int?,
        name: json['name'] as String?,
        url: json['url'] as String?,
        extension: json['extension'] as String?,
        type: json['type'] as int?,
        forValue: json['for'] as String?,
        createdAt: json['createdAt'] as String?,
        createdBy: json['createdBy'],
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'extension': extension,
      'type': type,
      'for': forValue,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }
}
