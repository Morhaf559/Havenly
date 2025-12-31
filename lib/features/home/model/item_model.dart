class ItemModel {
  final String id;
  final String title;
  final String category;
  final String location;
  final double price;
  final double rating;
  final int reviewCount;
  final String imageUrl;

  ItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
  });
}

