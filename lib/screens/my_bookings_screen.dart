// lib/screens/my_bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
// --- THÊM IMPORT NÀY ---
import '../services/notification_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  MyBookingsScreenState createState() => MyBookingsScreenState();
}

class MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
  // --- THÊM SERVICE NÀY ---
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... Phần build UI giữ nguyên ...
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF1E3A8A),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Lịch hẹn của tôi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E3A8A), Color(0xFF1E3A8A)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.calendar_month,
                      size: 60,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(icon: Icon(Icons.upcoming), text: 'Sắp tới'),
                  Tab(icon: Icon(Icons.history), text: 'Lịch sử'),
                ],
              ),
            ),
          ];
        },
        body: StreamBuilder<List<Booking>>(
          stream: _firestoreService.getUserBookings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Lỗi: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return TabBarView(
                controller: _tabController,
                children: [
                  _buildEmptyState(true),
                  _buildEmptyState(false),
                ],
              );
            }
            
            final bookings = snapshot.data!;
            List<Booking> upcomingBookings = bookings.where((b) => b.dateTime.isAfter(DateTime.now())).toList();
            List<Booking> pastBookings = bookings.where((b) => b.dateTime.isBefore(DateTime.now())).toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(upcomingBookings, isUpcoming: true),
                _buildBookingList(pastBookings, isUpcoming: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) => _buildBookingCard(bookings[i], isUpcoming: isUpcoming),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isUpcoming ? Icons.event_busy : Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            isUpcoming ? 'Chưa có lịch hẹn sắp tới' : 'Chưa có lịch sử',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, {required bool isUpcoming}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(booking.service.image),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stylist: ${booking.stylist.name}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(DateFormat('dd/MM/yyyy, HH:mm').format(booking.dateTime)),
                  ],
                ),
                Text(
                  NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(booking.service.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelDialog(booking),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Hủy lịch'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {}, // TODO: Chức năng đổi lịch
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Đổi lịch'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch hẹn?'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // --- CẬP NHẬT LOGIC NÀY ---
                // 1. Hủy thông báo đã đặt trước
                await _notificationService.cancelNotification(booking.id);
                // 2. Xóa booking khỏi Firestore
                await _firestoreService.cancelBooking(booking.id);

                if(mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã hủy lịch hẹn'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                 if(mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );
  }
}