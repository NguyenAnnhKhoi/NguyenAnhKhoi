import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/service.dart';
import '../models/stylist.dart';

class QuickBookingScreen extends StatefulWidget {
  const QuickBookingScreen({super.key});

  @override
  State<QuickBookingScreen> createState() => _QuickBookingScreenState();
}

class _QuickBookingScreenState extends State<QuickBookingScreen> {
  Stylist? selectedStylist;
  Service? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF1E3A8A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Đặt lịch giữ chỗ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          
          _stepDot(primary, 1, 'Chọn salon', _buildSelectSalon(context, primary)),
          const SizedBox(height: 12),
          _stepDot(primary, 2, 'Chọn dịch vụ', _buildSelectService(context, primary)),
          const SizedBox(height: 12),
          _stepDot(primary, 3, 'Chọn ngày, giờ & stylist', _buildSelectDateTime(context, primary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: (selectedService != null && selectedDate != null && selectedTime != null)
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đặt lịch tạm thời thành công. Chúng tôi sẽ liên hệ xác nhận.')),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('CHỐT GIỜ CẮT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(Color primary, int step, String title, Widget content) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
      ]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 16, height: 16, decoration: BoxDecoration(shape: BoxShape.circle, color: primary)),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          content,
        ]),
      ),
    );
  }

  Widget _buildSelectSalon(BuildContext context, Color primary) {
    return _rowButton(
      leading: const Icon(Icons.store_mall_directory_outlined, color: Colors.black54),
      text: 'Xem tất cả salon',
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildSelectService(BuildContext context, Color primary) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _rowButton(
        leading: const Icon(Icons.content_cut, color: Colors.black54),
        text: selectedService?.name ?? 'Xem tất cả dịch vụ hấp dẫn',
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final Service? picked = await showModalBottomSheet<Service>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => _ServicePicker(initial: selectedService),
          );
          if (picked != null) setState(() => selectedService = picked);
        },
      ),
    ]);
  }

  Widget _buildSelectDateTime(BuildContext context, Color primary) {
    return Column(children: [
      _rowButton(
        leading: const Icon(Icons.event_outlined, color: Colors.black54),
        text: selectedDate == null
            ? 'Hôm nay'
            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
          );
          if (picked != null) setState(() => selectedDate = picked);
        },
      ),
      const SizedBox(height: 8),
      _rowButton(
        leading: const Icon(Icons.access_time, color: Colors.black54),
        text: selectedTime == null ? 'Chọn giờ' : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
          if (picked != null) setState(() => selectedTime = picked);
        },
      ),
      const SizedBox(height: 8),
      _rowButton(
        leading: const Icon(Icons.person_outline, color: Colors.black54),
        text: selectedStylist?.name ?? 'Chọn stylist',
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final Stylist? picked = await showModalBottomSheet<Stylist>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => _StylistPicker(initial: selectedStylist),
          );
          if (picked != null) setState(() => selectedStylist = picked);
        },
      ),
    ]);
  }

  Widget _rowButton({required Widget leading, required String text, required Widget trailing, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(children: [
          leading,
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          trailing,
        ]),
      ),
    );
  }
}

class _ServicePicker extends StatelessWidget {
  final Service? initial;
  const _ServicePicker({this.initial});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 12),
          const Text('Chọn dịch vụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: MockData.services.length,
              itemBuilder: (context, index) {
                final s = MockData.services[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(s.image)),
                  title: Text(s.name),
                  subtitle: Text(s.duration),
                  trailing: Text('${s.price.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.w700)),
                  selected: initial?.id == s.id,
                  onTap: () => Navigator.pop(context, s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StylistPicker extends StatelessWidget {
  final Stylist? initial;
  const _StylistPicker({this.initial});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 12),
          const Text('Chọn stylist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: MockData.stylists.length,
              itemBuilder: (context, index) {
                final st = MockData.stylists[index];
                return ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(st.image)),
                  title: Text(st.name),
                  subtitle: Text('⭐ ${st.rating} · ${st.experience}'),
                  selected: initial?.id == st.id,
                  onTap: () => Navigator.pop(context, st),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


