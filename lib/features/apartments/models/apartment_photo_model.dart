/// Apartment Photo Model
/// Represents a photo for an apartment
/// Based on media API response structure
class ApartmentPhotoModel {
  final int id;
  final String? name;
  final String? url;
  final String? extension;
  final int? type;
  final String? forType;
  final bool isMain;
  final DateTime? createdAt;
  final String? createdBy;

  ApartmentPhotoModel({
    required this.id,
    this.name,
    this.url,
    this.extension,
    this.type,
    this.forType,
    this.isMain = false,
    this.createdAt,
    this.createdBy,
  });

  factory ApartmentPhotoModel.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    // Structure 1: Direct fields (legacy)
    // Structure 2: Nested in 'medium' object (current API structure)
    
    int? idValue;
    String? nameValue;
    String? urlValue;
    String? extensionValue;
    
    // Check if data is nested in 'medium' object (new API structure)
    if (json['medium'] != null && json['medium'] is Map) {
      final medium = json['medium'] as Map<String, dynamic>;
      idValue = medium['id'] is int 
          ? medium['id'] as int 
          : (medium['id'] != null ? int.tryParse(medium['id'].toString()) : null);
      nameValue = medium['name'] as String?;
      urlValue = medium['url'] as String?;
      extensionValue = medium['extension'] as String?;
    } else {
      // Direct structure (legacy)
      idValue = json['id'] is int 
          ? json['id'] as int 
          : (json['id'] != null ? int.tryParse(json['id'].toString()) : null);
      nameValue = json['name'] as String?;
      urlValue = json['url'] as String?;
      extensionValue = json['extension'] as String?;
    }
    
    if (idValue == null) {
      throw Exception('ApartmentPhoto ID is required but was null');
    }

    // Handle createdAt
    DateTime? createdAtValue;
    final createdAtData = json['createdAt'] ?? json['created_at'];
    if (createdAtData != null) {
      if (createdAtData is String) {
        try {
          createdAtValue = DateTime.parse(createdAtData);
        } catch (e) {
          createdAtValue = null;
        }
      }
    }

    // Handle is_main - can be int (1/0) or bool
    bool isMainValue = false;
    if (json['is_main'] != null) {
      if (json['is_main'] is bool) {
        isMainValue = json['is_main'] as bool;
      } else if (json['is_main'] is int) {
        isMainValue = (json['is_main'] as int) == 1;
      } else if (json['is_main'] is String) {
        isMainValue = json['is_main'] == '1' || json['is_main'].toLowerCase() == 'true';
      }
    } else if (json['isMain'] != null) {
      if (json['isMain'] is bool) {
        isMainValue = json['isMain'] as bool;
      } else if (json['isMain'] is int) {
        isMainValue = (json['isMain'] as int) == 1;
      }
    }

    return ApartmentPhotoModel(
      id: idValue,
      name: nameValue,
      url: urlValue,
      extension: extensionValue,
      type: json['type'] != null ? (json['type'] is int ? json['type'] as int : int.tryParse(json['type'].toString())) : null,
      forType: json['for'] as String?,
      isMain: isMainValue,
      createdAt: createdAtValue,
      createdBy: json['createdBy'] as String? ?? json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (url != null) 'url': url,
      if (extension != null) 'extension': extension,
      if (type != null) 'type': type,
      if (forType != null) 'for': forType,
      'is_main': isMain,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (createdBy != null) 'createdBy': createdBy,
    };
  }

  /// Get image URL - fallback to url if available
  String? get imageUrl => url;
}

