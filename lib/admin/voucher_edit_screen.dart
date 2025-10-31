// lib/admin/voucher_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/voucher.dart';

class VoucherEditScreen extends StatefulWidget {
  final Voucher? voucher; // null nếu tạo mới

  const VoucherEditScreen({super.key, this.voucher});

  @override
  State<VoucherEditScreen> createState() => _VoucherEditScreenState();
}

class _VoucherEditScreenState extends State<VoucherEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxUsesController = TextEditingController();
  
  VoucherType _selectedType = VoucherType.percentage;
  VoucherCondition _selectedCondition = VoucherCondition.all;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _isForNewUser = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.voucher != null) {
      // Load dữ liệu voucher cũ
      final v = widget.voucher!;
      _codeController.text = v.code;
      _titleController.text = v.title;
      _descriptionController.text = v.description;
      _valueController.text = v.value.toString();
      _minAmountController.text = v.minAmount?.toString() ?? '';
      _maxUsesController.text = v.maxUses == -1 ? '-1' : v.maxUses.toString();
      _selectedType = v.type;
      _selectedCondition = v.condition;
      _startDate = v.startDate;
      _endDate = v.endDate;
      _isActive = v.isActive;
      _isForNewUser = v.isForNewUser;
    } else {
      // Mặc định cho voucher mới
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 30));
      _maxUsesController.text = '-1'; // Không giới hạn
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _minAmountController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  Future<void> _saveVoucher() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thời gian bắt đầu và kết thúc')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final voucher = Voucher(
        id: widget.voucher?.id ?? '',
        code: _codeController.text.trim().toUpperCase(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        condition: _selectedCondition,
        value: double.parse(_valueController.text),
        minAmount: _minAmountController.text.isEmpty 
            ? null 
            : double.parse(_minAmountController.text),
        startDate: _startDate!,
        endDate: _endDate!,
        maxUses: int.parse(_maxUsesController.text),
        currentUses: widget.voucher?.currentUses ?? 0,
        isActive: _isActive,
        isForNewUser: _isForNewUser,
      );

      final db = FirebaseFirestore.instance;
      if (widget.voucher == null) {
        // Tạo mới
        await db.collection('vouchers').add(voucher.toJson());
      } else {
        // Cập nhật
        await db.collection('vouchers').doc(widget.voucher!.id).update(voucher.toJson());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.voucher == null ? 'Tạo voucher thành công!' : 'Cập nhật voucher thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteVoucher() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa voucher này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.voucher != null) {
      try {
        await FirebaseFirestore.instance
            .collection('vouchers')
            .doc(widget.voucher!.id)
            .delete();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa voucher'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.voucher == null ? 'Tạo voucher mới' : 'Chỉnh sửa voucher'),
        backgroundColor: const Color(0xFF0891B2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.voucher != null)
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              onPressed: _deleteVoucher,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(
              title: 'Thông tin cơ bản',
              icon: Icons.info_outline_rounded,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Mã voucher *',
                    hintText: 'VD: SUMMER2024',
                    prefixIcon: const Icon(Icons.qr_code_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã voucher';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Tiêu đề *',
                    hintText: 'VD: Giảm giá mùa hè',
                    prefixIcon: const Icon(Icons.title_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Mô tả *',
                    hintText: 'Mô tả chi tiết về voucher',
                    prefixIcon: const Icon(Icons.description_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Loại giảm giá',
              icon: Icons.discount_rounded,
              children: [
                DropdownButtonFormField<VoucherType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Loại voucher',
                    prefixIcon: const Icon(Icons.style_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: VoucherType.percentage,
                      child: Text('Giảm theo phần trăm (%)'),
                    ),
                    DropdownMenuItem(
                      value: VoucherType.fixed,
                      child: Text('Giảm số tiền cố định (đ)'),
                    ),
                    DropdownMenuItem(
                      value: VoucherType.freeService,
                      child: Text('Miễn phí dịch vụ'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valueController,
                  decoration: InputDecoration(
                    labelText: _selectedType == VoucherType.percentage 
                        ? 'Giá trị giảm (%) *' 
                        : 'Giá trị giảm (đ) *',
                    hintText: _selectedType == VoucherType.percentage ? 'VD: 20' : 'VD: 50000',
                    prefixIcon: Icon(_selectedType == VoucherType.percentage 
                        ? Icons.percent_rounded 
                        : Icons.attach_money_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập giá trị';
                    }
                    final num = double.tryParse(value);
                    if (num == null || num <= 0) {
                      return 'Giá trị phải lớn hơn 0';
                    }
                    if (_selectedType == VoucherType.percentage && num > 100) {
                      return 'Phần trăm không được vượt quá 100';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Điều kiện áp dụng',
              icon: Icons.rule_rounded,
              children: [
                DropdownButtonFormField<VoucherCondition>(
                  value: _selectedCondition,
                  decoration: InputDecoration(
                    labelText: 'Điều kiện',
                    prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: VoucherCondition.all,
                      child: Text('Áp dụng cho tất cả'),
                    ),
                    DropdownMenuItem(
                      value: VoucherCondition.minAmount,
                      child: Text('Yêu cầu số tiền tối thiểu'),
                    ),
                    DropdownMenuItem(
                      value: VoucherCondition.firstBooking,
                      child: Text('Chỉ cho lần đặt đầu tiên'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCondition = value);
                    }
                  },
                ),
                if (_selectedCondition == VoucherCondition.minAmount) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _minAmountController,
                    decoration: InputDecoration(
                      labelText: 'Số tiền tối thiểu (đ)',
                      hintText: 'VD: 100000',
                      prefixIcon: const Icon(Icons.money_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_selectedCondition == VoucherCondition.minAmount &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Vui lòng nhập số tiền tối thiểu';
                      }
                      return null;
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Thời gian & giới hạn',
              icon: Icons.access_time_rounded,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_rounded, color: Color(0xFF0891B2)),
                  title: const Text('Ngày bắt đầu'),
                  subtitle: Text(
                    _startDate == null 
                        ? 'Chưa chọn' 
                        : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_rounded, color: Color(0xFFFF6B9D)),
                  title: const Text('Ngày kết thúc'),
                  subtitle: Text(
                    _endDate == null 
                        ? 'Chưa chọn' 
                        : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: _startDate ?? DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _endDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxUsesController,
                  decoration: InputDecoration(
                    labelText: 'Giới hạn sử dụng',
                    hintText: 'Nhập -1 để không giới hạn',
                    prefixIcon: const Icon(Icons.people_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    helperText: 'Số lần voucher có thể được sử dụng (-1 = không giới hạn)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập giới hạn';
                    }
                    final num = int.tryParse(value);
                    if (num == null || num < -1) {
                      return 'Giá trị phải >= -1';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              title: 'Cài đặt',
              icon: Icons.settings_rounded,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Kích hoạt voucher'),
                  subtitle: const Text('Cho phép người dùng sử dụng voucher này'),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: const Color(0xFF0891B2),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Chỉ dành cho khách hàng mới'),
                  subtitle: const Text('Voucher chỉ áp dụng cho người dùng mới'),
                  value: _isForNewUser,
                  onChanged: (value) => setState(() => _isForNewUser = value),
                  activeColor: const Color(0xFF0891B2),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveVoucher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.voucher == null ? 'Tạo voucher' : 'Cập nhật voucher',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0891B2), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
