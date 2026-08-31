class CartModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final int availableQuantity;

  CartModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.availableQuantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'availableQuantity': availableQuantity,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      availableQuantity: map['availableQuantity'] ?? 0,
    );
  }

  double get subtotal => price * quantity;
}
