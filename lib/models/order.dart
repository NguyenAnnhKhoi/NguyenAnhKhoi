// lib/models/order.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item.dart';

class Order {
  final String id;
  final String userId;
  final String customerName;
  final String customerPhone;
  final String? customerAddress; // Địa chỉ giao hàng
  final List<OrderItem> items; // Danh sách sản phẩm
  final double subtotal; // Tổng tiền trước giảm giá
  final double? discountAmount; // Số tiền giảm từ voucher
  final String? voucherCode; // Mã voucher đã áp dụng
  final double total; // Tổng tiền sau giảm giá
  final String status; // 'pending', 'confirmed', 'shipping', 'completed', 'cancelled'
  final String paymentMethod; // 'VietQR', 'cash'
  final bool isPaid; // Đã thanh toán chưa
  final DateTime? paidAt; // Thời điểm thanh toán
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    required this.items,
    required this.subtotal,
    this.discountAmount,
    this.voucherCode,
    required this.total,
    this.status = 'pending',
    this.paymentMethod = 'VietQR',
    this.isPaid = false,
    this.paidAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    DateTime parseDate(dynamic value, DateTime? defaultDate) {
      if (value == null) return defaultDate ?? DateTime.now();
      if (value is Timestamp) return value.toDate();
      return defaultDate ?? DateTime.now();
    }
    
    final now = DateTime.now();
    
    // Parse order items
    List<OrderItem> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    
    return Order(
      id: doc.id,
      userId: data['userId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'],
      items: items,
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      discountAmount: data['discountAmount']?.toDouble(),
      voucherCode: data['voucherCode'],
      total: (data['total'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'VietQR',
      isPaid: data['isPaid'] ?? false,
      paidAt: parseDate(data['paidAt'], null),
      createdAt: parseDate(data['createdAt'], now),
      updatedAt: parseDate(data['updatedAt'], null),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discountAmount': discountAmount,
      'voucherCode': voucherCode,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : Timestamp.fromDate(DateTime.now()),
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<OrderItem>? items,
    double? subtotal,
    double? discountAmount,
    String? voucherCode,
    double? total,
    String? status,
    String? paymentMethod,
    bool? isPaid,
    DateTime? paidAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      voucherCode: voucherCode ?? this.voucherCode,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

