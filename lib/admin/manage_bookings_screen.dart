// lib/admin/manage_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';

class ManageBookingsScreen extends StatelessWidget {
  const ManageBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Đặt lịch'), elevation: 0),
      body: StreamBuilder<List<Booking>>(
        stream: FirestoreService().getAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có booking nào',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Sắp xếp bookings theo thời gian (mới nhất trước)
          final sortedBookings = List<Booking>.from(bookings);
          sortedBookings.sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedBookings.length,
            itemBuilder: (context, index) {
              final booking = sortedBookings[index];
              return _BookingCard(booking: booking);
            },
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking.status;

    // Xác định màu và label theo trạng thái
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'confirmed':
        statusColor = Colors.green;
        statusLabel = 'Đã xác nhận';
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusLabel = 'Hoàn thành';
        statusIcon = Icons.done_all;
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusLabel = 'Đã hủy';
        statusIcon = Icons.cancel;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusLabel = 'Bị từ chối';
        statusIcon = Icons.close;
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = 'Chờ xác nhận';
        statusIcon = Icons.pending;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Trạng thái
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(booking.dateTime),
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 24),

            // Thông tin khách hàng
            _buildInfoRow(Icons.person, 'Khách hàng', booking.customerName),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.phone, 'Số điện thoại', booking.customerPhone),
            const SizedBox(height: 8),

            // Thông tin dịch vụ
            _buildInfoRow(Icons.content_cut, 'Dịch vụ', booking.service.name),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person_pin, 'Stylist', booking.stylist.name),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.store, 'Chi nhánh', booking.branchName),

            // Ghi chú (nếu có)
            if (booking.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.note, 'Ghi chú', booking.note),
            ],

            // Thông báo: Booking tự động xác nhận
            if (status == 'confirmed') ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Booking đã được tự động xác nhận khi khách hàng đặt lịch',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
