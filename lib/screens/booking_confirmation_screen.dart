// lib/screens/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../models/voucher.dart';
import '../services/voucher_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'payment_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  BookingConfirmationScreenState createState() =>
      BookingConfirmationScreenState();
}

class BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final VoucherService _voucherService = VoucherService();

  UserVoucher? _selectedVoucher;
  bool _isLoading = false;
  List<UserVoucher> _availableVouchers = [];
  String _paymentMethod = 'online'; // 'online' hoặc 'counter'

  @override
  void initState() {
    super.initState();
    _loadAvailableVouchers();
  }

  // Load các voucher khả dụng của user
  Future<void> _loadAvailableVouchers() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _voucherService.getUnusedUserVouchers(userId).listen((vouchers) {
      if (mounted) {
        setState(() {
          // Lọc vouchers có thể áp dụng cho booking này
          _availableVouchers = vouchers.where((v) {
            return v.voucher.canApply(
              orderAmount: widget.booking.service.price,
              serviceIds: [widget.booking.service.id],
              isFirstBooking: false, // TODO: Check thật
            );
          }).toList();
        });
      }
    });
  }

  // Tính tổng tiền sau khi áp dụng voucher
  double get _finalAmount {
    double total = widget.booking.service.price;
    if (_selectedVoucher != null) {
      final discount = _selectedVoucher!.voucher.calculateDiscount(total);
      total -= discount;
      if (total < 0) total = 0;
    }
    return total;
  }

  // Tính số tiền giảm
  double get _discountAmount {
    if (_selectedVoucher == null) return 0;
    return _selectedVoucher!.voucher.calculateDiscount(
      widget.booking.service.price,
    );
  }

  Future<void> _confirmPayment() async {
    setState(() => _isLoading = true);

    try {
      if (_paymentMethod == 'online') {
        // Thanh toán online - chuyển sang màn hình QR
        final confirmedBooking = widget.booking.copyWith(
          paymentMethod: 'vietqr',
          status: 'pending', // Chờ thanh toán
          finalAmount: _finalAmount,
          voucherId: _selectedVoucher?.voucherId,
          discountAmount: _discountAmount,
        );

        setState(() => _isLoading = false);

        // Chuyển đến màn hình thanh toán VietQR
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              booking: confirmedBooking,
              voucher: _selectedVoucher,
              finalAmount: _finalAmount,
            ),
          ),
        );

        if (result == true && mounted) {
          Navigator.pop(context, true); // Quay về booking screen
        }
      } else {
        // Thanh toán tại quầy - lưu booking trực tiếp
        final FirestoreService _firestoreService = FirestoreService();
        final NotificationService _notificationService = NotificationService();

        final confirmedBooking = widget.booking.copyWith(
          paymentMethod: 'Tại quầy',
          status: 'Chờ xác nhận',
          finalAmount: _finalAmount,
          voucherId: _selectedVoucher?.voucherId,
          discountAmount: _discountAmount,
        );

        // Lưu booking vào Firestore
        final docRef = await _firestoreService.addBooking(confirmedBooking);
        final savedBooking = confirmedBooking.copyWith(id: docRef.id);

        // Sử dụng voucher nếu có
        if (_selectedVoucher != null) {
          await _voucherService.useVoucher(
            _selectedVoucher!.id,
            savedBooking.id,
          );
        }

        // Đặt thông báo
        await _notificationService.scheduleBookingNotification(savedBooking);

        if (mounted) {
          setState(() => _isLoading = false);

          // Hiển thị dialog thành công
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 12),
                  Text('Đặt lịch thành công!'),
                ],
              ),
              content: Text(
                'Bạn đã đặt lịch thành công.\nVui lòng thanh toán tại quầy khi đến.',
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng dialog
                    Navigator.pop(context, true); // Quay về booking screen
                  },
                  child: Text('OK', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted && _paymentMethod == 'online') {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          '💳 Xác nhận thanh toán',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingInfo(),
            const SizedBox(height: 24),
            _buildVoucherSection(),
            const SizedBox(height: 24),
            _buildPaymentMethodSection(),
            const SizedBox(height: 24),
            _buildPriceBreakdown(),
            const SizedBox(height: 32),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đặt lịch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.content_cut_rounded,
            label: 'Dịch vụ',
            value: widget.booking.service.name,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'Stylist',
            value: widget.booking.stylist.name,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.business_outlined,
            label: 'Chi nhánh',
            value: widget.booking.branchName,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Thời gian',
            value: DateFormat(
              'dd/MM/yyyy, HH:mm',
            ).format(widget.booking.dateTime),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_offer_rounded,
                color: Color(0xFFFF6B9D),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Khuyến mãi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_availableVouchers.isEmpty)
            Text(
              'Không có khuyến mãi khả dụng',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            )
          else
            InkWell(
              onTap: () => _showVoucherPicker(),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedVoucher != null
                        ? const Color(0xFFFF6B9D)
                        : Colors.grey[300]!,
                    width: _selectedVoucher != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedVoucher != null
                            ? _selectedVoucher!.voucher.title
                            : 'Chọn mã giảm giá',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _selectedVoucher != null
                              ? const Color(0xFFFF6B9D)
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payment_rounded,
                color: Color(0xFF0891B2),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.grey.shade50,
              selectedBackgroundColor: const Color(
                0xFF0891B2,
              ).withOpacity(0.15),
              selectedForegroundColor: const Color(0xFF0891B2),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            segments: const [
              ButtonSegment<String>(
                value: 'counter',
                label: Text('Tại quầy'),
                icon: Icon(Icons.storefront_rounded),
              ),
              ButtonSegment<String>(
                value: 'online',
                label: Text('Online'),
                icon: Icon(Icons.qr_code_scanner_rounded),
              ),
            ],
            selected: {_paymentMethod},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _paymentMethod = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 12),
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
                  Icons.info_outline_rounded,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _paymentMethod == 'counter'
                        ? 'Bạn sẽ thanh toán trực tiếp tại cửa hàng khi đến làm dịch vụ'
                        : 'Vui lòng quét mã QR để thanh toán trước khi đến',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B9D).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giá dịch vụ',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                ).format(widget.booking.service.price),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (_selectedVoucher != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giảm giá',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
                Text(
                  '- ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(_discountAmount)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white, height: 24),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                NumberFormat.currency(
                  locale: 'vi_VN',
                  symbol: 'đ',
                ).format(_finalAmount),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0891B2),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF0891B2).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _paymentMethod == 'counter'
                    ? 'Xác nhận đặt lịch'
                    : 'Tiếp tục thanh toán',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _showVoucherPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, controller) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chọn mã giảm giá',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _availableVouchers.length + 1,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Option để bỏ chọn voucher
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedVoucher = null);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedVoucher == null
                                  ? const Color(0xFF0891B2)
                                  : Colors.grey[300]!,
                              width: _selectedVoucher == null ? 2 : 1,
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.close, color: Colors.grey),
                              SizedBox(width: 12),
                              Text(
                                'Không sử dụng mã giảm giá',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final userVoucher = _availableVouchers[index - 1];
                    final voucher = userVoucher.voucher;
                    final isSelected = _selectedVoucher?.id == userVoucher.id;

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedVoucher = userVoucher);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B9D),
                                    Color(0xFFFF8FAB),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF6B9D)
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.3)
                                        : const Color(
                                            0xFFFF6B9D,
                                          ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    voucher.code,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFFFF6B9D),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              voucher.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voucher.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.grey[500],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'HSD: ${DateFormat('dd/MM/yyyy').format(voucher.endDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? Colors.white.withOpacity(0.8)
                                        : Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
