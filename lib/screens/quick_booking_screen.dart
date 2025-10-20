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
import '../main.dart';

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
    });
  }

  Future<void> _confirmQuickBooking() async {
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
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      branchName: selectedBranch!.name,
    );

    try {
      final createdBooking = await _firestoreService.addBooking(newBooking);
      await _notificationService.scheduleBookingNotification(createdBooking);

      if (mounted) {
        _resetForm();
        EasyLoading.dismiss();
        // Show success message and navigate back to home
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt lịch thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        // Navigate back to home screen and switch to bookings tab
        Navigator.pop(context);
        // Add a small delay to ensure Navigator.pop is fully completed
        Future.delayed(Duration(milliseconds: 100), () {
          MainScreenState.navigateToBookings();
        });
      }
    } catch (e) {
      if (mounted) {
        EasyLoading.showError('Lỗi: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0891B2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF22D3EE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Hero section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF22D3EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0891B2).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đặt lịch nhanh',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Chọn dịch vụ và thời gian phù hợp',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildFormSection(
                    title: 'Thông tin khách hàng',
                    child: _buildCustomerInfo(),
                  ),
                  const SizedBox(height: 20),
                  _buildFormSection(
                    title: 'Chọn chi nhánh',
                    child: _buildSelectBranch(context),
                  ),
                  const SizedBox(height: 20),
                  _buildFormSection(
                    title: 'Chọn dịch vụ',
                    child: _buildSelectService(context),
                  ),
                  const SizedBox(height: 20),
                  _buildFormSection(
                    title: 'Chọn ngày, giờ & stylist',
                    child: _buildSelectDateTime(context),
                  ),
                  const SizedBox(height: 32),
                  // Enhanced confirm button
                  Container(
                    width: double.infinity,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF22D3EE)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0891B2).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _confirmQuickBooking,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'CHỐT GIỜ CẮT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Họ và tên',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.person_outline, color: const Color(0xFF0891B2)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0891B2), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Số điện thoại',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF0891B2)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0891B2), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectBranch(BuildContext context) {
    return _selectButton(
      icon: Icons.business_rounded,
      text: selectedBranch?.name ?? 'Chọn chi nhánh',
      isSelected: selectedBranch != null,
      onTap: () async {
        final Branch? picked = await showModalBottomSheet<Branch>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => _BranchPicker(firestoreService: _firestoreService),
        );
        if (picked != null) setState(() => selectedBranch = picked);
      },
    );
  }

  Widget _buildSelectService(BuildContext context) {
    return _selectButton(
      icon: Icons.content_cut_rounded,
      text: selectedService?.name ?? 'Chọn dịch vụ',
      isSelected: selectedService != null,
      onTap: () async {
        final Service? picked = await showModalBottomSheet<Service>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => _ServicePicker(firestoreService: _firestoreService),
        );
        if (picked != null) setState(() => selectedService = picked);
      },
    );
  }

  Widget _buildSelectDateTime(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _selectButton(
                icon: Icons.event_outlined,
                text: selectedDate == null
                    ? 'Chọn ngày'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                isSelected: selectedDate != null,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF0891B2),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _selectButton(
                icon: Icons.access_time,
                text: selectedTime == null
                    ? 'Chọn giờ'
                    : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                isSelected: selectedTime != null,
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF0891B2),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) setState(() => selectedTime = picked);
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _selectButton(
          icon: Icons.person_outline,
          text: selectedStylist?.name ?? 'Chọn stylist',
          isSelected: selectedStylist != null,
          onTap: () async {
            final Stylist? picked = await showModalBottomSheet<Stylist>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => _StylistPicker(firestoreService: _firestoreService),
            );
            if (picked != null) setState(() => selectedStylist = picked);
          },
        ),
      ],
    );
  }

  Widget _selectButton({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0891B2).withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0891B2) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0891B2) : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF0891B2) : const Color(0xFF64748B),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isSelected ? const Color(0xFF0891B2) : Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade600, Colors.grey.shade400],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Chọn dịch vụ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Service>>(
                stream: firestoreService.getServices(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final services = snapshot.data!;
                  return ListView.separated(
                    controller: controller,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: services.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade700),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              s.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade800,
                                child: Icon(
                                  Icons.content_cut_rounded,
                                  color: Colors.grey.shade600,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            s.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              '${s.price.toStringAsFixed(0)}đ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          trailing: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          onTap: () => Navigator.pop(context, s),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StylistPicker extends StatelessWidget {
  final FirestoreService firestoreService;
  const _StylistPicker({required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade600, Colors.grey.shade400],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Chọn stylist',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Stylist>>(
                stream: firestoreService.getStylists(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final stylists = snapshot.data!;
                  return ListView.separated(
                    controller: controller,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: stylists.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final st = stylists[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade700),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              st.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade800,
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.grey.shade600,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            st.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Icon(Icons.star, size: 16, color: Colors.amber),
                              SizedBox(width: 4),
                              Text(
                                st.rating.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          onTap: () => Navigator.pop(context, st),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BranchPicker extends StatelessWidget {
  final FirestoreService firestoreService;
  const _BranchPicker({required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) => Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 50,
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey.shade600, Colors.grey.shade400],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Chọn chi nhánh',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Branch>>(
                stream: firestoreService.getBranches(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  final branches = snapshot.data!;
                  return ListView.separated(
                    controller: controller,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: branches.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final branch = branches[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D2D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade700),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              branch.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade800,
                                child: Icon(
                                  Icons.business_rounded,
                                  color: Colors.grey.shade600,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            branch.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Text(
                                branch.address,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    branch.rating.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          onTap: () => Navigator.pop(context, branch),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}