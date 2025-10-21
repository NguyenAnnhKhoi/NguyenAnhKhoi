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
  final String? paymentMethod;
  final bool isPaid;
  final double amount;
  final String? paymentId;
  final DateTime? paidAt;

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
    this.paymentMethod,
    this.isPaid = false,
    required this.amount,
    this.paymentId,
    this.paidAt,
  });

  Booking copyWith({
    String? id,
    Service? service,
    Stylist? stylist,
    DateTime? dateTime,
    String? status,
    String? note,
    String? customerName,
    String? customerPhone,
    String? branchName,
    String? paymentMethod,
    bool? isPaid,
    double? amount,
    String? paymentId,
    DateTime? paidAt,
  }) {
    return Booking(
      id: id ?? this.id,
      service: service ?? this.service,
      stylist: stylist ?? this.stylist,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      note: note ?? this.note,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      branchName: branchName ?? this.branchName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      amount: amount ?? this.amount,
      paymentId: paymentId ?? this.paymentId,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}
