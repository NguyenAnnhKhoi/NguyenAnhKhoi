// lib/providers/booking_provider.dart
import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';

/// Provider quản lý trạng thái booking
class BookingProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // Booking state
  Service? _selectedService;
  Stylist? _selectedStylist;
  Branch? _selectedBranch;
  DateTime? _selectedDate;
  String? _selectedTime;
  String _paymentMethod = 'Tại quầy';
  String _note = '';

  // Loading states
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Service? get selectedService => _selectedService;
  Stylist? get selectedStylist => _selectedStylist;
  Branch? get selectedBranch => _selectedBranch;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;
  String get paymentMethod => _paymentMethod;
  String get note => _note;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Kiểm tra đã chọn đủ thông tin chưa
  bool get isBookingComplete =>
      _selectedService != null &&
      _selectedStylist != null &&
      _selectedBranch != null &&
      _selectedDate != null &&
      _selectedTime != null;

  /// Tính tổng giá
  double get totalPrice => _selectedService?.price ?? 0.0;

  // Setters
  void setService(Service? service) {
    _selectedService = service;
    notifyListeners();
  }

  void setStylist(Stylist? stylist) {
    _selectedStylist = stylist;
    notifyListeners();
  }

  void setBranch(Branch? branch) {
    _selectedBranch = branch;
    notifyListeners();
  }

  void setDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setTime(String? time) {
    _selectedTime = time;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void setNote(String noteText) {
    _note = noteText;
    notifyListeners();
  }

  /// Reset tất cả booking data
  void resetBooking() {
    _selectedService = null;
    _selectedStylist = null;
    _selectedBranch = null;
    _selectedDate = null;
    _selectedTime = null;
    _paymentMethod = 'Tại quầy';
    _note = '';
    _clearError();
    notifyListeners();
  }

  /// Tạo booking
  Future<bool> createBooking({
    required String customerName,
    required String customerPhone,
  }) async {
    if (!isBookingComplete) {
      _setError('Vui lòng điền đầy đủ thông tin');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      final booking = Booking(
        id: '',
        service: _selectedService!,
        stylist: _selectedStylist!,
        dateTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          int.parse(_selectedTime!.split(':')[0]),
          int.parse(_selectedTime!.split(':')[1]),
        ),
        status: _paymentMethod == 'Online' ? 'Đã xác nhận' : 'Chờ xác nhận',
        note: _note,
        customerName: customerName,
        customerPhone: customerPhone,
        branchName: _selectedBranch!.name,
        paymentMethod: _paymentMethod,
      );

      await _firestoreService.addBooking(booking);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Get user bookings stream
  Stream<List<Booking>> getUserBookings() {
    return _firestoreService.getUserBookings();
  }

  /// Cancel booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.cancelBooking(bookingId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
