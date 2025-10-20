// lib/models/booking.dart
import 'service.dart';
import 'stylist.dart';

class Booking {
  final String id;
  final Service service;
  final Stylist stylist;
  final DateTime dateTime;
  final String status;
  final String note;
  // --- THÊM CÁC TRƯỜNG MỚI ---
  final String customerName;
  final String customerPhone;
  final String branchName; // Lưu tên chi nhánh
  final String? paymentMethod; // Phương thức thanh toán

  Booking({
    required this.id,
    required this.service,
    required this.stylist,
    required this.dateTime,
    required this.status,
    this.note = "",
    // --- CẬP NHẬT CONSTRUCTOR ---
    required this.customerName,
    required this.customerPhone,
    required this.branchName,
    this.paymentMethod,
  });

  Booking copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? branchName,
    String? status,
    String? paymentMethod,
  }) {
    return Booking(
      id: id ?? this.id,
      service: service,
      stylist: stylist,
      dateTime: dateTime,
      status: status ?? this.status,
      note: note,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      branchName: branchName ?? this.branchName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}