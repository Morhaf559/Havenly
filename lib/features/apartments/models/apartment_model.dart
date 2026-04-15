/// Apartment Model
/// Represents an apartment listing with all details
class ApartmentModel {
  final int id;
  final Map<String, dynamic>? title;
  final Map<String, dynamic>? description;
  final double price;
  final String? currency;
  final double? rate;
  final String? governorate;
  final String? city;
  final Map<String, dynamic>? address;
  final String? status;
  final int? numberOfRoom;
  final int? numberOfBathroom;
  final int? area;
  final int? floor;
  final String? mainImage;
  final DateTime? createdAt;

  ApartmentModel({
    required this.id,
    this.title,
    this.description,
    required this.price,
    this.currency,
    this.rate,
    this.governorate,
    this.city,
    this.address,
    this.status,
    this.numberOfRoom,
    this.numberOfBathroom,
    this.area,
    this.floor,
    this.mainImage,
    this.createdAt,
  });

  factory ApartmentModel.fromJson(Map<String, dynamic> json) {
    // Handle title field: can be String or Map<String, dynamic>
    Map<String, dynamic>? titleMap;
    final titleValue = json['title'];
    if (titleValue != null) {
      if (titleValue is Map<String, dynamic>) {
        titleMap = titleValue;
      } else if (titleValue is String) {
        // Convert String to Map with 'ar' key (default locale)
        titleMap = {'ar': titleValue};
      } else if (titleValue is Map) {
        // Handle generic Map (not typed)
        titleMap = Map<String, dynamic>.from(titleValue);
      }
    }

    // Handle description field: can be String or Map<String, dynamic>
    Map<String, dynamic>? descriptionMap;
    final descriptionValue = json['description'];
    if (descriptionValue != null) {
      if (descriptionValue is Map<String, dynamic>) {
        descriptionMap = descriptionValue;
      } else if (descriptionValue is String) {
        descriptionMap = {'ar': descriptionValue};
      } else if (descriptionValue is Map) {
        descriptionMap = Map<String, dynamic>.from(descriptionValue);
      }
    }

    // Handle address field: can be String or Map<String, dynamic>
    Map<String, dynamic>? addressMap;
    final addressValue = json['address'];
    if (addressValue != null) {
      if (addressValue is Map<String, dynamic>) {
        addressMap = addressValue;
      } else if (addressValue is String) {
        addressMap = {'ar': addressValue};
      } else if (addressValue is Map) {
        addressMap = Map<String, dynamic>.from(addressValue);
      }
    }

    // Handle price: can be String or num
    double priceValue = 0.0;
    final priceData = json['price'];
    if (priceData != null) {
      if (priceData is String) {
        priceValue = double.tryParse(priceData) ?? 0.0;
      } else if (priceData is num) {
        priceValue = priceData.toDouble();
      }
    }

    // Handle createdAt
    DateTime? createdAtValue;
    final createdAtData = json['created_at'];
    if (createdAtData != null) {
      if (createdAtData is String) {
        try {
          createdAtValue = DateTime.parse(createdAtData);
        } catch (e) {
          // If parsing fails, try to parse as date only (YYYY-MM-DD)
          try {
            createdAtValue = DateTime.parse('${createdAtData}T00:00:00');
          } catch (e2) {
            createdAtValue = null;
          }
        }
      }
    }

    // Handle id: can be int or String
    int idValue;
    final idData = json['id'];
    if (idData is int) {
      idValue = idData;
    } else if (idData is String) {
      idValue = int.tryParse(idData) ?? 0;
    } else if (idData is num) {
      idValue = idData.toInt();
    } else {
      idValue = 0;
    }

    // Helper function to safely parse int from JSON
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt();
      return null;
    }

