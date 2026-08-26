import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get all products
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

  //add product
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

    //upload image to firebase storage
    final ref = _storage
        .ref()
        .child('products')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final metadata = SettableMetadata(contentType: 'image/jpeg');

    await ref.putFile(image, metadata);

    final imageUrl = await ref.getDownloadURL();

    //add product to firebase firestore
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

  //update product
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

  //delete product
  Future<void> deleteProduct(String id) async {
    //delete image from firebase storage
    final ref = _storage.ref().child('products').child(id);
    await ref.delete();
    await _firestore.collection('products').doc(id).delete();
  }
}
