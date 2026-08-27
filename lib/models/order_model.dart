import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;

  final String userId;
  final String userName;
  final String userPhone;

  final DateTime createdAt;
  final String status;

  const OrderModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.createdAt,
    required this.status,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final timestamp = map['createdAt'];

    return OrderModel(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      createdAt: timestamp is Timestamp ? timestamp.toDate() : DateTime.now(),
      status: map['status'] ?? 'pending',
    );
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'createdAt': FieldValue.serverTimestamp(),
      'status': status,
    };
  }
}
