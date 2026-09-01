import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final String productPrice;
  final String productImage;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productPrice: map['productPrice'] ?? '',
      productImage: map['productImage'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String userPhone;
  final String address;
  final List<OrderItemModel> items;
  final String total;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.userPhone,
    required this.address,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final itemsList = (data['items'] as List<dynamic>? ?? [])
        .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'] ?? '',
      address: data['address'] ?? '',
      items: itemsList,
      total: data['total'] ?? '0',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // ✅ أضيفي هذه الدالة
  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final itemsList = (map['items'] as List<dynamic>? ?? [])
        .map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      address: map['address'] ?? '',
      items: itemsList,
      total: map['total'] ?? '0',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'userPhone': userPhone,
      'address': address,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {'status': status, 'updatedAt': FieldValue.serverTimestamp()};
  }
}

class OrderStatus {
  static const String pending = 'pending';
  static const String processing = 'processing';
  static const String outForDelivery = 'out_for_delivery';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';

  static List<String> get all => [
    pending,
    processing,
    outForDelivery,
    delivered,
    cancelled,
  ];

  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case processing:
        return 'Processing';
      case outForDelivery:
        return 'Out for Delivery';
      case delivered:
        return 'Delivered';
      case cancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }

  static Color getColor(String status) {
    switch (status) {
      case pending:
        return Colors.orange;
      case processing:
        return Colors.blue;
      case outForDelivery:
        return Colors.purple;
      case delivered:
        return Colors.green;
      case cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
