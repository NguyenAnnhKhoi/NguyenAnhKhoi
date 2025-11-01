// lib/models/service_category.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final String icon; // Tên icon hoặc emoji
  final int sortOrder; // Thứ tự hiển thị
  final bool isActive; // Trạng thái hoạt động

  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory ServiceCategory.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ServiceCategory(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      icon: data['icon'] ?? '✂️',
      sortOrder: data['sortOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  ServiceCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? sortOrder,
    bool? isActive,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
