import 'package:get/get.dart';
import '../model/category_model.dart';
import '../model/item_model.dart';

class HomeController extends GetxController {
  // User information
  final String userName = 'John';
  final String userLocation = 'Damascus, Syria';
  String userStatus = 'Premium Member'.tr;

  // Search text
  final searchText = ''.obs;

  // Categories list
  final RxList<CategoryModel> categories = [
    CategoryModel(id: 'all', name: 'All'.tr, isSelected: true),
    CategoryModel(id: 'apartment', name: 'Apartment'.tr),
    CategoryModel(id: 'house', name: 'House'.tr),
    CategoryModel(id: 'villa', name: 'Villa'.tr),
    CategoryModel(id: 'studio', name: 'Studio'.tr),
    CategoryModel(id: 'penthouse', name: 'Penthouse'.tr),
  ].obs;

  // Items list
  final List<ItemModel> _allItems = [
    ItemModel(
      id: '1',
      title: 'Lord Villa',
      category: 'villa',
      location: 'Damascus, Syria',
      price: 699.00,
      rating: 4.9,
      reviewCount: 6500,
      imageUrl: 'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
    ),
    ItemModel(
      id: '2',
      title: 'Modern Apartment',
      category: 'apartment',
      location: 'Damascus, Syria',
      price: 450.00,
      rating: 4.7,
      reviewCount: 3200,
      imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
    ),
    ItemModel(
      id: '3',
      title: 'Luxury House',
      category: 'house',
      location: 'Damascus, Syria',
      price: 850.00,
      rating: 4.8,
      reviewCount: 4800,
      imageUrl: 'https://images.unsplash.com/photo-1568605114967-8130f3a36994',
    ),
    ItemModel(
      id: '4',
      title: 'Cozy Studio',
      category: 'studio',
      location: 'Damascus, Syria',
      price: 350.00,
      rating: 4.6,
      reviewCount: 2100,
      imageUrl: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af',
    ),
    ItemModel(
      id: '5',
      title: 'Elegant Penthouse',
      category: 'penthouse',
      location: 'Damascus, Syria',
      price: 1200.00,
      rating: 5.0,
      reviewCount: 8900,
      imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9',
    ),
    ItemModel(
      id: '6',
      title: 'Family Villa',
      category: 'villa',
      location: 'Damascus, Syria',
      price: 950.00,
      rating: 4.9,
      reviewCount: 7200,
      imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
    ),
  ];

  // Getters
  List<ItemModel> get allItems => _allItems;

  // Get filtered items based on selected category
  List<ItemModel> get filteredItems {
    final selectedCategory = categories.firstWhere(
      (cat) => cat.isSelected,
      orElse: () => categories.first,
    );

    if (selectedCategory.id == 'all') {
      return _allItems;
    }

    return _allItems
        .where((item) => item.category == selectedCategory.id)
        .toList();
  }

  // Get items filtered by search text
  List<ItemModel> get searchedItems {
    if (searchText.value.isEmpty) {
      return filteredItems;
    }

    return filteredItems
        .where(
          (item) =>
              item.title.toLowerCase().contains(
                searchText.value.toLowerCase(),
              ) ||
              item.location.toLowerCase().contains(
                searchText.value.toLowerCase(),
              ),
        )
        .toList();
  }

  // Select category
  void selectCategory(String categoryId) {
    for (var i = 0; i < categories.length; i++) {
      categories[i] = categories[i].copyWith(
        isSelected: categories[i].id == categoryId,
      );
    }
  }

  // Update search text
  void updateSearchText(String text) {
    searchText.value = text;
  }

  // Open sidebar menu
  void openSidebar() {
    // TODO: Implement sidebar navigation
    Get.snackbar('Menu', 'Sidebar menu clicked');
  }

  // Open notes section
  void openNotes() {
    // TODO: Implement notes navigation
    Get.snackbar('Notes', 'Notes section clicked');
  }
}
