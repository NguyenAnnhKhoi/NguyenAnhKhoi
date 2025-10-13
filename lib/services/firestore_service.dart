import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- LẤY DỮ LIỆU ---

  Stream<List<Service>> getServices() {
    return _db.collection('services').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList());
  }

  Stream<List<Stylist>> getStylists() {
    return _db.collection('stylists').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Stylist.fromFirestore(doc)).toList());
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

    return _db.collection('users').doc(user.uid).snapshots().asyncMap((userDoc) async {
      if (!userDoc.exists || userDoc.data()?['favoriteServices'] == null) {
        return [];
      }
      List<String> favoriteIds = List<String>.from(userDoc.data()!['favoriteServices']);
      if (favoriteIds.isEmpty) return [];

      final servicesQuery = await _db.collection('services').where(FieldPath.documentId, whereIn: favoriteIds).get();
      return servicesQuery.docs.map((doc) => Service.fromFirestore(doc)).toList();
    });
  }


  // --- GHI DỮ LIỆU ---

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
}