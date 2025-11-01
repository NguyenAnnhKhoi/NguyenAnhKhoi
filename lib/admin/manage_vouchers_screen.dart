// lib/admin/manage_vouchers_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/voucher.dart';
import '../services/voucher_service.dart';
import 'voucher_edit_screen.dart';

class ManageVouchersScreen extends StatefulWidget {
  const ManageVouchersScreen({super.key});

  @override
  State<ManageVouchersScreen> createState() => _ManageVouchersScreenState();
}

class _ManageVouchersScreenState extends State<ManageVouchersScreen> {
  final VoucherService _voucherService = VoucherService();
  String _filterStatus = 'all'; // all, active, expired

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Quản lý khuyến mãi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(
                value: 'active',
                child: Text('Đang hoạt động'),
              ),
              const PopupMenuItem(value: 'expired', child: Text('Đã hết hạn')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Voucher>>(
        stream: _voucherService.getActiveVouchers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                ],
              ),
            );
          }

          final allVouchers = snapshot.data ?? [];

          // Lọc vouchers theo filter
          final filteredVouchers = allVouchers.where((v) {
            if (_filterStatus == 'active') {
              return v.isValid();
            } else if (_filterStatus == 'expired') {
              return !v.isValid();
            }
            return true; // all
          }).toList();

          if (filteredVouchers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có voucher nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhấn nút + để tạo voucher mới',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredVouchers.length,
            itemBuilder: (context, index) {
              final voucher = filteredVouchers[index];
              return _buildVoucherCard(voucher);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VoucherEditScreen()),
          );
        },
        backgroundColor: const Color(0xFF0891B2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tạo voucher',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildVoucherCard(Voucher voucher) {
    final isExpired = !voucher.isValid();
    final isActive = voucher.isActive && !isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isActive
            ? const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFFF8FAB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey.shade400, Colors.grey.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? const Color(0xFFFF6B9D).withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VoucherEditScreen(voucher: voucher),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            size: 16,
                            color: isActive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive
                                ? 'Hoạt động'
                                : (isExpired ? 'Hết hạn' : 'Tạm dừng'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Usage count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.people_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${voucher.currentUses}/${voucher.maxUses == -1 ? '∞' : voucher.maxUses}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Voucher Code
                Text(
                  voucher.code,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  voucher.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Discount info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getVoucherIcon(voucher.type),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getVoucherValueText(voucher),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Validity period
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Từ ${DateFormat('dd/MM/yyyy').format(voucher.startDate)} '
                        'đến ${DateFormat('dd/MM/yyyy').format(voucher.endDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getVoucherIcon(VoucherType type) {
    switch (type) {
      case VoucherType.percentage:
        return Icons.percent_rounded;
      case VoucherType.fixed:
        return Icons.attach_money_rounded;
      case VoucherType.freeService:
        return Icons.card_giftcard_rounded;
    }
  }

  String _getVoucherValueText(Voucher voucher) {
    switch (voucher.type) {
      case VoucherType.percentage:
        return 'Giảm ${voucher.value.toInt()}%';
      case VoucherType.fixed:
        return 'Giảm ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(voucher.value)}';
      case VoucherType.freeService:
        return 'Miễn phí dịch vụ';
    }
  }
}
