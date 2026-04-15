class PhotoModel {
  final int? id;
  final String? name;
  final String? url;
  final String? extension;
  final int? type;
  final String? forType;
  final String? createdAt;
  final String? createdBy;

  PhotoModel({
    this.id,
    this.name,
    this.url,
    this.extension,
    this.type,
    this.forType,
    this.createdAt,
    this.createdBy,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      extension: json['extension'] as String?,
      type: json['type'] as int?,
      forType: json['for'] as String?,
      createdAt: json['createdAt'] as String?,
      createdBy: json['createdBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'extension': extension,
      'type': type,
      'for': forType,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }
}
