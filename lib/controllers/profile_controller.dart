import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  ProfileModel? profile;

  File? selectedImage;

  bool isLoading = false;
  bool isSaving = false;

  Future<void> loadProfile() async {
    isLoading = true;
    notifyListeners();

    profile = await _service.getProfile();

    isLoading = false;
    notifyListeners();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    selectedImage = File(image.path);

    notifyListeners();
  }

  Future<void> saveProfile({
    required String name,
    required String age,
    required String phone,
    required String bio,
  }) async {
    if (profile == null) return;

    isSaving = true;
    notifyListeners();

    String imageUrl = profile!.imageUrl;

    if (selectedImage != null) {
      imageUrl = await _service.uploadProfileImage(selectedImage!);
    }

    final updatedProfile = ProfileModel(
      uid: profile!.uid,
      name: name,
      age: age,
      phone: phone,
      bio: bio,
      imageUrl: imageUrl,
      role: profile!.role,
    );

    await _service.saveProfile(updatedProfile);

    profile = updatedProfile;
    selectedImage = null;

    isSaving = false;
    notifyListeners();
  }
}
