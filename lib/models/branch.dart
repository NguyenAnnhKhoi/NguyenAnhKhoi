// lib/models/branch.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Branch {
  final String id;
  final String name;
  final String address;
  final String hours;
  final double rating;
  final String image;
  final double latitude;
  final double longitude;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.hours,
    required this.rating,
    required this.image,
    required this.latitude,
    required this.longitude,
  });

  // Thêm copyWith
  Branch copyWith({
    String? id,
    String? name,
    String? address,
    String? hours,
    double? rating,
    String? image,
    double? latitude,
    double? longitude,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      hours: hours ?? this.hours,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  factory Branch.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Branch(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      hours: data['hours'] ?? '8:00 - 22:00',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // THÊM MỚI: Phương thức toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'hours': hours,
      'rating': rating,
      'image': image,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}