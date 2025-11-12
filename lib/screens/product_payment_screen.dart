// lib/screens/product_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart' as order_model;
import '../services/firestore_service.dart';
import '../services/vietqr_generator.dart';

class ProductPaymentScreen extends StatefulWidget {
  final order_model.Order order;

  const ProductPaymentScreen({super.key, required this.order});

  @override
  State<ProductPaymentScreen> createState() => _ProductPaymentScreenState();
}

class _ProductPaymentScreenState extends State<ProductPaymentScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  Widget _buildVietQRSection() {
    try {
      // Sử dụng total từ order
      final amount = widget.order.total.toStringAsFixed(0);

      // Tạo URL hình ảnh VietQR
      final qrImageUrl = VietQRGenerator.generateImageUrl(
        amount: amount,
        addInfo: 'DH${widget.order.id.isEmpty ? 'NEW' : widget.order.id}',
      );

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // QR Code
            Container(
              width: 250,
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Image.network(
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
                        const Icon(Icons.error, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        const Text(
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
            const SizedBox(height: 16),

            // Thông tin thanh toán
            Container(
              padding: const EdgeInsets.all(16),
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
                  const Divider(height: 16),
                  _buildPaymentInfo(
                    'Số tài khoản:',
                    VietQRGenerator.ACCOUNT_NO,
                    Icons.credit_card,
                  ),
                  const Divider(height: 16),
                  _buildPaymentInfo(
                    'Chủ tài khoản:',
                    VietQRGenerator.ACCOUNT_NAME,
                    Icons.person,
                  ),
                  // Hiển thị giá gốc nếu có voucher
                  if (widget.order.discountAmount != null &&
                      widget.order.discountAmount! > 0) ...[
                    const Divider(height: 16),
                    _buildPaymentInfo(
                      'Giá gốc:',
                      '${widget.order.subtotal.toStringAsFixed(0)}đ',
                      Icons.receipt,
                      isStrikethrough: true,
                    ),
                    const Divider(height: 16),
                    _buildPaymentInfo(
                      'Giảm giá:',
                      '-${widget.order.discountAmount!.toStringAsFixed(0)}đ',
                      Icons.local_offer,
                      isDiscount: true,
                    ),
                  ],
                  const Divider(height: 16),
                  _buildPaymentInfo(
                    widget.order.discountAmount != null &&
                            widget.order.discountAmount! > 0
                        ? 'Tổng thanh toán:'
                        : 'Số tiền:',
                    '${widget.order.total.toStringAsFixed(0)}đ',
                    Icons.monetization_on,
                    isBold: true,
                  ),
                  const Divider(height: 16),
                  _buildPaymentInfo(
                    'Nội dung CK:',
                    'DH${widget.order.id.isEmpty ? 'NEW' : widget.order.id}',
                    Icons.message,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
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
                  const SizedBox(width: 12),
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
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Không thể tạo mã QR:\n$e',
              style: const TextStyle(color: Colors.red),
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
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? Colors.green : Colors.grey[600],
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: isBold ? 16 : 14,
            color: isDiscount
                ? Colors.green
                : (isBold ? const Color(0xFF0891B2) : Colors.black87),
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmPayment() async {
    try {
      // Lấy user hiện tại
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Bạn cần đăng nhập để thanh toán');
      }

      // Tạo order với userId của user hiện tại
      final orderWithUserId = widget.order.copyWith(userId: user.uid);
      final createdOrder = await _firestoreService.addOrder(orderWithUserId);

      // Áp dụng voucher nếu có
      if (widget.order.voucherCode != null) {
        final voucher = await _firestoreService.getVoucherByCode(
          widget.order.voucherCode!,
        );
        if (voucher != null) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            // Note: applyVoucher is for bookings, we'll handle voucher usage for orders separately
            // For now, just mark the order as using the voucher
          }
        }
      }

      // Cập nhật order với ID và trạng thái đã thanh toán
      final updatedOrder = createdOrder.copyWith(
        paymentMethod: 'VietQR',
        status: 'confirmed',
        isPaid: true,
        paidAt: DateTime.now(),
      );

      await _firestoreService.updateOrder(updatedOrder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✓ Thanh toán thành công! Đơn hàng đã được xác nhận.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );

        // Đợi một chút để người dùng thấy thông báo
        await Future.delayed(const Duration(milliseconds: 500));

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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
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
        title: const Text('Thanh toán Online'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đơn hàng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...widget.order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.productName} x ${item.quantity}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            '${item.total.toStringAsFixed(0)}đ',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildVietQRSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _confirmPayment,
          child: const Text(
            'Tôi đã thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0891B2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
