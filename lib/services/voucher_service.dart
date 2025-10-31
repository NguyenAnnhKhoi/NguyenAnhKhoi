// lib/services/voucher_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/voucher.dart';

class VoucherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy tất cả voucher đang active
  Stream<List<Voucher>> getActiveVouchers() {
    return _firestore
        .collection('vouchers')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Voucher.fromFirestore(doc))
            .where((v) => v.isValid())
            .toList());
  }

  // Lấy voucher dành cho người mới
  Stream<List<Voucher>> getNewUserVouchers() {
    return _firestore
        .collection('vouchers')
        .where('isActive', isEqualTo: true)
        .where('isForNewUser', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Voucher.fromFirestore(doc))
            .where((v) => v.isValid())
            .toList());
  }

  // Lấy voucher của user
  Stream<List<UserVoucher>> getUserVouchers(String userId) {
    return _firestore
        .collection('userVouchers')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<UserVoucher> userVouchers = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final voucherId = data['voucherId'];
        final voucherDoc = await _firestore.collection('vouchers').doc(voucherId).get();
        if (voucherDoc.exists) {
          final voucher = Voucher.fromFirestore(voucherDoc);
          userVouchers.add(UserVoucher.fromFirestore(doc, voucher));
        }
      }
      return userVouchers;
    });
  }

  // Lấy voucher chưa sử dụng của user
  Stream<List<UserVoucher>> getUnusedUserVouchers(String userId) {
    return getUserVouchers(userId).map(
      (vouchers) => vouchers.where((v) => v.canUse()).toList(),
    );
  }

  // Lấy voucher theo code
  Future<Voucher?> getVoucherByCode(String code) async {
    try {
      final snapshot = await _firestore
          .collection('vouchers')
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Voucher.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting voucher by code: $e');
      return null;
    }
  }

  // Claim voucher
  Future<bool> claimVoucher(String voucherId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return false;

    try {
      // Kiểm tra xem user đã claim voucher này chưa
      final existingClaim = await _firestore
          .collection('userVouchers')
          .where('userId', isEqualTo: userId)
          .where('voucherId', isEqualTo: voucherId)
          .get();

      if (existingClaim.docs.isNotEmpty) {
        throw Exception('Bạn đã nhận ưu đãi này rồi');
      }

      // Lấy thông tin voucher
      final voucherDoc = await _firestore.collection('vouchers').doc(voucherId).get();
      if (!voucherDoc.exists) throw Exception('Voucher không tồn tại');

      final voucher = Voucher.fromFirestore(voucherDoc);
      if (!voucher.isValid()) throw Exception('Voucher không còn hiệu lực');

      // Kiểm tra số lần sử dụng
      if (voucher.maxUses != -1 && voucher.currentUses >= voucher.maxUses) {
        throw Exception('Voucher đã hết lượt sử dụng');
      }

      // Thêm voucher cho user
      await _firestore.collection('userVouchers').add({
        'userId': userId,
        'voucherId': voucherId,
        'claimedAt': Timestamp.now(),
        'isUsed': false,
        'usedInBookingId': null,
        'usedAt': null,
      });

      // Cập nhật số lần sử dụng
      await _firestore.collection('vouchers').doc(voucherId).update({
        'currentUses': FieldValue.increment(1),
      });

      return true;
    } catch (e) {
      print('Error claiming voucher: $e');
      rethrow;
    }
  }

  // Sử dụng voucher
  Future<void> useVoucher(String userVoucherId, String bookingId) async {
    await _firestore.collection('userVouchers').doc(userVoucherId).update({
      'isUsed': true,
      'usedInBookingId': bookingId,
      'usedAt': Timestamp.now(),
    });
  }

  // Hoàn trả voucher (khi hủy booking)
  Future<void> refundVoucher(String userVoucherId) async {
    await _firestore.collection('userVouchers').doc(userVoucherId).update({
      'isUsed': false,
      'usedInBookingId': null,
      'usedAt': null,
    });
  }

  // Kiểm tra user có phải người mới không (chưa có booking nào)
  Future<bool> isNewUser(String userId) async {
    final bookings = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return bookings.docs.isEmpty;
  }

  // Admin: Tạo voucher mới
  Future<String> createVoucher(Voucher voucher) async {
    final docRef = await _firestore.collection('vouchers').add(voucher.toJson());
    return docRef.id;
  }

  // Admin: Cập nhật voucher
  Future<void> updateVoucher(String voucherId, Voucher voucher) async {
    await _firestore.collection('vouchers').doc(voucherId).update(voucher.toJson());
  }

  // Admin: Xóa voucher
  Future<void> deleteVoucher(String voucherId) async {
    await _firestore.collection('vouchers').doc(voucherId).delete();
  }

  // Admin: Lấy tất cả voucher
  Stream<List<Voucher>> getAllVouchers() {
    return _firestore
        .collection('vouchers')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Voucher.fromFirestore(doc))
            .toList());
  }
}
