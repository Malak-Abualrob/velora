import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:velora/models/cart_model.dart';
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

  // ✅ إنشاء طلب من السلة (3 خطوات)
  Future<void> createOrderFromCart({
    required String userId,
    required String userEmail,
    required String userName,
    required String userPhone,
    required String address,
    required List<OrderItemModel> items,
    required String total,
    required List<CartModel> cartItems,
  }) async {
    await _firestore.runTransaction((transaction) async {
      // ✅ 1️⃣ تحديث المخزون (إنقاص الكمية لكل منتج)
      for (final item in cartItems) {
        final productRef = _firestore
            .collection('products')
            .doc(item.productId);
        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception('Product not found: ${item.productName}');
        }

        final currentQty = productSnapshot.data()?['quantity'] ?? 0;

        if (currentQty < item.quantity) {
          throw Exception('Not enough stock for: ${item.productName}');
        }

        transaction.update(productRef, {
          'quantity': currentQty - item.quantity,
        });
      }

      // ✅ 2️⃣ إنشاء الطلب
      final orderRef = _firestore.collection('orders').doc();

      final order = OrderModel(
        id: orderRef.id,
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        userPhone: userPhone,
        address: address,
        items: items,
        total: total,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      transaction.set(orderRef, order.toMap());

      // ✅ 3️⃣ تفريغ السلة
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      for (final item in cartItems) {
        transaction.delete(cartRef.doc(item.productId));
      }
    });
  }
}
