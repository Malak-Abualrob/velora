import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createOrder({required String productId}) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      throw Exception('User profile not found');
    }

    final userData = userDoc.data()!;

    final productRef = _firestore.collection('products').doc(productId);

    final orderRef = _firestore.collection('orders').doc();

    await _firestore.runTransaction((transaction) async {
      final productSnapshot = await transaction.get(productRef);

      if (!productSnapshot.exists) {
        throw Exception('Product not found');
      }

      final productData = productSnapshot.data()!;

      final quantity = productData['quantity'] ?? 0;

      if (quantity <= 0) {
        throw Exception('This product is out of stock');
      }

      transaction.update(productRef, {'quantity': quantity - 1});

      transaction.set(orderRef, {
        'productId': productId,
        'productName': productData['name'] ?? '',
        'productImage': productData['imageUrl'] ?? '',
        'price': (productData['price'] ?? 0).toDouble(),

        'userId': user.uid,
        'userName': userData['name'] ?? '',
        'userPhone': userData['phone'] ?? '',

        'createdAt': FieldValue.serverTimestamp(),

        'status': 'pending',
      });
    });
  }

  /// Cancel an order by setting its status to 'cancelled'.
  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'cancelled',
    });
  }

  /// Stream all orders (admin view).
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Stream orders for the currently authenticated user.
  Stream<List<OrderModel>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromFirestore(doc))
              .toList(),
        );
  }
}