    // Helper function to safely parse double from JSON
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    return ApartmentModel(
      id: idValue,
      title: titleMap,
      description: descriptionMap,
      price: priceValue,
      currency: json['currency'] as String?,
      rate: _parseDouble(json['rate']),
      governorate: json['governorate'] as String?,
      city: json['city'] as String?,
      address: addressMap,
      status: json['status'] as String?,
      numberOfRoom: _parseInt(json['number_of_room']),
      numberOfBathroom: _parseInt(json['number_of_bathroom']),
      area: _parseInt(json['area']),
      floor: _parseInt(json['floor']),
      // Handle main_image: can be direct string or from photos array
      mainImage: _extractMainImage(json),
      createdAt: createdAtValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'price': price.toStringAsFixed(2),
      if (currency != null) 'currency': currency,
      if (rate != null) 'rate': rate,
      if (governorate != null) 'governorate': governorate,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (status != null) 'status': status,
      if (numberOfRoom != null) 'number_of_room': numberOfRoom,
      if (numberOfBathroom != null) 'number_of_bathroom': numberOfBathroom,
      if (area != null) 'area': area,
      if (floor != null) 'floor': floor,
      if (mainImage != null) 'main_image': mainImage,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Get localized title based on current locale
  String? getLocalizedTitle(String locale) {
    if (title == null) return null;
    return title![locale] as String? ??
        title!['ar'] as String? ??
        title!.values.first as String?;
  }

  /// Get localized description based on current locale
  String? getLocalizedDescription(String locale) {
    if (description == null) return null;
    return description![locale] as String? ??
        description!['ar'] as String? ??
        description!.values.first as String?;
  }

  /// Get localized address based on current locale
  String? getLocalizedAddress(String locale) {
    if (address == null) return null;
    return address![locale] as String? ??
        address!['ar'] as String? ??
        address!.values.first as String?;
  }

  /// Get formatted price with currency
  String getFormattedPrice() {
    final currencySymbol = currency ?? '\$';
    return '$currencySymbol${price.toStringAsFixed(2)}';
  }

  /// Check if apartment is available
  bool isAvailable() {
    return status?.toLowerCase() == 'available';
  }

  /// Extract main image from JSON response
  /// Handles both direct 'main_image' field and photos array
  static String? _extractMainImage(Map<String, dynamic> json) {
    // First, try direct main_image field
    if (json['main_image'] != null && json['main_image'] is String) {
      final mainImage = json['main_image'] as String;
      if (mainImage.isNotEmpty) {
        return mainImage;
      }
    }

    // If no direct main_image, try to get from photos array
    if (json['photos'] != null && json['photos'] is List) {
      final photos = json['photos'] as List;
      if (photos.isNotEmpty) {
        // Find main photo (is_main: true) or use first photo
        for (var photo in photos) {
          if (photo is Map<String, dynamic>) {
            // Check if this is the main photo
            final isMain = photo['is_main'] == true || 
                          photo['isMain'] == true ||
                          (photo['is_main'] is int && photo['is_main'] == 1);
            
            if (isMain) {
              // Try to get URL from photo object
              if (photo['url'] != null && photo['url'] is String) {
                return photo['url'] as String;
              }
              // Try nested structure
              if (photo['medium'] != null && photo['medium'] is Map) {
                final medium = photo['medium'] as Map<String, dynamic>;
                if (medium['url'] != null && medium['url'] is String) {
                  return medium['url'] as String;
                }
              }
            }
          }
        }
        
        // If no main photo found, use first photo
        final firstPhoto = photos.first;
        if (firstPhoto is Map<String, dynamic>) {
          if (firstPhoto['url'] != null && firstPhoto['url'] is String) {
            return firstPhoto['url'] as String;
          }
          // Try nested structure
          if (firstPhoto['medium'] != null && firstPhoto['medium'] is Map) {
            final medium = firstPhoto['medium'] as Map<String, dynamic>;
            if (medium['url'] != null && medium['url'] is String) {
              return medium['url'] as String;
            }
          }
        }
      }
    }

    return null;
  }
}
