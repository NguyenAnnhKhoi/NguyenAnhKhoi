import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            ));
          }
        } catch (e) {
          print('Error fetching booking details: $e');
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

  Future<DocumentReference> addBooking(Booking booking) {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Bạn cần đăng nhập để đặt lịch");

    return _db.collection('bookings').add({
      'userId': user.uid,
      'serviceId': booking.service.id,
      'stylistId': booking.stylist.id,
      'dateTime': Timestamp.fromDate(booking.dateTime),
      'status': booking.status,
      'note': booking.note,
      'customerName': booking.customerName,
      'customerPhone': booking.customerPhone,
      'branchName': booking.branchName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelBooking(String bookingId) {
    return _db.collection('bookings').doc(bookingId).delete();
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
}