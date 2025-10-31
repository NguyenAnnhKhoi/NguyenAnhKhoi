// lib/screens/quick_booking_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';
import '../models/booking.dart';
import 'booking_confirmation_screen.dart';

class QuickBookingScreen extends StatefulWidget {
  final Branch? initialBranch;

  const QuickBookingScreen({super.key, this.initialBranch});

  @override
  State<QuickBookingScreen> createState() => _QuickBookingScreenState();
}

class _QuickBookingScreenState extends State<QuickBookingScreen> {
  final FirestoreService _firestoreService = FirestoreService();

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
    _loadUserData();
    if (widget.initialBranch != null) {
      selectedBranch = widget.initialBranch;
    }
  }
  
  // Load user data from Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Set name from Firebase Auth first
      _nameController.text = user.displayName ?? '';
      
      try {
        // Try to get phone number from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data();
          // Use Firestore phone number if available, otherwise use Firebase Auth
          _phoneController.text = data?['phoneNumber'] ?? user.phoneNumber ?? '';
          // Also update name from Firestore if available
          if (data?['displayName'] != null) {
            _nameController.text = data!['displayName'];
          }
        } else {
          // Fallback to Firebase Auth phone number
          _phoneController.text = user.phoneNumber ?? '';
        }
      } catch (e) {
        print('Error loading user data: $e');
        // Fallback to Firebase Auth phone number
        _phoneController.text = user.phoneNumber ?? '';
      }
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
      // Không reset tên và sđt
    });
  }

  // --- HÀM _confirmQuickBooking ĐƯỢC VIẾT LẠI ---
  Future<void> _confirmQuickBooking() async {
    // 1. Kiểm tra
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

    // 2. Tạo Booking object tạm thời (chưa lưu vào DB)
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
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      branchName: selectedBranch!.name,
      paymentMethod: 'vietqr', // Luôn dùng VietQR
      status: 'pending', // Chờ thanh toán
    );

    // 3. Chuyển đến màn hình xác nhận booking với voucher
    if (!mounted) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(booking: newBooking),
      ),
    );

    // 4. Nếu thanh toán thành công, reset form
    if (result == true && mounted) {
      _resetForm();
      Navigator.pop(context); // Quay lại màn hình trước
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // ... (SliverAppBar giữ nguyên) ...
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF0891B2),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Đặt lịch nhanh',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0891B2),
                      Color(0xFF06B6D4),
                      Color(0xFF22D3EE),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.flash_on_rounded,
                    size: 60,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildStepCard(
                    step: 1,
                    title: 'Thông tin của bạn',
                    icon: Icons.person_outline,
                    child: _buildCustomerInfo(),
                  ),
                  SizedBox(height: 16),
                  _buildStepCard(
                    step: 2,
                    title: 'Chọn chi nhánh',
                    icon: Icons.business_rounded,
                    child: _buildSelectBranch(context),
                  ),
                  SizedBox(height: 16),
                  _buildStepCard(
                    step: 3,
                    title: 'Chọn dịch vụ',
                    icon: Icons.content_cut_rounded,
                    child: _buildSelectService(context),
                  ),
                  SizedBox(height: 16),
                  _buildStepCard(
                    step: 4,
                    title: 'Chọn thời gian & stylist',
                    icon: Icons.access_time_rounded,
                    child: _buildSelectDateTime(context),
                  ),
                  SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0891B2),
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: Color(0xFF0891B2).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _confirmQuickBooking,
                      icon: Icon(Icons.check_circle_outline, size: 24),
                      label: Text(
                        'XÁC NHẬN ĐẶT LỊCH',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Tất cả các hàm _build... và _selectButton còn lại giữ nguyên)
  Widget _buildStepCard({
    required int step,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Icon(icon, color: Color(0xFF0891B2), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
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
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Họ và tên',
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF0891B2)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFF0891B2), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Số điện thoại',
            prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFF0891B2)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xFF0891B2), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
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
            // Kiểm tra đã chọn chi nhánh chưa
            if (selectedBranch == null) {
              EasyLoading.showInfo('Vui lòng chọn chi nhánh trước');
              return;
            }
            
            final Stylist? picked = await showModalBottomSheet<Stylist>(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => _StylistPicker(
                firestoreService: _firestoreService,
                selectedBranch: selectedBranch!, // Truyền branch đã chọn
              ),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Color(0xFF0891B2) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFF0891B2) : Colors.grey.shade500,
              size: 22,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.grey.shade800 : Colors.grey.shade600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ... (Các class _ServicePicker, _StylistPicker, _BranchPicker giữ nguyên)
// --- PICKER WIDGETS ---

class _ServicePicker extends StatelessWidget {
  final FirestoreService firestoreService;
  const _ServicePicker({required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Chọn dịch vụ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.grey.shade800,
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
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            s.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          s.name,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${s.price.toStringAsFixed(0)}đ',
                          style: TextStyle(
                            color: Color(0xFF0891B2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF0891B2),
                        ),
                        onTap: () => Navigator.pop(context, s),
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
  final Branch selectedBranch; // Thêm tham số selectedBranch
  
  const _StylistPicker({
    required this.firestoreService,
    required this.selectedBranch, // Required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Chọn stylist',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Chi nhánh: ${selectedBranch.name}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Stylist>>(
                stream: firestoreService.getStylists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  
                  if (!snapshot.hasData) {
                    return Center(child: Text('Không có dữ liệu'));
                  }
                  
                  // Lọc stylists theo branch đã chọn
                  var stylists = snapshot.data!
                      .where((s) => s.branchId == selectedBranch.id)
                      .toList();
                  
                  if (stylists.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Không có stylist nào\ntại chi nhánh này',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.separated(
                    controller: controller,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    itemCount: stylists.length,
                    separatorBuilder: (context, index) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final st = stylists[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            st.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          st.name,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, size: 16, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  st.rating.toString(),
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.work_outline, size: 16, color: Colors.grey.shade600),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    st.experience,
                                    style: TextStyle(fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            if (st.branchName != null) ...[
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.business_rounded, size: 14, color: Colors.blue.shade700),
                                  SizedBox(width: 4),
                                  Text(
                                    st.branchName!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF0891B2),
                        ),
                        onTap: () => Navigator.pop(context, st),
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
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Chọn chi nhánh',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.grey.shade800,
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
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            branch.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          branch.name,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              branch.address,
                              style: TextStyle(fontSize: 12),
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
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Color(0xFF0891B2),
                        ),
                        onTap: () => Navigator.pop(context, branch),
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