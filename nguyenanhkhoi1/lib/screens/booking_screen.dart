import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/stylist.dart';
import '../data/mock_data.dart';

// Ensure mockStylists is imported or defined
// If not present in mock_data.dart, define it here as a temporary fix:
// final List<Stylist> mockStylists = [/* Add Stylist objects here */];

class BookingScreen extends StatefulWidget {
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  Stylist? selectedStylist;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
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
                child: Center(
                  child: Icon(Icons.calendar_month, size: 80, color: Colors.white54),
                ),
              ),
            ),
          ),

          // Nội dung chính
          SliverToBoxAdapter(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ----- Thông tin dịch vụ -----
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              const Icon(Icons.spa, color: Color(0xFF1E3A8A), size: 28),
                              const SizedBox(width: 12),
                              const Text('Dịch vụ đã chọn',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ]),
                            const Divider(height: 24),
                            Text(service.name,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(service.duration,
                                    style: const TextStyle(fontSize: 15, color: Colors.grey)),
                                const SizedBox(width: 24),
                                const Icon(Icons.payment, size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('${service.price.toStringAsFixed(0)}đ',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E3A8A))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ----- Chọn stylist -----
                    const Text('Chọn stylist',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Stylist>(
                          isExpanded: true,
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.person, color: Color(0xFF1E3A8A)),
                                SizedBox(width: 12),
                                Text('Chọn stylist của bạn'),
                              ],
                            ),
                          ),
                          value: selectedStylist,
                          onChanged: (val) => setState(() => selectedStylist = val),
                          items: MockData.stylists.map((s) {
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('⭐ ${s.rating}',
                                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ----- Chọn ngày -----
                    _buildDatePicker(context),

                    const SizedBox(height: 24),

                    // ----- Chọn giờ -----
                    _buildTimePicker(context),

                    const SizedBox(height: 40),

                    // ----- Nút xác nhận -----
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: (selectedStylist != null && selectedDate != null && selectedTime != null)
                            ? () {
                                final newBooking = Booking(
                                  id: MockData.bookings.length + 1,
                                  service: service,
                                  stylist: selectedStylist!,
                                  dateTime: DateTime(
                                    selectedDate!.year,
                                    selectedDate!.month,
                                    selectedDate!.day,
                                    selectedTime!.hour,
                                    selectedTime!.minute,
                                  ),
                                  status: 'Đã đặt',
                                );
                                setState(() => MockData.bookings.add(newBooking));

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: Row(children: const [
                                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                                      SizedBox(width: 12),
                                      Text('Thành công!'),
                                    ]),
                                    content: const Text(
                                        'Đặt lịch thành công! Chúng tôi sẽ gọi xác nhận trong thời gian sớm nhất.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK', style: TextStyle(color: Color(0xFF1E3A8A))),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            : null,
                        child: const Text('Xác nhận đặt lịch',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- widget chọn ngày ---
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

  // --- widget chọn giờ ---
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

  // --- khung chọn ---
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
