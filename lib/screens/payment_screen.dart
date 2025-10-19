// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;
  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  // --- THÔNG TIN MOCK ĐỂ TẠO MÃ VIETQR ---
  // Thay thế bằng thông tin thật của bạn
  final String bankBin = "260804"; // BIN của Vietcombank
  final String bankAccount = "0977175770"; // Số tài khoản của bạn
  final String accountName = "THAN QUANG TUAN"; // Tên chủ tài khoản
  // ------------------------------------------

  String _getQRString() {
    // Tạo nội dung chuyển khoản, ví dụ: "TG Tuan cat toc 15:30"
    String memo =
        'TG ${widget.booking.customerName.split(' ').last} ${widget.booking.service.name.split(' ').first} ${DateFormat('HH:mm').format(widget.booking.dateTime)}';

    // Tạo URL VietQR thủ công theo format chuẩn
    // Format: https://img.vietqr.io/image/[bankBin]-[accountNumber]-compact2.jpg?amount=[amount]&addInfo=[memo]&accountName=[accountName]
    final amount = widget.booking.service.price.toInt();
    final encodedMemo = Uri.encodeComponent(memo);
    final encodedAccountName = Uri.encodeComponent(accountName);
    
    return 'https://img.vietqr.io/image/$bankBin-$bankAccount-compact2.jpg?amount=$amount&addInfo=$encodedMemo&accountName=$encodedAccountName';
  }

  Future<void> _confirmPayment() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Lưu booking vào Firestore
      final docRef = await _firestoreService.addBooking(widget.booking);
      final newBooking = widget.booking.copyWith(id: docRef.id);

      // 2. Đặt lịch thông báo
      await _notificationService.scheduleBookingNotification(newBooking);

      if (!mounted) return;

      // 3. Hiển thị dialog thành công
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
                SizedBox(height: 24),
                Text(
                  'Thanh toán thành công!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Lịch hẹn của bạn đã được xác nhận. Hẹn gặp bạn nhé!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                ),
                SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    // Đóng dialog trước
                    Navigator.of(context).pop();
                    // Trả về true để BookingScreen biết thanh toán thành công
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Về trang chủ'),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu lịch hẹn: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final qrString = _getQRString();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán Online'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quét mã để thanh toán',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Sử dụng App ngân hàng hoặc ví điện tử',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    qrString,
                    width: 280,
                    height: 280,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 280,
                        height: 280,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 280,
                        height: 280,
                        color: Colors.grey.shade100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                            SizedBox(height: 8),
                            Text(
                              'Lỗi tạo mã QR',
                              style: TextStyle(color: Colors.red.shade400),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            _buildInfoCard(context, currencyFormat),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _confirmPayment,
              icon: _isLoading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(Icons.check_circle_outline),
              label: Text(_isLoading ? 'Đang xử lý...' : 'Tôi đã thanh toán'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, NumberFormat currencyFormat) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết dịch vụ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildInfoRow(
            Icons.content_cut_rounded,
            'Dịch vụ',
            widget.booking.service.name,
          ),
          _buildInfoRow(
            Icons.person_outline,
            'Stylist',
            widget.booking.stylist.name,
          ),
          _buildInfoRow(
            Icons.business_rounded,
            'Chi nhánh',
            widget.booking.branchName,
          ),
          _buildInfoRow(
            Icons.calendar_month_rounded,
            'Thời gian',
            DateFormat('dd/MM/yyyy, HH:mm').format(widget.booking.dateTime),
          ),
          Divider(height: 24, color: Colors.grey.shade200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TỔNG CỘNG',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                currencyFormat.format(widget.booking.service.price),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}