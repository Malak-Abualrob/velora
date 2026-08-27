import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ دالة إنشاء طلب (مع Batch بدل Transaction)
  Future<void> createOrder({required String productId}) async {
    debugPrint('🟢 1. createOrder called with productId: $productId');

    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ User not logged in');
      throw Exception('User not logged in');
    }
    debugPrint('✅ User UID: ${user.uid}');

    try {
      debugPrint('🟢 2. Getting user data...');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        debugPrint('❌ User profile not found');
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;
      debugPrint('✅ User name: ${userData['name']}');
      debugPrint('✅ User phone: ${userData['phone']}');

      debugPrint('🟢 3. Getting product data...');
      final productRef = _firestore.collection('products').doc(productId);
      final productSnapshot = await productRef.get();

      if (!productSnapshot.exists) {
        debugPrint('❌ Product not found');
        throw Exception('Product not found');
      }

      final productData = productSnapshot.data()!;
      final quantity = productData['quantity'] ?? 0;
      debugPrint('✅ Product name: ${productData['name']}');
      debugPrint('✅ Current quantity: $quantity');

      if (quantity <= 0) {
        debugPrint('❌ Out of stock');
        throw Exception('This product is out of stock');
      }

      debugPrint('🟢 4. Creating order and updating quantity...');

      final orderRef = _firestore.collection('orders').doc();

      // ✅ نستخدم batch عشان نبسط
      final batch = _firestore.batch();

      // 1️⃣ ننقص الكمية
      batch.update(productRef, {'quantity': quantity - 1});

      // 2️⃣ ننشئ الطلب
      final price =
          double.tryParse(productData['price']?.toString() ?? '0') ?? 0.0;

      batch.set(orderRef, {
        'productId': productId,
        'productName': productData['name'] ?? '',
        'productImage': productData['imageUrl'] ?? '',
        'price': price,
        'userId': user.uid,
        'userName': userData['name'] ?? '',
        'userPhone': userData['phone'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      await batch.commit();
      debugPrint('✅ 5. Order created successfully! Order ID: ${orderRef.id}');
    } catch (e) {
      debugPrint('❌ Error: $e');
      rethrow;
    }
  }

  // ✅ جلب طلبات المستخدم الحالي
  Stream<List<OrderModel>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in');
      return Stream.value([]);
    }

    debugPrint('📦 Getting orders for user: ${user.uid}');

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint('📦 Found ${snapshot.docs.length} orders');
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ✅ جلب كل الطلبات (للأدمن)
  Stream<List<OrderModel>> getAllOrders() {
    debugPrint('📦 Getting all orders for admin');

    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          debugPrint('📦 Found ${snapshot.docs.length} total orders');
          return snapshot.docs.map((doc) {
            return OrderModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // ✅ إلغاء طلب
  Future<void> cancelOrder(String orderId) async {
    debugPrint('🔄 Cancelling order: $orderId');
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Order cancelled successfully');
    } catch (e) {
      debugPrint('❌ Error cancelling order: $e');
      rethrow;
    }
  }

  // ✅ تأكيد طلب (للأدمن)
  Future<void> completeOrder(String orderId) async {
    debugPrint('🔄 Completing order: $orderId');
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('✅ Order completed successfully');
    } catch (e) {
      debugPrint('❌ Error completing order: $e');
      rethrow;
    }
  }
}
