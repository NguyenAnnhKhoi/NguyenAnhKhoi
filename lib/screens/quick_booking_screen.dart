// lib/screens/quick_booking_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';
import '../models/booking.dart';
import '../services/notification_service.dart';

class QuickBookingScreen extends StatefulWidget {
  const QuickBookingScreen({super.key});

  @override
  State<QuickBookingScreen> createState() => _QuickBookingScreenState();
}

class _QuickBookingScreenState extends State<QuickBookingScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  Stylist? selectedStylist;
  Service? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Branch? selectedBranch;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tự động điền thông tin người dùng nếu đã đăng nhập
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _resetForm() {
    setState(() {
      selectedStylist = null;
      selectedService = null;
      selectedDate = null;
      selectedTime = null;
      selectedBranch = null;
      // Không xóa tên và sđt vì người dùng có thể muốn đặt lại
    });
  }

  Future<void> _confirmQuickBooking() async {
    // Validate form
    if (selectedStylist == null ||
        selectedService == null ||
        selectedDate == null ||
        selectedTime == null ||
        selectedBranch == null ||
        _nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      EasyLoading.showInfo('Vui lòng điền đủ thông tin');
      return;
    }

    await EasyLoading.show(status: 'Đang xử lý...');

    Booking newBooking = Booking(
      id: '', // Sẽ được cập nhật sau
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
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      branchName: selectedBranch!.name,
    );

    try {
      final docRef = await _firestoreService.addBooking(newBooking);
      newBooking = newBooking.copyWith(id: docRef.id);
      await _notificationService.scheduleBookingNotification(newBooking);

      if (mounted) {
        _resetForm();
        EasyLoading.showSuccess('Đặt lịch thành công!\nKiểm tra ở tab Lịch sử.');
      }
    } catch (e) {
      if (mounted) {
        EasyLoading.showError('Lỗi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF1A1A2E);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Đặt lịch nhanh',
            style:
                TextStyle(color: primary, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _stepDot(primary, 1, 'Thông tin của bạn',
              _buildCustomerInfo(context, primary)),
          const SizedBox(height: 12),
          _stepDot(primary, 2, 'Chọn chi nhánh',
              _buildSelectBranch(context, primary)),
          const SizedBox(height: 12),
          _stepDot(primary, 3, 'Chọn dịch vụ',
              _buildSelectService(context, primary)),
          const SizedBox(height: 12),
          _stepDot(primary, 4, 'Chọn thời gian & stylist',
              _buildSelectDateTime(context, primary)),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _confirmQuickBooking,
              child: const Text('XÁC NHẬN ĐẶT LỊCH',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(Color primary, int step, String title, Widget content) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ]),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: primary),
            child: Text('$step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                  color: primary, fontSize: 18, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 12),
        content,
      ]),
    );
  }

  Widget _buildCustomerInfo(BuildContext context, Color primary) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Họ và tên',
            prefixIcon: Icon(Icons.person_outline, color: primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Số điện thoại',
            prefixIcon: Icon(Icons.phone_outlined, color: primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectBranch(BuildContext context, Color primary) {
    return _rowButton(
      leading: const Icon(Icons.business_rounded, color: Colors.black54),
      text: selectedBranch?.name ?? 'Chọn chi nhánh',
      onTap: () async {
        final Branch? picked = await showModalBottomSheet<Branch>(
          context: context,
          builder: (context) => _BranchPicker(firestoreService: _firestoreService),
        );
        if (picked != null) setState(() => selectedBranch = picked);
      },
    );
  }

  Widget _buildSelectService(BuildContext context, Color primary) {
    return _rowButton(
      leading: const Icon(Icons.content_cut, color: Colors.black54),
      text: selectedService?.name ?? 'Chọn dịch vụ',
      onTap: () async {
        final Service? picked = await showModalBottomSheet<Service>(
          context: context,
          builder: (context) =>
              _ServicePicker(firestoreService: _firestoreService),
        );
        if (picked != null) setState(() => selectedService = picked);
      },
    );
  }

  Widget _buildSelectDateTime(BuildContext context, Color primary) {
    return Column(children: [
      _rowButton(
        leading: const Icon(Icons.event_outlined, color: Colors.black54),
        text: selectedDate == null
            ? 'Chọn ngày'
            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        onTap: () async {
          final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 30)));
          if (picked != null) setState(() => selectedDate = picked);
        },
      ),
      const SizedBox(height: 8),
      _rowButton(
        leading: const Icon(Icons.access_time, color: Colors.black54),
        text: selectedTime == null
            ? 'Chọn giờ'
            : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
        onTap: () async {
          final TimeOfDay? picked =
              await showTimePicker(context: context, initialTime: TimeOfDay.now());
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
            builder: (context) =>
                _StylistPicker(firestoreService: _firestoreService),
          );
          if (picked != null) setState(() => selectedStylist = picked);
        },
      ),
    ]);
  }

  Widget _rowButton(
      {required Widget leading,
      required String text,
      required VoidCallback onTap}) {
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

// --- PICKER WIDGETS ---

class _ServicePicker extends StatelessWidget {
  final FirestoreService firestoreService;
  const _ServicePicker({required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 12),
          const Text('Chọn dịch vụ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Service>>(
              stream: firestoreService.getServices(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final services = snapshot.data!;
                return ListView.builder(
                  controller: controller,
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final s = services[index];
                    return ListTile(
                      leading:
                          CircleAvatar(backgroundImage: NetworkImage(s.image)),
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
  final FirestoreService firestoreService;
  const _StylistPicker({required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 12),
          const Text('Chọn stylist',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Stylist>>(
                stream: firestoreService.getStylists(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final stylists = snapshot.data!;
                  return ListView.builder(
                    controller: controller,
                    itemCount: stylists.length,
                    itemBuilder: (context, index) {
                      final st = stylists[index];
                      return ListTile(
                        leading: CircleAvatar(
                            backgroundImage: NetworkImage(st.image)),
                        title: Text(st.name),
                        subtitle: Text('⭐ ${st.rating}'),
                        onTap: () => Navigator.pop(context, st),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class _BranchPicker extends StatelessWidget {
  final FirestoreService firestoreService;
  const _BranchPicker({required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) => Column(
        children: [
          const SizedBox(height: 12),
          const Text('Chọn chi nhánh',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<Branch>>(
                stream: firestoreService.getBranches(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final branches = snapshot.data!;
                  return ListView.builder(
                    controller: controller,
                    itemCount: branches.length,
                    itemBuilder: (context, index) {
                      final branch = branches[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(branch.image),
                        ),
                        title: Text(branch.name),
                        subtitle: Text(branch.address),
                        trailing: Text('⭐ ${branch.rating}'),
                        onTap: () => Navigator.pop(context, branch),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}