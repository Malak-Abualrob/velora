import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/profile_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  Future<void> createProfile({
    required String uid,
    required String name,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set({
      'name': name,
      'age': '',
      'phone': '',
      'bio': '',
      'imageUrl': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<ProfileModel?> getProfile() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) return null;

    return ProfileModel.fromMap(
      user.uid,
      snapshot.data()!,
    );
  }

  Future<String> uploadProfileImage(
    File image,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final reference = _storage
        .ref()
        .child('users')
        .child(user.uid)
        .child('profile.jpg');

    await reference.putFile(image);

    return await reference.getDownloadURL();
  }

  Future<void> saveProfile(
    ProfileModel profile,
  ) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }
}