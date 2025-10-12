import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final double price;
  final String duration;
  final double rating;
  final String image;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.rating,
    required this.image,
  });

  factory Service.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      duration: data['duration'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? '',
    );
  }
}