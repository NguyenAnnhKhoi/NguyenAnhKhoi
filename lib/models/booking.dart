// lib/models/booking.dart
import 'service.dart';
import 'stylist.dart';

/// Enum trạng thái booking
enum BookingStatus {
  pending('Chờ xác nhận', 'pending'),
  confirmed('Đã xác nhận', 'confirmed'),
  completed('Hoàn thành', 'completed'),
  cancelled('Đã hủy', 'cancelled'),
  rejected('Bị từ chối', 'rejected');

  final String label;
  final String value;
  const BookingStatus(this.label, this.value);

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => BookingStatus.pending,
    );
  }
}

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
  final String paymentMethod;
  final String? userId; // ID của user đặt lịch
  final String? rejectionReason; // Lý do từ chối (nếu có)

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
    this.paymentMethod = 'Tại quầy',
    this.userId,
    this.rejectionReason,
  });

  Booking copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? branchName,
    String? paymentMethod,
    String? status,
    String? userId,
    String? rejectionReason,
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
      userId: userId ?? this.userId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  // Helper methods
  BookingStatus get bookingStatus => BookingStatus.fromString(status);
  
  bool get isPending => status == BookingStatus.pending.value;
  bool get isConfirmed => status == BookingStatus.confirmed.value;
  bool get isCompleted => status == BookingStatus.completed.value;
  bool get isCancelled => status == BookingStatus.cancelled.value;
  bool get isRejected => status == BookingStatus.rejected.value;
}