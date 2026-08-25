class ProfileModel {
  final String uid;
  final String name;
  final String age;
  final String phone;
  final String bio;
  final String imageUrl;

  const ProfileModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.phone,
    required this.bio,
    required this.imageUrl,
  });

  factory ProfileModel.fromMap(
    String uid,
    Map<String, dynamic> map,
  ) {
    return ProfileModel(
      uid: uid,
      name: map['name'] ?? '',
      age: map['age'] ?? '',
      phone: map['phone'] ?? '',
      bio: map['bio'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'phone': phone,
      'bio': bio,
      'imageUrl': imageUrl,
    };
  }
}