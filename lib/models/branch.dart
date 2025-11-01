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

  // THÊM MỚI: Parse giờ mở cửa
  // Giả sử format: "8:00 - 22:00" hoặc "08:00 - 22:00"
  Map<String, int>? get openingHours {
    try {
      // Parse chuỗi giờ: "8:00 - 22:00"
      final parts = hours.split('-');
      if (parts.length != 2) return null;

      final openTime = parts[0].trim().split(':');
      final closeTime = parts[1].trim().split(':');

      if (openTime.length != 2 || closeTime.length != 2) return null;

      return {
        'openHour': int.parse(openTime[0]),
        'openMinute': int.parse(openTime[1]),
        'closeHour': int.parse(closeTime[0]),
        'closeMinute': int.parse(closeTime[1]),
      };
    } catch (e) {
      return null;
    }
  }

  // THÊM MỚI: Kiểm tra xem thời gian có nằm trong giờ mở cửa không
  bool isTimeWithinOpeningHours(int hour, int minute) {
    final hours = openingHours;
    if (hours == null) return true; // Nếu không parse được, cho phép mọi giờ

    final openHour = hours['openHour']!;
    final openMinute = hours['openMinute']!;
    final closeHour = hours['closeHour']!;
    final closeMinute = hours['closeMinute']!;

    // Chuyển thành phút để so sánh dễ hơn
    final selectedTimeInMinutes = hour * 60 + minute;
    final openTimeInMinutes = openHour * 60 + openMinute;
    final closeTimeInMinutes = closeHour * 60 + closeMinute;

    return selectedTimeInMinutes >= openTimeInMinutes &&
        selectedTimeInMinutes <= closeTimeInMinutes;
  }

  // THÊM MỚI: Lấy giờ mở cửa dạng text cho thông báo
  String get openingTimeText {
    final hours = openingHours;
    if (hours == null) return '';
    return '${hours['openHour']}:${hours['openMinute']!.toString().padLeft(2, '0')}';
  }

  // THÊM MỚI: Lấy giờ đóng cửa dạng text cho thông báo
  String get closingTimeText {
    final hours = openingHours;
    if (hours == null) return '';
    return '${hours['closeHour']}:${hours['closeMinute']!.toString().padLeft(2, '0')}';
  }
}
