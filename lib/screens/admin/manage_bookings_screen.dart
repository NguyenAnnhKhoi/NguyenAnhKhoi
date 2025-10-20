// lib/screens/admin/manage_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_ui.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedStatus = 'Tất cả';

  final List<String> _statusOptions = [
    'Tất cả',
    'Chờ xác nhận',
    'Đã xác nhận',
    'Đang thực hiện',
    'Hoàn thành',
    'Đã hủy',
  ];

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': newStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _deleteBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa đơn đặt lịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('bookings').doc(bookingId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa đơn đặt lịch thành công!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Chờ xác nhận':
        color = Colors.orange;
        break;
      case 'Đã xác nhận':
        color = Colors.blue;
        break;
      case 'Đang thực hiện':
        color = Colors.purple;
        break;
      case 'Hoàn thành':
        color = Colors.green;
        break;
      case 'Đã hủy':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return AdminStatusChip(label: status, color: color);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _bookingsStream() {
    final base = _firestore.collection('bookings').orderBy('dateTime', descending: true);
    if (_selectedStatus == 'Tất cả') {
      return base.snapshots();
    }
    return base.where('status', isEqualTo: _selectedStatus).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Quản lý đơn đặt lịch',
      body: Column(
        children: [
          // Filter
          AdminSection(
            child: Row(
              children: [
                const Text(
                  'Lọc theo trạng thái:',
                  style: TextStyle(color: AdminColors.textPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    dropdownColor: AdminColors.surface,
                    style: const TextStyle(color: AdminColors.textPrimary),
                    items: _statusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _bookingsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                
                final docs = snapshot.data?.docs ?? [];
                
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có đơn đặt lịch nào',
                      style: TextStyle(color: AdminColors.textSecondary),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final docId = doc.id;
                    final dateTime = data['dateTime'] is Timestamp
                        ? (data['dateTime'] as Timestamp).toDate()
                        : data['dateTime'] is int
                            ? DateTime.fromMillisecondsSinceEpoch(data['dateTime'] as int)
                            : null;
                    
                    return AdminCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Đơn #${docId.substring(0, 8)}',
                                  style: const TextStyle(
                                    color: AdminColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildStatusChip(data['status'] ?? 'Chờ xác nhận'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Khách hàng: ${data['customerName'] ?? 'N/A'}',
                              style: const TextStyle(color: AdminColors.textSecondary),
                            ),
                            Text(
                              'SĐT: ${data['customerPhone'] ?? 'N/A'}',
                              style: const TextStyle(color: AdminColors.textSecondary),
                            ),
                            Text(
                              'Chi nhánh: ${data['branchName'] ?? 'N/A'}',
                              style: const TextStyle(color: AdminColors.textSecondary),
                            ),
                            Text(
                              'Thời gian: ${dateTime != null ? dateTime.toString().substring(0, 16) : 'N/A'}',
                              style: const TextStyle(color: AdminColors.textSecondary),
                            ),
                            if (data['note'] != null && (data['note'] as String).isNotEmpty)
                              Text(
                                'Ghi chú: ${data['note']}',
                                style: const TextStyle(color: AdminColors.textSecondary),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(child: AdminPrimaryButton(
                                  label: 'Cập nhật trạng thái',
                                  icon: Icons.sync,
                                  onPressed: () => _showStatusDialog(docId, data['status'] ?? 'Chờ xác nhận'),
                                )),
                                const SizedBox(width: 12),
                                Expanded(child: AdminDangerButton(label: 'Xóa', onPressed: () => _deleteBooking(docId))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(String bookingId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AdminColors.surface,
        title: const Text('Cập nhật trạng thái', style: TextStyle(color: AdminColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Chọn trạng thái mới:'),
            const SizedBox(height: 16),
            ..._statusOptions.where((status) => status != 'Tất cả').map((status) {
              return RadioListTile<String>(
                title: Text(status),
                value: status,
                groupValue: currentStatus,
                onChanged: (value) {
                  if (value != null) {
                    _updateBookingStatus(bookingId, value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: AdminColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
