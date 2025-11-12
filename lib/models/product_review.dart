// lib/models/product_review.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName; // Tên người đánh giá
  final int rating; // 1-5 sao
  final String? comment; // Bình luận
  final DateTime createdAt;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parseDate(dynamic value, DateTime defaultDate) {
      if (value == null) return defaultDate;
      if (value is Timestamp) return value.toDate();
      return defaultDate;
    }
    
    final now = DateTime.now();
    
    return ProductReview(
      id: doc.id,
      productId: data['productId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Người dùng',
      rating: data['rating'] ?? 5,
      comment: data['comment'],
      createdAt: parseDate(data['createdAt'], now),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ProductReview copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ProductReview(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

