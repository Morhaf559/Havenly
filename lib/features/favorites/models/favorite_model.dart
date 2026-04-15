import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';

class FavoriteModel {
  final int id;
  final ApartmentModel? apartment;

  FavoriteModel({
    required this.id,
    this.apartment,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    int? idValue;
    if (json['id'] != null) {
      idValue = json['id'] is int 
          ? json['id'] as int 
          : int.tryParse(json['id'].toString());
    }
    
    if (idValue == null) {
      throw Exception('FavoriteModel ID is required but was null or invalid');
    }

    ApartmentModel? apartmentModel;
    
    if (json['apartment'] != null) {
      if (json['apartment'] is Map<String, dynamic>) {
        try {
          apartmentModel = ApartmentModel.fromJson(json['apartment'] as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing apartment in FavoriteModel: $e');
        }
      }
    } else {
      try {
        apartmentModel = ApartmentModel.fromJson(json);
      } catch (e) {
        print('Error parsing apartment as flat structure: $e');
      }
    }

    return FavoriteModel(
      id: idValue,
      apartment: apartmentModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment': apartment?.toJson(),
    };
  }
}

