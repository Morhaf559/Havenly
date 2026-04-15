class MediaModel {
  final int? id;
  final String? name;
  final String? url;
  final String? extension;
  final int? type;
  final String? forType;
  final String? createdAt;
  final dynamic createdBy;

  MediaModel({
    this.id,
    this.name,
    this.url,
    this.extension,
    this.type,
    this.forType,
    this.createdAt,
    this.createdBy,
  });
  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      url: json['url'] as String?,
      extension: json['extension'] as String?,
      type: json['type'] as int?,
      forType: json['for'] as String?,
      createdAt: json['createdAt'] as String?,
      createdBy: json['createdBy'],
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

  bool get hasUrl => url != null && url!.isNotEmpty;

  String? get fullUrl => url;

  MediaModel copyWith({
    int? id,
    String? name,
    String? url,
    String? extension,
    int? type,
    String? forType,
    String? createdAt,
    dynamic createdBy,
  }) {
    return MediaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      extension: extension ?? this.extension,
      type: type ?? this.type,
      forType: forType ?? this.forType,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'MediaModel(id: $id, name: $name, url: $url, extension: $extension, type: $type, forType: $forType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
