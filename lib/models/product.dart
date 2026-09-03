class Product {
  final int id;
  final String name;
  final String article;
  final String category;
  final String manufacturer;
  final double price;
  final int stock;
  final String description;
  final DateTime? deletedAt;

  const Product({
    required this.id,
    required this.name,
    required this.article,
    required this.category,
    required this.manufacturer,
    required this.price,
    required this.stock,
    required this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Product copyWith({
    String? name,
    String? article,
    String? category,
    String? manufacturer,
    double? price,
    int? stock,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      article: article ?? this.article,
      category: category ?? this.category,
      manufacturer: manufacturer ?? this.manufacturer,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      deletedAt: clearDeletedAt
          ? null
          : (deletedAt ?? this.deletedAt),
    );
  }
}