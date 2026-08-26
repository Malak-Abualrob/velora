class ProfileModel {
  final String uid;
  final String name;
  final String age;
  final String phone;
  final String bio;
  final String imageUrl;
  final String role; // user or admin

  const ProfileModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.phone,
    required this.bio,
    required this.imageUrl,
    required this.role, // user or admin
  });

  factory ProfileModel.fromMap(String uid, Map<String, dynamic> map) {
    return ProfileModel(
      uid: uid,
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      phone: map['phone'] ?? '',
      bio: map['bio'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      role: map['role'] ?? 'user', // user or admin
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'phone': phone,
      'bio': bio,
      'imageUrl': imageUrl,
      'role': role, // user or admin
    };
  }
}
