// lib/models/stylist.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Stylist {
  final String id;
  final String name;
  final String image;
  final double rating;
  final String experience;

  Stylist({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.experience,
  });

  // Thêm copyWith
  Stylist copyWith({
    String? id,
    String? name,
    String? image,
    double? rating,
    String? experience,
  }) {
    return Stylist(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      experience: experience ?? this.experience,
    );
  }

  factory Stylist.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Stylist(
      id: doc.id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      experience: data['experience'] ?? '',
    );
  }
  
  // THÊM MỚI: Phương thức toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image': image,
      'rating': rating,
      'experience': experience,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stylist &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}