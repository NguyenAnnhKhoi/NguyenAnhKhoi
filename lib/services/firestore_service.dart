import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../models/booking.dart';
import '../models/branch.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- KIỂM TRA ADMIN ---
  Stream<bool> isAdmin() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(false);
    return _db.collection('users').doc(user.uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data();
      return data?['role'] == 'admin';
    });
  }

  // --- LẤY DỮ LIỆU (Giữ nguyên) ---

  Stream<List<Service>> getServices() {
    return _db.collection('services').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList());
  }

  Stream<List<Stylist>> getStylists() {
    return _db.collection('stylists').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Stylist.fromFirestore(doc)).toList());
  }

  Stream<List<Branch>> getBranches() {
    return _db.collection('branches').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Branch.fromFirestore(doc)).toList());
  }

  Stream<List<Booking>> getUserBookings() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Booking> bookings = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        try {
          final serviceDoc =
              await _db.collection('services').doc(data['serviceId']).get();
          final stylistDoc =
              await _db.collection('stylists').doc(data['stylistId']).get();

          if (serviceDoc.exists && stylistDoc.exists) {
            bookings.add(Booking(
              id: doc.id,
              service: Service.fromFirestore(serviceDoc),
              stylist: Stylist.fromFirestore(stylistDoc),
              dateTime: (data['dateTime'] as Timestamp).toDate(),
              status: data['status'],
              note: data['note'] ?? "",
              customerName: data['customerName'] ?? 'Không rõ',
              customerPhone: data['customerPhone'] ?? 'Không rõ',
              branchName: data['branchName'] ?? 'Không rõ',
              paymentMethod: data['paymentMethod'] ?? 'Tại quầy',
              userId: data['userId'],
              rejectionReason: data['rejectionReason'],
            ));
          }
        } catch (e) {
          debugPrint('Error fetching booking details: $e');
        }
      }
      return bookings;
    });
  }

  Stream<List<Service>> getFavoriteServices() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists || userDoc.data()?['favoriteServices'] == null) {
        return [];
      }
      List<String> favoriteIds =
          List<String>.from(userDoc.data()!['favoriteServices']);
      if (favoriteIds.isEmpty) return [];

      final servicesQuery = await _db
          .collection('services')
          .where(FieldPath.documentId, whereIn: favoriteIds)
          .get();
      return servicesQuery.docs.map((doc) => Service.fromFirestore(doc)).toList();
    });
  }

  // --- GHI DỮ LIỆU (Giữ nguyên) ---

  Future<DocumentReference> addBooking(Booking booking) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Bạn cần đăng nhập để đặt lịch");

    // Parse duration từ service duration string
    final serviceDuration = booking.service.duration;
    int durationMinutes = 60; // Mặc định 60 phút
    
    if (serviceDuration.contains('giờ')) {
      final hours = int.tryParse(serviceDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      durationMinutes = hours * 60;
    } else {
      durationMinutes = int.tryParse(serviceDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 60;
    }

    // Kiểm tra stylist có available không trước khi tạo booking
    final isAvailable = await checkStylistAvailability(
      stylistId: booking.stylist.id,
      dateTime: booking.dateTime,
      durationMinutes: durationMinutes,
    );

    if (!isAvailable) {
      throw Exception("Stylist đã có lịch hẹn vào thời gian này. Vui lòng chọn thời gian khác hoặc stylist khác.");
    }

    // Tự động set status = 'confirmed' thay vì 'pending'
    // Vì đã kiểm tra availability rồi nên không cần admin xác nhận
    return _db.collection('bookings').add({
      'userId': user.uid,
      'serviceId': booking.service.id,
      'serviceName': booking.service.name,
      'servicePrice': booking.service.price,
      'serviceDuration': booking.service.duration, // Lưu duration để check conflict
      'stylistId': booking.stylist.id,
      'stylistName': booking.stylist.name,
      'dateTime': Timestamp.fromDate(booking.dateTime),
      'status': 'confirmed', // Tự động confirmed thay vì pending
      'note': booking.note,
      'customerName': booking.customerName,
      'customerPhone': booking.customerPhone,
      'branchName': booking.branchName,
      'paymentMethod': booking.paymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelBooking(String bookingId) {
    return _db.collection('bookings').doc(bookingId).delete();
  }

  Future<void> updateBooking(Booking booking) {
    return _db.collection('bookings').doc(booking.id).update({
      'status': booking.status,
      'paymentMethod': booking.paymentMethod,
      // Cập nhật bất kỳ trường nào khác nếu cần
    });
  }

  // Thêm method mới để update booking datetime
  Future<void> updateBookingDateTime({
    required String bookingId,
    required DateTime newDateTime,
    required Stylist newStylist,
    required String newBranchName,
  }) {
    return _db.collection('bookings').doc(bookingId).update({
      'dateTime': Timestamp.fromDate(newDateTime),
      'stylistId': newStylist.id,
      'stylistName': newStylist.name,
      'stylistImage': newStylist.image,
      'stylistExperience': newStylist.experience,
      'stylistRating': newStylist.rating,
      'branchName': newBranchName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleFavoriteService(String serviceId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _db.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        'favoriteServices': [serviceId]
      });
      return;
    }

    List<String> favoriteIds = userDoc.data()?['favoriteServices'] != null
        ? List<String>.from(userDoc.data()!['favoriteServices'])
        : [];

    if (favoriteIds.contains(serviceId)) {
      userRef.update({
        'favoriteServices': FieldValue.arrayRemove([serviceId])
      });
    } else {
      userRef.update({
        'favoriteServices': FieldValue.arrayUnion([serviceId])
      });
    }
  }

  // --- THÊM MỚI: CÁC HÀM QUẢN LÝ CHO ADMIN ---

  // Quản lý Dịch vụ (Services)
  Future<void> addService(Service service) {
    return _db.collection('services').add(service.toJson());
  }

  Future<void> updateService(Service service) {
    return _db.collection('services').doc(service.id).update(service.toJson());
  }

  Future<void> deleteService(String serviceId) {
    return _db.collection('services').doc(serviceId).delete();
  }

  // Quản lý Chi nhánh (Branches)
  Future<void> addBranch(Branch branch) {
    return _db.collection('branches').add(branch.toJson());
  }

  Future<void> updateBranch(Branch branch) {
    return _db.collection('branches').doc(branch.id).update(branch.toJson());
  }

  Future<void> deleteBranch(String branchId) {
    return _db.collection('branches').doc(branchId).delete();
  }

  // Quản lý Stylist
  Future<void> addStylist(Stylist stylist) {
    return _db.collection('stylists').add(stylist.toJson());
  }

  Future<void> updateStylist(Stylist stylist) {
    return _db.collection('stylists').doc(stylist.id).update(stylist.toJson());
  }

  Future<void> deleteStylist(String stylistId) {
    return _db.collection('stylists').doc(stylistId).delete();
  }

  // --- QUẢN LÝ BOOKING CHO ADMIN ---

  /// Lấy tất cả bookings (Admin)
  /// Filter và sort trên client side để tránh cần composite index
  Stream<List<Booking>> getAllBookings({String? statusFilter}) {
    // Lấy tất cả bookings, không dùng where + orderBy để tránh cần composite index
    Query query = _db.collection('bookings');

    return query.snapshots().asyncMap((snapshot) async {
      final List<Booking> bookings = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Filter trên client side
        if (statusFilter != null && statusFilter.isNotEmpty) {
          if (data['status'] != statusFilter) {
            continue; // Skip booking không match status
          }
        }
        
        try {
          final serviceDoc = await _db.collection('services').doc(data['serviceId']).get();
          final stylistDoc = await _db.collection('stylists').doc(data['stylistId']).get();

          if (serviceDoc.exists && stylistDoc.exists) {
            bookings.add(Booking(
              id: doc.id,
              service: Service.fromFirestore(serviceDoc),
              stylist: Stylist.fromFirestore(stylistDoc),
              dateTime: (data['dateTime'] as Timestamp).toDate(),
              status: data['status'] ?? 'pending',
              note: data['note'] ?? "",
              customerName: data['customerName'] ?? 'Không rõ',
              customerPhone: data['customerPhone'] ?? 'Không rõ',
              branchName: data['branchName'] ?? 'Không rõ',
              paymentMethod: data['paymentMethod'] ?? 'Tại quầy',
              userId: data['userId'],
              rejectionReason: data['rejectionReason'],
            ));
          }
        } catch (e) {
          debugPrint('Error fetching booking details: $e');
        }
      }
      
      // Sort trên client side theo dateTime descending
      bookings.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      
      return bookings;
    });
  }

  /// Xác nhận booking (Admin)
  Future<void> confirmBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'confirmed',
      'confirmedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Từ chối booking (Admin)
  Future<void> rejectBooking(String bookingId, String reason) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'rejected',
      'rejectionReason': reason,
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kiểm tra stylist có bận trong khoảng thời gian không
  /// Returns true nếu stylist rảnh, false nếu đã có lịch
  Future<bool> checkStylistAvailability({
    required String stylistId,
    required DateTime dateTime,
    int durationMinutes = 60, // Duration của dịch vụ mới (mặc định 60 phút)
    String? excludeBookingId, // Để loại trừ booking hiện tại khi reschedule
  }) async {
    try {
      // Tính thời gian bắt đầu và kết thúc của lịch hẹn mới
      final requestedStartTime = dateTime;
      final requestedEndTime = dateTime.add(Duration(minutes: durationMinutes));

      // Lấy danh sách booking của stylist trong ngày
      final startOfDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Query các booking của stylist
      final snapshot = await _db
          .collection('bookings')
          .where('stylistId', isEqualTo: stylistId)
          .get();

      // Kiểm tra từng booking xem có conflict về thời gian không
      for (var doc in snapshot.docs) {
        // Bỏ qua booking hiện tại nếu đang reschedule
        if (excludeBookingId != null && doc.id == excludeBookingId) {
          continue;
        }

        final data = doc.data();
        final status = data['status'] as String?;
        
        // Chỉ kiểm tra các booking đang pending hoặc confirmed
        if (status != 'pending' && status != 'confirmed') {
          continue;
        }
        
        final bookingTime = (data['dateTime'] as Timestamp).toDate();
        
        // Chỉ kiểm tra các booking trong ngày
        if (bookingTime.isBefore(startOfDay) || bookingTime.isAfter(endOfDay)) {
          continue;
        }
        
        // Parse duration từ string (ví dụ: "30 phút" -> 30, "1 giờ" -> 60)
        final serviceDuration = data['serviceDuration']?.toString() ?? '60';
        int bookingDuration = 60; // Mặc định 60 phút
        
        if (serviceDuration.contains('giờ')) {
          final hours = int.tryParse(serviceDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
          bookingDuration = hours * 60;
        } else {
          bookingDuration = int.tryParse(serviceDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 60;
        }
        
        final bookingStartTime = bookingTime;
        final bookingEndTime = bookingTime.add(Duration(minutes: bookingDuration));

        // Kiểm tra overlap giữa 2 khoảng thời gian:
        // Hai khoảng thời gian overlap nếu:
        // - Thời gian bắt đầu mới < thời gian kết thúc cũ
        // - Thời gian kết thúc mới > thời gian bắt đầu cũ
        final hasConflict = requestedStartTime.isBefore(bookingEndTime) &&
            requestedEndTime.isAfter(bookingStartTime);

        if (hasConflict) {
          debugPrint(
            'Stylist $stylistId is busy from $bookingStartTime to $bookingEndTime. '
            'Requested time: $requestedStartTime to $requestedEndTime'
          );
          return false; // Có conflict - stylist đang bận
        }
      }

      return true; // Không có conflict - stylist rảnh
    } catch (e) {
      debugPrint('Error checking stylist availability: $e');
      return false; // Trả về false để an toàn trong trường hợp lỗi
    }
  }

  /// Lấy danh sách stylists khả dụng cho thời gian cụ thể
  Future<List<Stylist>> getAvailableStylists({
    required DateTime dateTime,
    int durationMinutes = 60, // Duration của dịch vụ
    String? excludeBookingId,
  }) async {
    // Lấy tất cả stylists
    final stylistsSnapshot = await _db.collection('stylists').get();
    final allStylists = stylistsSnapshot.docs
        .map((doc) => Stylist.fromFirestore(doc))
        .toList();

    // Lọc stylists khả dụng
    final List<Stylist> availableStylists = [];
    for (var stylist in allStylists) {
      final isAvailable = await checkStylistAvailability(
        stylistId: stylist.id,
        dateTime: dateTime,
        durationMinutes: durationMinutes, // Truyền duration vào
        excludeBookingId: excludeBookingId,
      );
      if (isAvailable) {
        availableStylists.add(stylist);
      }
    }

    return availableStylists;
  }

  /// Lấy bookings của một stylist trong ngày cụ thể
  Future<List<DateTime>> getStylistBookedTimes({
    required String stylistId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Đơn giản hóa query - chỉ where stylistId, filter còn lại trên client
    final snapshot = await _db
        .collection('bookings')
        .where('stylistId', isEqualTo: stylistId)
        .get();

    final List<DateTime> bookedTimes = [];
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String?;
      
      // Filter theo status
      if (status != 'pending' && status != 'confirmed') {
        continue;
      }
      
      final bookingTime = (data['dateTime'] as Timestamp).toDate();
      
      // Filter theo thời gian (trong ngày)
      if (bookingTime.isAfter(startOfDay) && bookingTime.isBefore(endOfDay)) {
        bookedTimes.add(bookingTime);
      }
    }

    return bookedTimes;
  }
}