import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all products
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ProductModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  // Add product
  Future<void> addProduct({
    required String name,
    required String price,
    required String description,
    required String category,
    required int quantity,
    required File image,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Not authenticated');
    }

    // Upload image to Firebase Storage
    final ref = _storage
        .ref()
        .child('products')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    await ref.putFile(image, metadata);

    final imageUrl = await ref.getDownloadURL();

    // Add product to Firebase Firestore
    await _firestore.collection('products').add({
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
    });
  }

  // Update product
  Future<void> updateProduct({
    required String id,
    required String name,
    required String price,
    required String description,
    required String category,
    required int quantity,
    File? image,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'quantity': quantity,
    };

    if (image != null) {
      final ref = _storage
          .ref()
          .child('products')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      await ref.putFile(image, metadata);

      data['imageUrl'] = await ref.getDownloadURL();
    }

    await _firestore.collection('products').doc(id).update(data);
  }

  // ✅ Delete product (Fixed)
  Future<void> deleteProduct(String id) async {
    try {
      // 1️⃣ نجيب المنتج عشان نعرف رابط الصورة
      final doc = await _firestore.collection('products').doc(id).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final imageUrl = data['imageUrl'] ?? '';

        // 2️⃣ نحذف الصورة من Storage إذا موجودة
        if (imageUrl.isNotEmpty) {
          try {
            // ✅ نستخرج المسار من الـ URL
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
            debugPrint('✅ Image deleted from Storage');
          } catch (e) {
            debugPrint('⚠️ Error deleting image: $e');
            // نكمل حتى لو فشل حذف الصورة
          }
        }
      }

      // 3️⃣ نحذف المنتج من Firestore
      await _firestore.collection('products').doc(id).delete();
      debugPrint('✅ Product deleted from Firestore');
    } catch (e) {
      debugPrint('❌ Error deleting product: $e');
      rethrow;
    }
  }
}
