class CategoryModel {
  final String id;
  final String name;
  final bool isSelected;

  CategoryModel({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    bool? isSelected,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

