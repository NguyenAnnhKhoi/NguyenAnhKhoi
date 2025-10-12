import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../services/firestore_service.dart';
import '../models/booking.dart';

class QuickBookingScreen extends StatefulWidget {
  const QuickBookingScreen({super.key});

  @override
  State<QuickBookingScreen> createState() => _QuickBookingScreenState();
}

class _QuickBookingScreenState extends State<QuickBookingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Stylist? selectedStylist;
  Service? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isLoading = false;
  
  Future<void> _confirmQuickBooking() async {
    if (selectedStylist == null || selectedService == null || selectedDate == null || selectedTime == null) return;
    
    setState(() => _isLoading = true);

    final newBooking = Booking(
      id: '',
      service: selectedService!,
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
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt lịch thành công!'), backgroundColor: Colors.green),
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
          _stepDot(primary, 1, 'Chọn dịch vụ', _buildSelectService(context, primary)),
          const SizedBox(height: 12),
          _stepDot(primary, 2, 'Chọn ngày, giờ & stylist', _buildSelectDateTime(context, primary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: (_isLoading || selectedService == null || selectedDate == null || selectedTime == null || selectedStylist == null)
                  ? null
                  : _confirmQuickBooking,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('CHỐT GIỜ CẮT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ... các hàm build UI khác ...
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

  Widget _buildSelectService(BuildContext context, Color primary) {
    return _rowButton(
      leading: const Icon(Icons.content_cut, color: Colors.black54),
      text: selectedService?.name ?? 'Chọn dịch vụ',
      onTap: () async {
        final Service? picked = await showModalBottomSheet<Service>(
          context: context,
          builder: (context) => _ServicePicker(initial: selectedService, firestoreService: _firestoreService),
        );
        if (picked != null) setState(() => selectedService = picked);
      },
    );
  }

  Widget _buildSelectDateTime(BuildContext context, Color primary) {
    return Column(children: [
      _rowButton(
        leading: const Icon(Icons.event_outlined, color: Colors.black54),
        text: selectedDate == null ? 'Chọn ngày' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        onTap: () async {
          final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
          if (picked != null) setState(() => selectedDate = picked);
        },
      ),
      const SizedBox(height: 8),
      _rowButton(
        leading: const Icon(Icons.access_time, color: Colors.black54),
        text: selectedTime == null ? 'Chọn giờ' : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
        onTap: () async {
          final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
          if (picked != null) setState(() => selectedTime = picked);
        },
      ),
      const SizedBox(height: 8),
      _rowButton(
        leading: const Icon(Icons.person_outline, color: Colors.black54),
        text: selectedStylist?.name ?? 'Chọn stylist',
        onTap: () async {
          final Stylist? picked = await showModalBottomSheet<Stylist>(
            context: context,
            builder: (context) => _StylistPicker(initial: selectedStylist, firestoreService: _firestoreService),
          );
          if (picked != null) setState(() => selectedStylist = picked);
        },
      ),
    ]);
  }

  Widget _rowButton({required Widget leading, required String text, required VoidCallback onTap}) {
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
          const Icon(Icons.chevron_right),
        ]),
      ),
    );
  }
}

class _ServicePicker extends StatelessWidget {
  final Service? initial;
  final FirestoreService firestoreService;
  const _ServicePicker({this.initial, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 12),
          const Text('Chọn dịch vụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Service>>(
              stream: firestoreService.getServices(),
              builder: (context, snapshot) {
                 if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                 final services = snapshot.data!;
                 return ListView.builder(
                    controller: controller,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return ListTile(
                        leading: CircleAvatar(backgroundImage: NetworkImage(s.image)),
                        title: Text(s.name),
                        trailing: Text('${s.price.toStringAsFixed(0)}đ'),
                        onTap: () => Navigator.pop(context, s),
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
}

class _StylistPicker extends StatelessWidget {
  final Stylist? initial;
  final FirestoreService firestoreService;
  const _StylistPicker({this.initial, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 12),
          const Text('Chọn stylist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Stylist>>(
              stream: firestoreService.getStylists(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final stylists = snapshot.data!;
                return ListView.builder(
                  controller: controller,
                  itemCount: stylists.length,
                  itemBuilder: (context, index) {
                    final st = stylists[index];
                    return ListTile(
                      leading: CircleAvatar(backgroundImage: NetworkImage(st.image)),
                      title: Text(st.name),
                      subtitle: Text('⭐ ${st.rating}'),
                      onTap: () => Navigator.pop(context, st),
                    );
                  },
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}