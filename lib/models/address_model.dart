import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String? notes;

  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    this.notes,
  });

  factory AddressModel.fromMap(String id, Map<String, dynamic> map) {
    return AddressModel(
      id: id,
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      addressLine: map['addressLine'] ?? '',
      city: map['city'] ?? '',
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'addressLine': addressLine,
      'city': city,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
