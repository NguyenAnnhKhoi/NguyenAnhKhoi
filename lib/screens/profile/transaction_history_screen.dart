// lib/screens/profile/transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử giao dịch')),
      body: StreamBuilder<List<Booking>>(
        // Lấy danh sách các lịch hẹn từ Firestore
        stream: _firestoreService.getUserBookings(),
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Xử lý lỗi
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }
          // Nếu không có dữ liệu hoặc danh sách rỗng
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có giao dịch nào',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final transactions = snapshot.data!;

          // Hiển thị danh sách giao dịch
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = transactions[index];
              final isCompleted = booking.dateTime.isBefore(DateTime.now());

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isCompleted ? Colors.red : Colors.blue)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      // Icon cho thanh toán dịch vụ
                      Icons.cut,
                      color: isCompleted ? Colors.redAccent : Colors.blueAccent,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    booking.service.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    // Format ngày tháng cho dễ đọc
                    DateFormat('dd/MM/yyyy, HH:mm').format(booking.dateTime),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        // Hiển thị số tiền giao dịch
                        '-${currencyFormat.format(booking.service.price)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted ? 'Hoàn thành' : 'Sắp tới',
                         style: TextStyle(
                          fontSize: 12,
                          color: isCompleted ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}