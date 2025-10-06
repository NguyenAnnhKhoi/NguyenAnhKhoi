import 'service.dart';
import 'stylist.dart';

class Booking {
  final int id;
  final Service service;
  final Stylist stylist;
  final DateTime dateTime;
  final String status;
  final String note;

  Booking({
    required this.id,
    required this.service,
    required this.stylist,
    required this.dateTime,
    required this.status,
    this.note = "",
  });
}
