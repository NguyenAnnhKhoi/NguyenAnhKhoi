// lib/models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String categoryId; // ID của ProductCategory
  final int stock; // Số lượng tồn kho
  final bool isActive;
  final double? rating; // Điểm đánh giá trung bình (1-5)
  final int reviewCount; // Số lượng đánh giá
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.categoryId,
    this.stock = 0,
    this.isActive = true,
    this.rating,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parseDate(dynamic value, DateTime defaultDate) {
      if (value == null) return defaultDate;
      if (value is Timestamp) return value.toDate();
      return defaultDate;
    }
    
    final now = DateTime.now();
    
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'],
      categoryId: data['categoryId'] ?? '',
      stock: data['stock'] ?? 0,
      isActive: data['isActive'] ?? true,
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      createdAt: parseDate(data['createdAt'], now),
      updatedAt: parseDate(data['updatedAt'], now),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'stock': stock,
      'isActive': isActive,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? categoryId,
    int? stock,
    bool? isActive,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

