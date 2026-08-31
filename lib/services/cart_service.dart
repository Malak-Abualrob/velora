import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/cart_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _cartCollection {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).collection('cart');
  }

  Future<void> addToCart(CartModel cart) async {
    final doc = _cartCollection.doc(cart.productId);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      final currentQuantity = snapshot.data()?['quantity'] ?? 0;
      final newQuantity = currentQuantity + cart.quantity;

      if (newQuantity > cart.availableQuantity) {
        throw Exception('Quantity exceeds available stock');
      }

      await doc.update({
        'quantity': newQuantity,
        'availableQuantity': cart.availableQuantity,
      });
    } else {
      await doc.set(cart.toMap());
    }
  }

  Stream<List<CartModel>> getCart() {
    return _cartCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> increaseQuantity(CartModel cart) async {
    if (cart.quantity >= cart.availableQuantity) {
      throw Exception('Cannot exceed available quantity');
    }

    await _cartCollection.doc(cart.productId).update({
      'quantity': FieldValue.increment(1),
    });
  }

  Future<void> decreaseQuantity(CartModel cart) async {
    if (cart.quantity <= 1) {
      await removeFromCart(cart.productId);
      return;
    }

    await _cartCollection.doc(cart.productId).update({
      'quantity': FieldValue.increment(-1),
    });
  }

  Future<void> removeFromCart(String productId) async {
    await _cartCollection.doc(productId).delete();
  }

  Future<void> clearCart() async {
    final snapshot = await _cartCollection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<double> getCartTotal() async {
    final snapshot = await _cartCollection.get();
    double total = 0.0;

    for (final doc in snapshot.docs) {
      final item = CartModel.fromMap(doc.data());
      total += item.subtotal;
    }

    return total;
  }
}
