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

  // Create profile
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

  // Get profile
  Future<ProfileModel?> getProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return ProfileModel.fromMap(
      user.uid,
      snapshot.data()!,
    );
  }

  // Upload profile image
  Future<String> uploadProfileImage(File image) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    print('==============================');
    print('USER UID: ${user.uid}');
    print('STARTING IMAGE UPLOAD');

    final reference = _storage
        .ref()
        .child('users')
        .child(user.uid)
        .child('profile.jpg');

    print('STORAGE PATH: ${reference.fullPath}');

    try {
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      await reference.putFile(
        image,
        metadata,
      );

      print('UPLOAD SUCCESS');

      final url = await reference.getDownloadURL();

      print('IMAGE URL: $url');
      print('==============================');

      return url;
    } on FirebaseException catch (e) {
      print('FIREBASE STORAGE ERROR');
      print('CODE: ${e.code}');
      print('MESSAGE: ${e.message}');
      rethrow;
    } catch (e) {
      print('UPLOAD ERROR: $e');
      rethrow;
    }
  }

  // Save profile
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