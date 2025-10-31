// lib/models/voucher.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum VoucherType {
  percentage, // Giảm theo %
  fixed, // Giảm cố định
  freeService, // Dịch vụ miễn phí
}

enum VoucherCondition {
  all, // Áp dụng cho tất cả
  minAmount, // Yêu cầu số tiền tối thiểu
  firstBooking, // Chỉ cho lần đặt đầu tiên
  specificService, // Chỉ cho dịch vụ cụ thể
}

class Voucher {
  final String id;
  final String code;
  final String title;
  final String description;
  final VoucherType type;
  final VoucherCondition condition;
  final double value; // % hoặc số tiền giảm
  final double? minAmount; // Số tiền tối thiểu để áp dụng
  final DateTime startDate;
  final DateTime endDate;
  final int maxUses; // Số lần sử dụng tối đa (-1 là không giới hạn)
  final int currentUses; // Số lần đã sử dụng
  final bool isActive;
  final String? imageUrl;
  final List<String>? specificServiceIds; // Chỉ áp dụng cho các dịch vụ này
  final bool isForNewUser; // Chỉ dành cho người dùng mới

  Voucher({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.condition,
    required this.value,
    this.minAmount,
    required this.startDate,
    required this.endDate,
    required this.maxUses,
    this.currentUses = 0,
    this.isActive = true,
    this.imageUrl,
    this.specificServiceIds,
    this.isForNewUser = false,
  });

  // Kiểm tra voucher có hợp lệ không
  bool isValid() {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (maxUses == -1 || currentUses < maxUses);
  }

  // Kiểm tra có áp dụng được cho đơn hàng không
  bool canApply({
    required double orderAmount,
    List<String>? serviceIds,
    bool isFirstBooking = false,
  }) {
    if (!isValid()) return false;

    switch (condition) {
      case VoucherCondition.all:
        return true;
      case VoucherCondition.minAmount:
        return minAmount != null && orderAmount >= minAmount!;
      case VoucherCondition.firstBooking:
        return isFirstBooking;
      case VoucherCondition.specificService:
        if (specificServiceIds == null || serviceIds == null) return false;
        return serviceIds.any((id) => specificServiceIds!.contains(id));
    }
  }

  // Tính số tiền giảm
  double calculateDiscount(double orderAmount) {
    if (!isValid()) return 0;

    switch (type) {
      case VoucherType.percentage:
        return orderAmount * (value / 100);
      case VoucherType.fixed:
        return value;
      case VoucherType.freeService:
        return orderAmount; // Hoặc logic khác tùy theo service
    }
  }

  factory Voucher.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Voucher(
      id: doc.id,
      code: data['code'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: VoucherType.values[data['type'] ?? 0],
      condition: VoucherCondition.values[data['condition'] ?? 0],
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      minAmount: (data['minAmount'] as num?)?.toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      maxUses: data['maxUses'] ?? -1,
      currentUses: data['currentUses'] ?? 0,
      isActive: data['isActive'] ?? true,
      imageUrl: data['imageUrl'],
      specificServiceIds: data['specificServiceIds'] != null
          ? List<String>.from(data['specificServiceIds'])
          : null,
      isForNewUser: data['isForNewUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'title': title,
      'description': description,
      'type': type.index,
      'condition': condition.index,
      'value': value,
      'minAmount': minAmount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'maxUses': maxUses,
      'currentUses': currentUses,
      'isActive': isActive,
      'imageUrl': imageUrl,
      'specificServiceIds': specificServiceIds,
      'isForNewUser': isForNewUser,
    };
  }

  Voucher copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    VoucherType? type,
    VoucherCondition? condition,
    double? value,
    double? minAmount,
    DateTime? startDate,
    DateTime? endDate,
    int? maxUses,
    int? currentUses,
    bool? isActive,
    String? imageUrl,
    List<String>? specificServiceIds,
    bool? isForNewUser,
  }) {
    return Voucher(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      condition: condition ?? this.condition,
      value: value ?? this.value,
      minAmount: minAmount ?? this.minAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      maxUses: maxUses ?? this.maxUses,
      currentUses: currentUses ?? this.currentUses,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
      specificServiceIds: specificServiceIds ?? this.specificServiceIds,
      isForNewUser: isForNewUser ?? this.isForNewUser,
    );
  }
}

// Model cho voucher của user
class UserVoucher {
  final String id;
  final String userId;
  final String voucherId;
  final Voucher voucher;
  final DateTime claimedAt;
  final bool isUsed;
  final String? usedInBookingId;
  final DateTime? usedAt;

  UserVoucher({
    required this.id,
    required this.userId,
    required this.voucherId,
    required this.voucher,
    required this.claimedAt,
    this.isUsed = false,
    this.usedInBookingId,
    this.usedAt,
  });

  factory UserVoucher.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    Voucher voucher,
  ) {
    final data = doc.data()!;
    return UserVoucher(
      id: doc.id,
      userId: data['userId'] ?? '',
      voucherId: data['voucherId'] ?? '',
      voucher: voucher,
      claimedAt: (data['claimedAt'] as Timestamp).toDate(),
      isUsed: data['isUsed'] ?? false,
      usedInBookingId: data['usedInBookingId'],
      usedAt: data['usedAt'] != null
          ? (data['usedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'voucherId': voucherId,
      'claimedAt': Timestamp.fromDate(claimedAt),
      'isUsed': isUsed,
      'usedInBookingId': usedInBookingId,
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
    };
  }

  bool canUse() {
    return !isUsed && voucher.isValid();
  }
}
