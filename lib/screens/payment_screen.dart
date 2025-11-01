import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/voucher.dart';
import '../services/firestore_service.dart';
import '../services/vietqr_generator.dart';
import '../services/voucher_service.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;
  final UserVoucher? voucher;
  final double? finalAmount;

  const PaymentScreen({
    Key? key,
    required this.booking,
    this.voucher,
    this.finalAmount,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final VoucherService _voucherService = VoucherService();

  Widget _buildVietQRSection() {
    try {
      // Sử dụng finalAmount nếu có, nếu không dùng giá service
      final amount = (widget.finalAmount ?? widget.booking.service.price)
          .toStringAsFixed(0);

      // Tạo URL hình ảnh VietQR
      final qrImageUrl = VietQRGenerator.generateImageUrl(
        amount: amount,
        addInfo: 'DH${widget.booking.id}',
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
              child: Image.network(
                // Sử dụng Image.network để hiển thị QR từ URL
                qrImageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Lỗi tải mã QR',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
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
                    'MB Bank', // Giữ nguyên hoặc có thể lấy từ config
                    Icons.account_balance,
                  ),
                  Divider(height: 16),
                  _buildPaymentInfo(
                    'Số tài khoản:',
                    VietQRGenerator.ACCOUNT_NO, // Sử dụng hằng số mới
                    Icons.credit_card,
                  ),
                  Divider(height: 16),
                  _buildPaymentInfo(
                    'Chủ tài khoản:',
                    VietQRGenerator.ACCOUNT_NAME, // Sử dụng hằng số mới
                    Icons.person,
                  ),
                  // Hiển thị giá gốc nếu có voucher
                  if (widget.voucher != null) ...[
                    Divider(height: 16),
                    _buildPaymentInfo(
                      'Giá gốc:',
                      '${widget.booking.service.price.toStringAsFixed(0)}đ',
                      Icons.receipt,
                      isStrikethrough: true,
                    ),
                    Divider(height: 16),
                    _buildPaymentInfo(
                      'Giảm giá:',
                      '-${widget.booking.discountAmount?.toStringAsFixed(0) ?? '0'}đ',
                      Icons.local_offer,
                      isDiscount: true,
                    ),
                  ],
                  Divider(height: 16),
                  _buildPaymentInfo(
                    widget.voucher != null ? 'Tổng thanh toán:' : 'Số tiền:',
                    '${(widget.finalAmount ?? widget.booking.service.price).toStringAsFixed(0)}đ',
                    Icons.monetization_on,
                    isBold: true,
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
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Vui lòng mở ứng dụng ngân hàng và quét mã QR để thanh toán',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildPaymentInfo(
    String label,
    String value,
    IconData icon, {
    bool isStrikethrough = false,
    bool isDiscount = false,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDiscount ? Colors.green : Colors.grey[600],
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? Colors.green : Colors.grey[600],
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
            color: isDiscount
                ? Colors.green
                : (isBold ? Color(0xFF0891B2) : Colors.black87),
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmPayment() async {
    // Cập nhật trạng thái booking với phương thức VietQR
    final updatedBooking = widget.booking.copyWith(
      paymentMethod: 'vietqr', // Luôn là VietQR
      status: 'confirmed', // Đã xác nhận
    );

    try {
      // Nếu booking chưa có ID (chưa được tạo trên Firestore), tạo mới
      String bookingId;
      if (widget.booking.id.isEmpty) {
        final docRef = await _firestoreService.addBooking(updatedBooking);
        bookingId = docRef.id;
      } else {
        // Nếu đã có ID, cập nhật
        await _firestoreService.updateBooking(updatedBooking);
        bookingId = widget.booking.id;
      }

      // Sử dụng voucher nếu có
      if (widget.voucher != null) {
        await _voucherService.useVoucher(widget.voucher!.id, bookingId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Thanh toán thành công! Lịch hẹn đã được xác nhận.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Đợi một chút để người dùng thấy thông báo
        await Future.delayed(Duration(milliseconds: 500));

        // Trở về với kết quả thành công
        if (!mounted) return;
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xác nhận thanh toán: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán Online'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Trả về false khi người dùng bấm nút back
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chỉ hiển thị mã VietQR, không có lựa chọn
            _buildVietQRSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _confirmPayment,
          child: Text(
            'Tôi đã thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0891B2),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
