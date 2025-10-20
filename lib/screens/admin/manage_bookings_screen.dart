// lib/screens/admin/manage_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Quản lý đơn đặt lịch'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Column(
        children: [
          // Filter
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade800),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Lọc theo trạng thái:',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1A1A1A),
                    style: const TextStyle(color: Colors.white),
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
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('bookings').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                
                final bookings = snapshot.data?.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList() ?? [];
                
                // Filter by status
                final filteredBookings = _selectedStatus == 'Tất cả'
                    ? bookings
                    : bookings.where((booking) => booking['status'] == _selectedStatus).toList();
                
                if (filteredBookings.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có đơn đặt lịch nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    final bookingId = snapshot.data!.docs[index].id;
                    
                    return Card(
                      margin: const EdgeInsets.all(8),
                      color: const Color(0xFF1A1A1A),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Đơn #${bookingId.substring(0, 8)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildStatusChip(booking['status'] ?? 'Chờ xác nhận'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Khách hàng: ${booking['customerName'] ?? 'N/A'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'SĐT: ${booking['customerPhone'] ?? 'N/A'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Chi nhánh: ${booking['branchName'] ?? 'N/A'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Dịch vụ: ${booking['serviceName'] ?? 'N/A'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Stylist: ${booking['stylistName'] ?? 'N/A'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Thời gian: ${booking['dateTime'] != null ? DateTime.fromMillisecondsSinceEpoch(booking['dateTime']).toString().substring(0, 16) : 'N/A'}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            if (booking['note'] != null && booking['note'].isNotEmpty)
                              Text(
                                'Ghi chú: ${booking['note']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showStatusDialog(bookingId, booking['status'] ?? 'Chờ xác nhận'),
                                  child: const Text('Cập nhật trạng thái'),
                                ),
                                ElevatedButton(
                                  onPressed: () => _deleteBooking(bookingId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Xóa'),
                                ),
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
        title: const Text('Cập nhật trạng thái'),
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
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }
}
