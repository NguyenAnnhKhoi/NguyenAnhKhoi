// lib/screens/profile/my_vouchers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/voucher.dart';
import '../../services/voucher_service.dart';
import '../voucher_detail_screen.dart';

class MyVouchersScreen extends StatefulWidget {
  const MyVouchersScreen({super.key});

  @override
  State<MyVouchersScreen> createState() => _MyVouchersScreenState();
}

class _MyVouchersScreenState extends State<MyVouchersScreen>
    with SingleTickerProviderStateMixin {
  final VoucherService _voucherService = VoucherService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _codeController = TextEditingController();

  late TabController _tabController;
  bool _isClaimingCode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _showClaimCodeDialog() async {
    _codeController.clear();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF0891B2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: Color(0xFF0891B2),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Nhập mã voucher',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhập mã voucher của bạn để nhận ưu đãi',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'VD: WELCOME2024',
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0891B2),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _claimVoucherByCode(_codeController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0891B2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Nhận voucher'),
          ),
        ],
      ),
    );
  }

  Future<void> _claimVoucherByCode(String code) async {
    if (code.isEmpty) {
      _showMessage('Vui lòng nhập mã voucher', isError: true);
      return;
    }

    setState(() => _isClaimingCode = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Vui lòng đăng nhập');

      // Tìm voucher theo code
      final voucher = await _voucherService.getVoucherByCode(code);

      if (voucher == null) {
        throw Exception('Mã voucher không tồn tại');
      }

      if (!voucher.isValid()) {
        throw Exception('Voucher đã hết hạn hoặc không còn hiệu lực');
      }

      // Claim voucher
      await _voucherService.claimVoucher(voucher.id);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isClaimingCode = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 12),
            Text(
              'Nhận voucher thành công!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Voucher đã được thêm vào danh sách của bạn. Bạn có thể sử dụng khi đặt lịch.',
          style: TextStyle(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0891B2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Đóng'),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0891B2),
        title: const Text(
          'Voucher của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 15,
          ),
          tabs: const [
            Tab(text: 'Chưa sử dụng'),
            Tab(text: 'Đã sử dụng'),
          ],
        ),
      ),
      body: userId == null
          ? _buildLoginRequired()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildVoucherList(userId, isUsed: false),
                _buildVoucherList(userId, isUsed: true),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isClaimingCode ? null : _showClaimCodeDialog,
        backgroundColor: const Color(0xFF0891B2),
        icon: const Icon(Icons.add),
        label: const Text(
          'Nhập mã',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginRequired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Vui lòng đăng nhập',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đăng nhập để xem voucher của bạn',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherList(String userId, {required bool isUsed}) {
    return StreamBuilder<List<UserVoucher>>(
      stream: _voucherService.getUserVouchers(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0891B2)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${snapshot.error}',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final allVouchers = snapshot.data ?? [];
        final filteredVouchers = allVouchers
            .where((v) => v.isUsed == isUsed)
            .toList();

        if (filteredVouchers.isEmpty) {
          return _buildEmptyState(isUsed);
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: const Color(0xFF0891B2),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredVouchers.length,
            itemBuilder: (context, index) {
              return _buildVoucherCard(filteredVouchers[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isUsed) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0891B2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUsed ? Icons.history : Icons.card_giftcard_rounded,
              size: 64,
              color: const Color(0xFF0891B2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isUsed ? 'Chưa có voucher đã sử dụng' : 'Chưa có voucher',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              isUsed
                  ? 'Các voucher bạn đã sử dụng sẽ hiển thị ở đây'
                  : 'Nhận voucher từ khuyến mãi hoặc nhập mã để nhận ưu đãi',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
          if (!isUsed) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showClaimCodeDialog,
              icon: const Icon(Icons.add),
              label: const Text('Nhập mã voucher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0891B2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoucherCard(UserVoucher userVoucher) {
    final voucher = userVoucher.voucher;
    final canUse = userVoucher.canUse();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                VoucherDetailScreen(voucher: voucher, showClaimButton: false),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: canUse
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFFA06B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade400],
                ),
          boxShadow: [
            BoxShadow(
              color: canUse
                  ? const Color(0xFFFF6B9D).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.card_giftcard_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              voucher.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getValueText(voucher),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          size: 16,
                          color: Color(0xFF0891B2),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          voucher.code,
                          style: const TextStyle(
                            color: Color(0xFF0891B2),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'HSD: ${DateFormat('dd/MM/yyyy').format(voucher.endDate)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (userVoucher.isUsed) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Đã sử dụng: ${DateFormat('dd/MM/yyyy HH:mm').format(userVoucher.usedAt!)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!canUse)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        userVoucher.isUsed ? 'ĐÃ SỬ DỤNG' : 'HẾT HẠN',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getValueText(Voucher voucher) {
    switch (voucher.type) {
      case VoucherType.percentage:
        return 'Giảm ${voucher.value.toStringAsFixed(0)}%';
      case VoucherType.fixed:
        return 'Giảm ${voucher.value.toStringAsFixed(0)}đ';
      case VoucherType.freeService:
        return 'Miễn phí dịch vụ';
    }
  }
}
