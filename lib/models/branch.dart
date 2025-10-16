// lib/models/branch.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Branch {
  final String id;
  final String name;
  final String address;
  final String hours;
  final double rating;
  final String image; // Thêm trường ảnh cho chi nhánh

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.hours,
    required this.rating,
    required this.image,
  });

  factory Branch.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Branch(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      hours: data['hours'] ?? '8:00 - 22:00',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? 'https://i.imgur.com/default_branch.png', // URL ảnh mặc định
    );
  }
}