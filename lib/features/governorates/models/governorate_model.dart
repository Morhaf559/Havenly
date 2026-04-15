class GovernorateModel {
  final int id;
  final String? nameAr;
  final String? nameEn;
  final Map<String, String>? name;

  GovernorateModel({
    required this.id,
    this.nameAr,
    this.nameEn,
    this.name,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    int? idValue;
    String? arValue;
    String? enValue;
    Map<String, String>? nameMap;

    if (json['id'] != null) {
      idValue = json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString());
    } else if (json['value'] != null) {
      idValue = json['value'] is int ? json['value'] as int : int.tryParse(json['value'].toString());
    }

    if (json['name'] != null && json['name'] is Map) {
      nameMap = Map<String, String>.from(json['name'] as Map);
      arValue = nameMap['ar'];
      enValue = nameMap['en'];
    } else {
      if (json['ar'] != null) {
        arValue = json['ar'] is String ? json['ar'] as String : json['ar'].toString();
      }
      if (json['en'] != null) {
        enValue = json['en'] is String ? json['en'] as String : json['en'].toString();
      }
    }

    if (arValue != null || enValue != null) {
      nameMap = {};
      if (arValue != null) nameMap['ar'] = arValue;
      if (enValue != null) nameMap['en'] = enValue;
    }

    if (idValue == null) {
      throw Exception('Governorate ID (id or value) is required');
    }

    return GovernorateModel(
      id: idValue,
      nameAr: arValue,
      nameEn: enValue,
      name: nameMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': id,
      if (nameAr != null) 'ar': nameAr,
      if (nameEn != null) 'en': nameEn,
      if (name != null) 'name': name,
    };
  }

  String? getLocalizedName(String locale) {
    if (name != null && name!.isNotEmpty) {
      return name![locale] ?? name!['ar'] ?? name!['en'] ?? name!.values.first;
    }
    
    if (locale == 'ar' && nameAr != null) {
      return nameAr;
    }
    if (locale == 'en' && nameEn != null) {
      return nameEn;
    }
    
    return nameAr ?? nameEn;
  }
}

