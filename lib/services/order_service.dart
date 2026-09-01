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

  // ✅ إلغاء طلب + إرجاع الكمية للمخزون
  Future<void> cancelOrder(String orderId) async {
    debugPrint('🔄 Cancelling order: $orderId');
    try {
      // ✅ 1️⃣ نجيب الطلب عشان نعرف المنتجات والكميات
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) throw Exception('Order not found');

      final orderData = orderDoc.data() as Map<String, dynamic>;
      final items = orderData['items'] as List<dynamic>? ?? [];

      // ✅ 2️⃣ نستخدم Transaction عشان نرجع الكمية
      await _firestore.runTransaction((transaction) async {
        // نرجع الكمية لكل منتج
        for (final item in items) {
          final itemMap = item as Map<String, dynamic>;
          final productId = itemMap['productId'] ?? '';
          final quantity = itemMap['quantity'] ?? 0;

          if (productId.isNotEmpty && quantity > 0) {
            final productRef = _firestore.collection('products').doc(productId);
            final productSnapshot = await transaction.get(productRef);

            if (productSnapshot.exists) {
              final currentQty = productSnapshot.data()?['quantity'] ?? 0;
              transaction.update(productRef, {
                'quantity': currentQty + quantity,
              });
            }
          }
        }

        // ✅ 3️⃣ نغير حالة الطلب
        transaction.update(_firestore.collection('orders').doc(orderId), {
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      debugPrint('✅ Order cancelled and stock restored');
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

  // ✅ إنشاء طلب من السلة (نسخة مبسطة للاختبار)
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
    try {
      debugPrint('🔥 Starting createOrderFromCart');
      debugPrint('📦 Items count: ${items.length}');
      debugPrint('💰 Total: $total');
      debugPrint('👤 User: $userName');

      // ✅ 1️⃣ إنشاء الطلب أولاً (بدون Transaction)
      final orderRef = _firestore.collection('orders').doc();

      // ✅ تحويل items إلى List<Map>
      final itemsMap = items
          .map(
            (item) => {
              'productId': item.productId,
              'productName': item.productName,
              'productPrice': item.productPrice,
              'productImage': item.productImage,
              'quantity': item.quantity,
            },
          )
          .toList();

      debugPrint('📦 Items Map: $itemsMap');

      final orderData = {
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'userPhone': userPhone,
        'address': address,
        'items': itemsMap,
        'total': total,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      };

      debugPrint('📦 Order Data: $orderData');

      await orderRef.set(orderData);
      debugPrint('✅ Order created: ${orderRef.id}');

      // ✅ 2️⃣ تحديث المخزون (إنقاص الكمية لكل منتج)
      for (final item in cartItems) {
        debugPrint('📦 Processing: ${item.productName} x ${item.quantity}');
        final productRef = _firestore
            .collection('products')
            .doc(item.productId);
        final productSnapshot = await productRef.get();

        if (!productSnapshot.exists) {
          throw Exception('Product not found: ${item.productName}');
        }

        final currentQty = productSnapshot.data()?['quantity'] ?? 0;

        if (currentQty < item.quantity) {
          throw Exception('Not enough stock for: ${item.productName}');
        }

        await productRef.update({'quantity': currentQty - item.quantity});
        debugPrint('✅ Stock updated for: ${item.productName}');
      }

      // ✅ 3️⃣ تفريغ السلة
      final user = _auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      for (final item in cartItems) {
        await cartRef.doc(item.productId).delete();
        debugPrint('🗑️ Deleted from cart: ${item.productName}');
      }

      debugPrint('✅ Order placed successfully!');
    } catch (e) {
      debugPrint('❌ ERROR: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
