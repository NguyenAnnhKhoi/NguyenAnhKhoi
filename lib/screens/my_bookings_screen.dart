// lib/screens/my_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'quick_booking_screen.dart';
import 'reschedule_booking_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  MyBookingsScreenState createState() => MyBookingsScreenState();
}

class MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();
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
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  '📅 Lịch hẹn của tôi',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Color(0xFF0F172A),
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF0F9FF),
                        Color(0xFFE0F2FE),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 60, right: 20),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF0891B2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 32,
                          color: Color(0xFF0891B2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF0891B2).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Color(0xFF64748B),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upcoming_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Sắp tới'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded, size: 18),
                              SizedBox(width: 6),
                              Text('Lịch sử'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.grey[50],
          child: StreamBuilder<List<Booking>>(
            stream: _firestoreService.getUserBookings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
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
              List<Booking> upcomingBookings = bookings
                  .where((b) => b.dateTime.isAfter(DateTime.now()))
                  .toList();
              List<Booking> pastBookings = bookings
                  .where((b) => b.dateTime.isBefore(DateTime.now()))
                  .toList();

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
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (ctx, i) => Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: _buildBookingCard(bookings[i], isUpcoming: isUpcoming),
      ),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF0F9FF),
                  Color(0xFFE0F2FE),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF0891B2).withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              isUpcoming ? '📅' : '📋',
              style: TextStyle(fontSize: 72),
            ),
          ),
          SizedBox(height: 24),
          Text(
            isUpcoming ? 'Chưa có lịch hẹn nào' : 'Chưa có lịch sử',
            style: TextStyle(
              fontSize: 22,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              isUpcoming 
                  ? 'Bắt đầu đặt lịch để trải nghiệm dịch vụ tuyệt vời! ✨' 
                  : 'Các lịch hẹn đã hoàn thành sẽ hiện ở đây',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (isUpcoming) ...[
            SizedBox(height: 32),
            ElevatedButton.icon(
              // --- THAY ĐỔI CHỖ NÀY ---
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuickBookingScreen()),
                );
              },
              // --- KẾT THÚC THAY ĐỔI ---
              icon: Icon(Icons.add_circle_outline, size: 20),
              label: Text('Đặt lịch ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0891B2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                shadowColor: Color(0xFF0891B2).withOpacity(0.4),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, {required bool isUpcoming}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    booking.service.image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 6),
                          Text(
                            booking.stylist.name,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business_outlined, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              booking.branchName,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF0891B2)),
                        SizedBox(width: 8),
                        Text(
                          DateFormat('dd/MM/yyyy, HH:mm').format(booking.dateTime),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ')
                          .format(booking.service.price),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0891B2),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                // Hiển thị trạng thái thanh toán
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: booking.paymentMethod == 'vietqr'
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: booking.paymentMethod == 'vietqr'
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            booking.paymentMethod == 'vietqr'
                                ? Icons.check_circle
                                : Icons.schedule,
                            size: 14,
                            color: booking.paymentMethod == 'vietqr'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          SizedBox(width: 6),
                          Text(
                            booking.paymentMethod == 'vietqr'
                                ? 'Đã thanh toán'
                                : 'Chưa thanh toán',
                            style: TextStyle(
                              fontSize: 12,
                              color: booking.paymentMethod == 'vietqr'
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                if (isUpcoming) ...[
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showCancelDialog(booking),
                          icon: Icon(Icons.cancel_outlined, size: 18),
                          label: Text('Hủy lịch'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade400,
                            side: BorderSide(color: Colors.red.shade200, width: 1.5),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToReschedule(booking),
                          icon: Icon(Icons.edit_calendar_rounded, size: 18),
                          label: Text('Đổi lịch'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0891B2),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            elevation: 3,
                            shadowColor: Color(0xFF0891B2).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel_outlined, color: Colors.red.shade400, size: 48),
              ),
              SizedBox(height: 20),
              Text(
                'Hủy lịch hẹn?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Bạn có chắc chắn muốn hủy lịch hẹn này không?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Không',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await _notificationService.cancelNotification(booking.id);
                          await _firestoreService.cancelBooking(booking.id);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Đã hủy lịch hẹn',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Lịch hẹn đã được hủy thành công',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF10B981),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.only(
                                  bottom: 20,
                                  left: 16,
                                  right: 16,
                                  top: 80,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.error_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Có lỗi xảy ra',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Lỗi: $e',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFFEF4444), // Red 500
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.only(
                                  bottom: 20,
                                  left: 16,
                                  right: 16,
                                  top: 80,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 6,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hủy lịch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToReschedule(Booking booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RescheduleBookingScreen(booking: booking),
      ),
    );

    // Nếu đổi lịch thành công, hiển thị thông báo
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thành công! ✨',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Lịch hẹn đã được cập nhật',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981), // Green 500
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 20,
            left: 16,
            right: 16,
            top: 80, // Hiển thị cao hơn
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}