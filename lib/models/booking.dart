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
  final String customerName;
  final String customerPhone;
  final String branchName;
  final String paymentMethod; // <-- THÊM MỚI

  Booking({
    required this.id,
    required this.service,
    required this.stylist,
    required this.dateTime,
    required this.status,
    this.note = "",
    required this.customerName,
    required this.customerPhone,
    required this.branchName,
    this.paymentMethod = 'Tại quầy', // <-- THÊM MỚI (mặc định)
  });

  Booking copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? branchName,
    String? paymentMethod, // <-- THÊM MỚI
    String? status, // <-- THÊM MỚI (để cập nhật status)
  }) {
    return Booking(
      id: id ?? this.id,
      service: service,
      stylist: stylist,
      dateTime: dateTime,
      status: status ?? this.status, // <-- CẬP NHẬT
      note: note,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      branchName: branchName ?? this.branchName,
      paymentMethod: paymentMethod ?? this.paymentMethod, // <-- CẬP NHẬT
    );
  }
}