import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/stylist.dart';
import '../services/firestore_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  Stylist? selectedStylist;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _confirmBooking(Service service) async {
    if (selectedStylist == null || selectedDate == null || selectedTime == null) return;
    
    setState(() => _isLoading = true);

    final newBooking = Booking(
      id: '', // Firestore sẽ tự tạo ID
      service: service,
      stylist: selectedStylist!,
      dateTime: DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      ),
      status: 'Chờ xác nhận',
    );
    
    try {
      await _firestoreService.addBooking(newBooking);
      if(mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thành công!'),
            content: const Text('Đặt lịch thành công! Chúng tôi sẽ gọi xác nhận trong thời gian sớm nhất.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch(e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red,));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)!.settings.arguments as Service;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A8A),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Đặt lịch hẹn', style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), Color(0xFF0097A7)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.calendar_month, size: 80, color: Colors.white54),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... Thông tin dịch vụ giữ nguyên
                  const SizedBox(height: 24),
                  const Text('Chọn stylist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // ----- Chọn stylist từ Firestore -----
                  StreamBuilder<List<Stylist>>(
                    stream: _firestoreService.getStylists(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final stylists = snapshot.data!;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Stylist>(
                            isExpanded: true,
                            hint: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Chọn stylist của bạn'),
                            ),
                            value: selectedStylist,
                            onChanged: (val) => setState(() => selectedStylist = val),
                            items: stylists.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(s.image),
                                        radius: 18,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildDatePicker(context),
                  const SizedBox(height: 24),
                  _buildTimePicker(context),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isLoading || selectedStylist == null || selectedDate == null || selectedTime == null) 
                        ? null 
                        : () => _confirmBooking(service),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white,)
                        : const Text('Xác nhận đặt lịch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... các hàm _buildDatePicker, _buildTimePicker, _buildSelectBox giữ nguyên
  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn ngày', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) setState(() => selectedDate = picked);
          },
          child: _buildSelectBox(
            icon: Icons.calendar_today,
            text: selectedDate == null
                ? 'Chọn ngày hẹn'
                : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
            isSelected: selectedDate != null,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn giờ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            TimeOfDay? picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
            if (picked != null) setState(() => selectedTime = picked);
          },
          child: _buildSelectBox(
            icon: Icons.access_time,
            text: selectedTime == null
                ? 'Chọn giờ hẹn'
                : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
            isSelected: selectedTime != null,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectBox({required IconData icon, required String text, required bool isSelected}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[300]!, width: isSelected ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 16, color: isSelected ? Colors.black : Colors.grey))),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}