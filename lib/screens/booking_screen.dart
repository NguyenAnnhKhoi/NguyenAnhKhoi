// lib/screens/booking_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/stylist.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Service? preSelectedService;
  final Stylist? preSelectedStylist;
  final Branch? preSelectedBranch;

  const BookingScreen({
    super.key,
    this.preSelectedService,
    this.preSelectedStylist,
    this.preSelectedBranch,
  });

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen>
    with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  Service? selectedService;
  Stylist? selectedStylist;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Branch? selectedBranch;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Set pre-selected values if provided
    selectedService = widget.preSelectedService;
    selectedStylist = widget.preSelectedStylist;
    selectedBranch = widget.preSelectedBranch;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _loadUserData();
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
          _phoneController.text =
              data?['phoneNumber'] ?? user.phoneNumber ?? '';
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
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Hàm xác nhận booking - Chuyển đến màn hình xác nhận thanh toán
  Future<void> _confirmBooking(Service service) async {
    // 1. Kiểm tra thông tin
    if (selectedBranch == null ||
        selectedStylist == null ||
        selectedDate == null ||
        selectedTime == null ||
        _nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // 1.5. KIỂM TRA GIỜ MỞ CỬA - Validation cuối cùng trước khi đặt
    if (!selectedBranch!.isTimeWithinOpeningHours(
      selectedTime!.hour,
      selectedTime!.minute,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Ngoài giờ mở cửa',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Chi nhánh ${selectedBranch!.name} chỉ mở cửa từ ${selectedBranch!.openingTimeText} đến ${selectedBranch!.closingTimeText}.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Vui lòng chọn thời gian trong khung giờ hoạt động.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Parse duration từ service
    final serviceDuration = service.duration;
    int durationMinutes = 60; // Mặc định 60 phút

    if (serviceDuration.contains('giờ')) {
      final hours =
          int.tryParse(serviceDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
      durationMinutes = hours * 60;
    } else {
      durationMinutes =
          int.tryParse(serviceDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 60;
    }

    // 2. Kiểm tra stylist có khả dụng không (double-check)
    final isAvailable = await _firestoreService.checkStylistAvailability(
      stylistId: selectedStylist!.id,
      dateTime: DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      ),
      durationMinutes: durationMinutes,
    );

    if (!isAvailable) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stylist đã có lịch hẹn vào thời gian này. Vui lòng chọn thời gian khác.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }

    // 3. Tạo đối tượng Booking tạm thời (chưa lưu vào DB)
    final tempBooking = Booking(
      id: '', // Chưa có ID
      service: service,
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
      paymentMethod: 'Chưa thanh toán', // Sẽ được chọn ở màn hình xác nhận
      status: 'pending', // Pending cho đến khi xác nhận thanh toán
    );

    setState(() => _isLoading = false);

    // 4. Chuyển đến màn hình xác nhận thanh toán
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(booking: tempBooking),
      ),
    );

    // Nếu thanh toán/xác nhận thành công, quay về home
    if (result == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu không có service nhưng có stylist/branch, vẫn hiển thị form để chọn service
    // Chỉ hiển thị error khi không có gì cả
    if (selectedService == null &&
        selectedStylist == null &&
        selectedBranch == null) {
      return Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text('Đặt lịch hẹn'),
          backgroundColor: Color(0xFF0891B2),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Vui lòng chọn dịch vụ hoặc stylist',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
                label: Text('Quay lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0891B2),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Nếu có service thì dùng, không thì build form để chọn
    final service = selectedService;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // SliverAppBar với service title (có thể null)
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.white,
            leading: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Color(0xFF0891B2)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                '📝 Đặt lịch hẹn',
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
          ),

          SliverToBoxAdapter(
            child: Container(
              color: Color(0xFFF8FAFC),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị service info nếu có, không thì hiển thị selector
                    if (service != null) _buildServiceInfo(service),
                    if (service == null) _buildServiceSelector(),
                    SizedBox(height: 28),

                    _buildSectionTitle(
                      '👤 Thông tin khách hàng',
                      Icons.person_outline,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      label: 'Họ và tên',
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 12),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    SizedBox(height: 28),
                    _buildSectionTitle(
                      '📍 Chọn chi nhánh',
                      Icons.business_rounded,
                    ),
                    SizedBox(height: 16),
                    _buildBranchSelector(),

                    SizedBox(height: 28),
                    _buildSectionTitle(
                      '✂️ Chọn stylist',
                      Icons.person_pin_outlined,
                    ),
                    SizedBox(height: 16),
                    // Chỉ build stylist selector nếu có service
                    if (service != null) _buildStylistSelector(service),
                    if (service == null)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Vui lòng chọn dịch vụ trước',
                                style: TextStyle(color: Colors.orange.shade900),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 28),
                    _buildSectionTitle(
                      '⏰ Chọn thời gian',
                      Icons.access_time_outlined,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker(context)),
                        SizedBox(width: 12),
                        Expanded(child: _buildTimePicker(context)),
                      ],
                    ),

                    SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0891B2),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: Color(0xFF0891B2).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading || service == null
                            ? null
                            : () => _confirmBooking(service!),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Đang xử lý...',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_outline, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Xác nhận đặt lịch',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Tất cả các hàm _build... khác giữ nguyên)
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF0891B2).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfo(Service service) {
    return Container(
      padding: EdgeInsets.all(20),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              service.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      service.duration,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  '${service.price.toStringAsFixed(0)}đ',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF0891B2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget để chọn dịch vụ khi chưa có service được chọn sẵn
  Widget _buildServiceSelector() {
    return StreamBuilder<List<Service>>(
      stream: _firestoreService.getServices(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF0891B2)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Không có dịch vụ nào',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }

        final services = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('💇 Chọn dịch vụ', Icons.content_cut),
            SizedBox(height: 16),
            ...services
                .map(
                  (service) => GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedService = service;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedService?.id == service.id
                              ? Color(0xFF0891B2)
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              service.image,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${service.duration} • ${service.price.toStringAsFixed(0)}đ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF0891B2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (selectedService?.id == service.id)
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFF0891B2),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        );
      },
    );
  }

  Widget _buildStylistSelector(Service service) {
    // Kiểm tra đã chọn chi nhánh chưa
    if (selectedBranch == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Vui lòng chọn chi nhánh trước khi chọn stylist',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Sử dụng modal picker giống Quick Booking
    return InkWell(
      onTap: () async {
        final Stylist? picked = await showModalBottomSheet<Stylist>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _StylistPicker(
            firestoreService: _firestoreService,
            selectedBranch: selectedBranch!,
          ),
        );
        if (picked != null) {
          setState(() => selectedStylist = picked);
        }
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedStylist != null
                ? Color(0xFF0891B2)
                : Colors.grey.shade300,
            width: selectedStylist != null ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_outline,
              color: selectedStylist != null
                  ? Color(0xFF0891B2)
                  : Colors.grey.shade400,
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedStylist?.name ?? 'Chọn stylist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selectedStylist != null
                          ? Colors.grey.shade800
                          : Colors.grey.shade500,
                    ),
                  ),
                  if (selectedStylist != null) ...[
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(
                          selectedStylist!.rating.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (selectedStylist!.branchName != null) ...[
                          SizedBox(width: 12),
                          Icon(
                            Icons.business_rounded,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(width: 4),
                          Text(
                            selectedStylist!.branchName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(Duration(days: 1)),
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
      child: _buildSelectBox(
        icon: Icons.calendar_today_rounded,
        text: selectedDate == null
            ? 'Chọn ngày'
            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
        isSelected: selectedDate != null,
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        // Kiểm tra xem đã chọn chi nhánh chưa
        if (selectedBranch == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Vui lòng chọn chi nhánh trước')),
                ],
              ),
              backgroundColor: Colors.orange.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
            ),
          );
          return;
        }

        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: 9, minute: 0),
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

        if (picked != null) {
          // Kiểm tra xem thời gian có nằm trong giờ mở cửa không
          if (selectedBranch != null &&
              !selectedBranch!.isTimeWithinOpeningHours(
                picked.hour,
                picked.minute,
              )) {
            // Hiển thị thông báo lỗi
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Ngoài giờ mở cửa',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Chi nhánh ${selectedBranch!.name} chỉ mở cửa từ ${selectedBranch!.openingTimeText} đến ${selectedBranch!.closingTimeText}.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Vui lòng chọn thời gian trong khung giờ hoạt động.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.all(16),
                  duration: Duration(seconds: 4),
                ),
              );
            }
            return;
          }

          setState(() => selectedTime = picked);
        }
      },
      child: _buildSelectBox(
        icon: Icons.access_time_rounded,
        text: selectedTime == null
            ? 'Chọn giờ'
            : '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
        isSelected: selectedTime != null,
      ),
    );
  }

  Widget _buildSelectBox({
    required IconData icon,
    required String text,
    required bool isSelected,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Color(0xFF0891B2) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFF0891B2) : Colors.grey.shade400,
            size: 28,
          ),
          SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Color(0xFF0891B2) : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF0891B2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFF0891B2), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final Branch? picked = await showModalBottomSheet<Branch>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) =>
                  _BranchPicker(firestoreService: _firestoreService),
            );
            if (picked != null) {
              setState(() {
                selectedBranch = picked;
                // Reset thời gian đã chọn khi đổi chi nhánh
                // Kiểm tra nếu thời gian hiện tại không hợp lệ với chi nhánh mới
                if (selectedTime != null &&
                    !picked.isTimeWithinOpeningHours(
                      selectedTime!.hour,
                      selectedTime!.minute,
                    )) {
                  selectedTime = null;
                  // Thông báo cho user
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Thời gian đã chọn không phù hợp với giờ mở cửa của chi nhánh mới. Vui lòng chọn lại.',
                        ),
                        backgroundColor: Colors.orange.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  });
                }
              });
            }
          },
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedBranch != null
                    ? Color(0xFF0891B2)
                    : Colors.grey.shade300,
                width: selectedBranch != null ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.business_rounded,
                  color: selectedBranch != null
                      ? Color(0xFF0891B2)
                      : Colors.grey.shade400,
                  size: 24,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedBranch?.name ?? 'Chọn chi nhánh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selectedBranch != null
                          ? Colors.grey.shade800
                          : Colors.grey.shade500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        // Hiển thị giờ mở cửa nếu đã chọn chi nhánh
        if (selectedBranch != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFF0891B2),
                ),
                SizedBox(width: 6),
                Text(
                  'Giờ mở cửa: ${selectedBranch!.hours}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ... (Class _BranchPicker giữ nguyên)
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Không có chi nhánh nào."));
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

// Thêm class _StylistPicker
class _StylistPicker extends StatelessWidget {
  final FirestoreService firestoreService;
  final Branch selectedBranch;

  const _StylistPicker({
    required this.firestoreService,
    required this.selectedBranch,
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
                          Icon(
                            Icons.person_off_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
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
                                Icon(
                                  Icons.work_outline,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
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
                                  Icon(
                                    Icons.business_rounded,
                                    size: 14,
                                    color: Colors.blue.shade700,
                                  ),
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
