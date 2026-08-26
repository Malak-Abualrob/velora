import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create profile
  Future<void> createProfile({
    required String uid,
    required String name,
    String role = 'user', // user or admin
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'age': '',
      'phone': '',
      'bio': '',
      'imageUrl': '',
      'role': role, // user or admin
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get profile
  Future<ProfileModel?> getProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final snapshot = await _firestore.collection('users').doc(user.uid).get();

    if (!snapshot.exists) {
      return null;
    }

    return ProfileModel.fromMap(user.uid, snapshot.data()!);
  }

  // Upload profile image
  Future<String> uploadProfileImage(File image) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final reference = _storage
        .ref()
        .child('users')
        .child(user.uid)
        .child('profile.jpg');

    try {
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      await reference.putFile(image, metadata);

      return await reference.getDownloadURL();
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.code}');
      debugPrint('Message: ${e.message}');
      rethrow;
    }
  }

  // Save profile
  Future<void> saveProfile(ProfileModel profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  // Get user role
  Future<String> getUserRole(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();

    if (!snapshot.exists) {
      return 'user';
    }

    return snapshot.data()?['role'] ?? 'user';
  }
}
