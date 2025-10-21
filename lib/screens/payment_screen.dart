import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import '../utils/vietqr_generator.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;

  const PaymentScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _selectedPaymentMethod;

  Widget _buildPaymentOption({
    required String title,
    required String value,
    required String description,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedPaymentMethod == value
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          width: _selectedPaymentMethod == value ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (String? value) {
          setState(() => _selectedPaymentMethod = value);
        },
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            SizedBox(width: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        subtitle: Text(description),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildVietQRSection() {
    try {
      // Format số tiền thành chuỗi số nguyên
      final amount = widget.booking.amount.toStringAsFixed(0);

      final qrString = VietQRGenerator.generateQRString(
        amount: amount,
        purpose: 'DH${widget.booking.id}',
      );

      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // QR Code
            Container(
              width: 250, // Đặt kích thước cố định
              height: 250,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: QrImageView(
                data: qrString,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),
            SizedBox(height: 16),

            // Thông tin thanh toán
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildPaymentInfo(
                    'Ngân hàng:',
                    'MB Bank',
                    Icons.account_balance,
                  ),
                  Divider(height: 16),
                  _buildPaymentInfo(
                    'Số tài khoản:',
                    VietQRGenerator.TEST_ACCOUNT,
                    Icons.credit_card,
                  ),
                  Divider(height: 16),
                  _buildPaymentInfo(
                    'Chủ tài khoản:',
                    VietQRGenerator.TEST_NAME,
                    Icons.person,
                  ),
                  Divider(height: 16),
                  _buildPaymentInfo(
                    'Số tiền:',
                    '${widget.booking.amount.toStringAsFixed(0)}đ',
                    Icons.monetization_on,
                  ),
                  Divider(height: 16),
                  _buildPaymentInfo(
                    'Nội dung CK:',
                    'DH${widget.booking.id}',
                    Icons.message,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Sau khi chuyển khoản, nhấn xác nhận bên dưới',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Không thể tạo mã QR:\n$e',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPaymentInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Future<void> _confirmPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn phương thức thanh toán'),
          backgroundColor: const Color(0xFF0891B2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      final updatedBooking = widget.booking.copyWith(
        paymentMethod: _selectedPaymentMethod,
        status: 'Chờ xác nhận', // Giữ trạng thái chờ xác nhận để admin có thể xác nhận
        isPaid: true,
        paidAt: DateTime.now(),
      );

      await _firestoreService.updateBooking(updatedBooking);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text('Thanh toán thành công! Đơn hàng đang chờ xác nhận.'),
            backgroundColor: const Color(0xFF0891B2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context); // Return to previous screen
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: const Color(0xFF0891B2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thanh toán')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Payment Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin thanh toán',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Divider(),
                    _buildPaymentDetail(
                      'Dịch vụ:',
                      widget.booking.service.name,
                    ),
                    _buildPaymentDetail('Giá:', '${widget.booking.amount}đ'),
                    _buildPaymentDetail(
                      'Thời gian:',
                      '${widget.booking.dateTime.day}/${widget.booking.dateTime.month}/${widget.booking.dateTime.year} ${widget.booking.dateTime.hour}:${widget.booking.dateTime.minute}',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            Text(
              'Chọn phương thức thanh toán',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),

            // Payment Options
            _buildPaymentOption(
              title: 'Tiền mặt',
              value: 'CASH',
              description: 'Thanh toán tại cửa hàng',
              icon: Icons.payments_outlined,
            ),

            _buildPaymentOption(
              title: 'Chuyển khoản',
              value: 'TRANSFER',
              description: 'Chuyển khoản qua VietQR',
              icon: Icons.qr_code_rounded,
            ),

            SizedBox(height: 24),

            // VietQR Section
            if (_selectedPaymentMethod == 'TRANSFER') _buildVietQRSection(),

            SizedBox(height: 24),

            // Confirm Button
            ElevatedButton(
              onPressed: _confirmPayment,
              child: Text('Xác nhận thanh toán'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
