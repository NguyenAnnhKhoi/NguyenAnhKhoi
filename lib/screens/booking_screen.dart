// lib/screens/booking_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/stylist.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart'; // THÊM IMPORT
import 'payment_screen.dart'; // THÊM IMPORT

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  BookingScreenState createState() => BookingScreenState();
}

class BookingScreenState extends State<BookingScreen> with TickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService(); // THÊM MỚI
  Stylist? selectedStylist;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Branch? selectedBranch;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  late AnimationController _controller;
  bool _isLoading = false;

  // --- THÊM MỚI: Trạng thái thanh toán ---
  String _paymentMethod = 'Tại quầy'; // 'Tại quầy' hoặc 'Online'
  // ------------------------------------

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  // --- HÀM _confirmBooking ĐƯỢC VIẾT LẠI ---
  Future<void> _confirmBooking(Service service) async {
    // 1. Kiểm tra thông tin
    if (selectedBranch == null || selectedStylist == null || selectedDate == null || selectedTime == null || 
        _nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);

    // 2. Tạo đối tượng Booking trong bộ nhớ
    final newBooking = Booking(
      id: '', // ID sẽ được tạo bởi Firestore
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
      paymentMethod: _paymentMethod, // <-- Gán phương thức
      status: _paymentMethod == 'Online' ? 'Đã xác nhận' : 'Chờ xác nhận', // <-- Gán trạng thái
    );
    
    // 3. Xử lý dựa trên phương thức thanh toán
    if (_paymentMethod == 'Online') {
      // Chuyển đến màn hình thanh toán
      setState(() => _isLoading = false);
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(booking: newBooking),
        ),
      );
      
      // Nếu thanh toán thành công, thoát về màn hình chính
      if (result == true && mounted) {
        Navigator.pop(context);
      }
      // Nếu result == null (user bấm back), không làm gì, ở lại màn hình booking
    } else {
      // Thanh toán tại quầy (luồng cũ)
      try {
        final docRef = await _firestoreService.addBooking(newBooking);
        final bookingWithId = newBooking.copyWith(id: docRef.id);
        await _notificationService.scheduleBookingNotification(bookingWithId);

        if(mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: EdgeInsets.all(32),
                // ... (Nội dung Dialog thành công giữ nguyên như cũ) ...
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xFF0891B2).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF0891B2),
                        size: 64,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Thành công!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0891B2),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Đặt lịch thành công!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Chúng tôi sẽ gửi xác nhận trong thời gian sớm nhất.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng dialog
                          Navigator.of(context).pop(); // Đóng BookingScreen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0891B2),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Color(0xFF0891B2).withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Hoàn tất',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      } catch(e) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if(mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)!.settings.arguments as Service;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ... (SliverAppBar giữ nguyên)
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
                    _buildServiceInfo(service),
                    SizedBox(height: 28),
                    
                    _buildSectionTitle('👤 Thông tin khách hàng', Icons.person_outline),
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
                    _buildSectionTitle('📍 Chọn chi nhánh', Icons.business_rounded),
                    SizedBox(height: 16),
                    _buildBranchSelector(),
                    
                    SizedBox(height: 28),
                    _buildSectionTitle('✂️ Chọn stylist', Icons.person_pin_outlined),
                    SizedBox(height: 16),
                    _buildStylistSelector(),
                    
                    SizedBox(height: 28),
                    _buildSectionTitle('⏰ Chọn thời gian', Icons.access_time_outlined),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildDatePicker(context)),
                        SizedBox(width: 12),
                        Expanded(child: _buildTimePicker(context)),
                      ],
                    ),

                    // --- THÊM PHẦN CHỌN THANH TOÁN ---
                    SizedBox(height: 28),
                    _buildSectionTitle('💳 Thanh toán', Icons.payment_rounded),
                    SizedBox(height: 16),
                    _buildPaymentSelector(),
                    // ------------------------------------
                    
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
                        onPressed: _isLoading ? null : () => _confirmBooking(service),
                        child: _isLoading 
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Text(
                      service.duration,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
  
  Widget _buildStylistSelector() {
    return StreamBuilder<List<Stylist>>(
      stream: _firestoreService.getStylists(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final stylists = snapshot.data!;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedStylist != null ? Color(0xFF0891B2) : Colors.grey.shade300,
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Stylist>(
              isExpanded: true,
              hint: Text('Chọn stylist của bạn'),
              value: selectedStylist,
              onChanged: (val) => setState(() => selectedStylist = val),
              items: stylists.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          s.image,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, size: 14, color: Colors.amber),
                                SizedBox(width: 4),
                                Text(
                                  s.rating.toString(),
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
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
        if (picked != null) setState(() => selectedTime = picked);
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
    return InkWell(
      onTap: () async {
        final Branch? picked = await showModalBottomSheet<Branch>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _BranchPicker(
            firestoreService: _firestoreService,
          ),
        );
        if (picked != null) setState(() => selectedBranch = picked);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedBranch != null ? Color(0xFF0891B2) : Colors.grey.shade300,
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
              color: selectedBranch != null ? Color(0xFF0891B2) : Colors.grey.shade400,
              size: 24,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                selectedBranch?.name ?? 'Chọn chi nhánh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: selectedBranch != null ? Colors.grey.shade800 : Colors.grey.shade500,
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
    );
  }

  // --- HÀM WIDGET MỚI ---
  Widget _buildPaymentSelector() {
    return SegmentedButton<String>(
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white,
        selectedBackgroundColor: Color(0xFF0891B2).withOpacity(0.1),
        selectedForegroundColor: Color(0xFF0891B2),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      segments: const [
        ButtonSegment<String>(
          value: 'Tại quầy',
          label: Text('Tại quầy', style: TextStyle(fontSize: 14)),
          icon: Icon(Icons.storefront_rounded, size: 20),
        ),
        ButtonSegment<String>(
          value: 'Online',
          label: Text('VietQR', style: TextStyle(fontSize: 14)),
          icon: Icon(Icons.qr_code_scanner_rounded, size: 20),
        ),
      ],
      selected: {_paymentMethod},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _paymentMethod = newSelection.first;
        });
      },
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