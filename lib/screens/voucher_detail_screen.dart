// lib/screens/voucher_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/voucher.dart';
import '../services/voucher_service.dart';

class VoucherDetailScreen extends StatelessWidget {
  final Voucher voucher;
  final bool showClaimButton;

  const VoucherDetailScreen({
    super.key,
    required this.voucher,
    this.showClaimButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0891B2),
        title: const Text(
          'Chi tiết ưu đãi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với hình ảnh
            if (voucher.imageUrl != null)
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(voucher.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFFF6B9D), const Color(0xFFFFA06B)],
                  ),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    voucher.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Code card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF0891B2),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mã ưu đãi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                voucher.code,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0891B2),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: voucher.code),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép mã!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.copy,
                            color: Color(0xFF0891B2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildSection(
                    'Mô tả',
                    voucher.description,
                    Icons.description_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Value
                  _buildSection(
                    'Giá trị',
                    _getValueText(),
                    Icons.discount_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Condition
                  if (voucher.minAmount != null)
                    _buildSection(
                      'Điều kiện',
                      'Áp dụng cho đơn hàng từ ${voucher.minAmount!.toStringAsFixed(0)}đ',
                      Icons.rule_outlined,
                    ),
                  const SizedBox(height: 16),

                  // Validity
                  _buildSection(
                    'Thời hạn sử dụng',
                    '${DateFormat('dd/MM/yyyy').format(voucher.startDate)} - ${DateFormat('dd/MM/yyyy').format(voucher.endDate)}',
                    Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Usage limit
                  if (voucher.maxUses != -1)
                    _buildSection(
                      'Lượt sử dụng',
                      'Còn ${voucher.maxUses - voucher.currentUses}/${voucher.maxUses} lượt',
                      Icons.people_outline,
                    ),
                  const SizedBox(height: 24),

                  // Terms & Conditions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Điều khoản sử dụng',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getTermsText(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Claim Button
                  if (showClaimButton)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: voucher.isValid()
                            ? () => _claimVoucher(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0891B2),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.card_giftcard_rounded, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              voucher.isValid()
                                  ? 'Nhận ưu đãi ngay'
                                  : 'Hết hiệu lực',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF0891B2), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getValueText() {
    switch (voucher.type) {
      case VoucherType.percentage:
        return 'Giảm ${voucher.value.toStringAsFixed(0)}%';
      case VoucherType.fixed:
        return 'Giảm ${voucher.value.toStringAsFixed(0)}đ';
      case VoucherType.freeService:
        return 'Miễn phí dịch vụ';
    }
  }

  String _getTermsText() {
    List<String> terms = [];

    switch (voucher.condition) {
      case VoucherCondition.all:
        terms.add('• Áp dụng cho tất cả dịch vụ');
        break;
      case VoucherCondition.minAmount:
        terms.add(
          '• Áp dụng cho đơn hàng từ ${voucher.minAmount!.toStringAsFixed(0)}đ',
        );
        break;
      case VoucherCondition.firstBooking:
        terms.add('• Chỉ áp dụng cho lần đặt lịch đầu tiên');
        break;
      case VoucherCondition.specificService:
        terms.add('• Chỉ áp dụng cho một số dịch vụ nhất định');
        break;
    }

    terms.add('• Mỗi người chỉ được nhận một lần');
    terms.add('• Không áp dụng cùng lúc với các ưu đãi khác');
    if (voucher.maxUses != -1) {
      terms.add('• Số lượng có hạn, nhanh tay nhận ngay');
    }

    return terms.join('\n');
  }

  Future<void> _claimVoucher(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0891B2)),
        ),
      );

      final voucherService = VoucherService();
      await voucherService.claimVoucher(voucher.id);

      // Close loading
      if (context.mounted) Navigator.of(context).pop();

      // Show success
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text('Thành công!'),
              ],
            ),
            content: const Text(
              'Bạn đã nhận ưu đãi thành công! Kiểm tra trong phần "Ưu đãi của tôi".',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF0891B2)),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (context.mounted) Navigator.of(context).pop();

      // Show error
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text('Lỗi'),
              ],
            ),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF0891B2)),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
