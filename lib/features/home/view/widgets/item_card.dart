import 'package:flutter/material.dart';
import 'package:my_havenly_application/core/widgets/apartment_card_widget.dart';
import 'package:my_havenly_application/features/apartments/models/apartment_model.dart';
import '../../model/item_model.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;

  const ItemCard({super.key, required this.item});

  ApartmentModel _itemToApartment(ItemModel item) {
    final apartmentId = int.tryParse(item.id) ?? 0;
    return ApartmentModel(
      id: apartmentId,
      title: {'ar': item.title, 'en': item.title},
      price: item.price,
      rate: item.rating,
      city: item.location,
      mainImage: item.imageUrl.isNotEmpty ? item.imageUrl : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final apartment = _itemToApartment(item);
    return ApartmentCardWidget(
      apartment: apartment,
      showFavoriteButton: true,
    );
  }
}
