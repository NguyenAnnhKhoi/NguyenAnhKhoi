import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  final String id;
  final String name;
  final double price;
  final String duration;
  final double rating;
  final String image;
  final String? categoryId;
  final String? categoryName;
  final bool isFeatured; // Dịch vụ nổi bật
  final int featuredOrder; // Thứ tự hiển thị trong danh sách nổi bật

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.rating,
    required this.image,
    this.categoryId,
    this.categoryName,
    this.isFeatured = false,
    this.featuredOrder = 999,
  });

  Service copyWith({
    String? id,
    String? name,
    double? price,
    String? duration,
    double? rating,
    String? image,
    String? categoryId,
    String? categoryName,
    bool? isFeatured,
    int? featuredOrder,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isFeatured: isFeatured ?? this.isFeatured,
      featuredOrder: featuredOrder ?? this.featuredOrder,
    );
  }

  factory Service.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Service(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      duration: data['duration'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      image: data['image'] ?? '',
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],
      isFeatured: data['isFeatured'] ?? false,
      featuredOrder: data['featuredOrder'] ?? 999,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'rating': rating,
      'image': image,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'isFeatured': isFeatured,
      'featuredOrder': featuredOrder,
    };
  }

  // Alias for toFirestore() to support existing code
  Map<String, dynamic> toJson() => toFirestore();
}
