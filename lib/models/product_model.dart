class ProductModel {
  final String id;
  final String name;
  final String price;
  final String description;
  final String category;
  final int quantity;
  final String imageUrl;

  bool isFavorite; // 👈 للـ UI فقط، مش في Firestore

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.quantity,
    required this.imageUrl,
    this.isFavorite = false,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: map['price'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      isFavorite: false, // 👈 دايماً false عند الجلب من Firestore
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'quantity': quantity,
      'imageUrl': imageUrl,
      // ❌ isFavorite مش موجودة هنا
    };
  }

  ProductModel copyWith({bool? isFavorite}) {
    return ProductModel(
      id: id,
      name: name,
      price: price,
      description: description,
      category: category,
      quantity: quantity,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
