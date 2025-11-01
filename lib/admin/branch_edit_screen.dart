// lib/admin/branch_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';

class BranchEditScreen extends StatefulWidget {
  final Branch? branch;

  const BranchEditScreen({super.key, this.branch});

  @override
  State<BranchEditScreen> createState() => _BranchEditScreenState();
}

class _BranchEditScreenState extends State<BranchEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();

  bool _isLoading = false;

  bool get _isEditing => widget.branch != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.branch!.name;
      _addressCtrl.text = widget.branch!.address;
      _hoursCtrl.text = widget.branch!.hours;
      _ratingCtrl.text = widget.branch!.rating.toString();
      _imageCtrl.text = widget.branch!.image;
      _latitudeCtrl.text = widget.branch!.latitude.toString();
      _longitudeCtrl.text = widget.branch!.longitude.toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _hoursCtrl.dispose();
    _ratingCtrl.dispose();
    _imageCtrl.dispose();
    _latitudeCtrl.dispose();
    _longitudeCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final branchData = Branch(
        id: _isEditing ? widget.branch!.id : '',
        name: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        hours: _hoursCtrl.text.trim(),
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        image: _imageCtrl.text.trim(),
        latitude: double.tryParse(_latitudeCtrl.text) ?? 0.0,
        longitude: double.tryParse(_longitudeCtrl.text) ?? 0.0,
      );

      if (_isEditing) {
        await _firestoreService.updateBranch(branchData);
      } else {
        await _firestoreService.addBranch(branchData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Cập nhật chi nhánh thành công!'
                  : 'Thêm chi nhánh mới thành công!',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa Chi nhánh' : 'Thêm Chi nhánh mới'),
        backgroundColor: Color(0xFF0891B2),
        elevation: 0,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: _saveForm,
              tooltip: 'Lưu',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextFormField(
                      controller: _nameCtrl,
                      label: 'Tên chi nhánh',
                      icon: Icons.storefront_rounded,
                    ),
                    _buildTextFormField(
                      controller: _addressCtrl,
                      label: 'Địa chỉ',
                      icon: Icons.location_on_outlined,
                    ),
                    _buildTextFormField(
                      controller: _hoursCtrl,
                      label: 'Giờ mở cửa',
                      icon: Icons.access_time_outlined,
                      hint: 'Ví dụ: 8:00 - 22:00',
                    ),
                    _buildTextFormField(
                      controller: _ratingCtrl,
                      label: 'Đánh giá',
                      icon: Icons.star_outline,
                      hint: 'Ví dụ: 4.5',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _latitudeCtrl,
                      label: 'Vĩ độ (Latitude)',
                      icon: Icons.my_location_outlined,
                      hint: 'Ví dụ: 10.762622',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                    _buildTextFormField(
                      controller: _longitudeCtrl,
                      label: 'Kinh độ (Longitude)',
                      icon: Icons.place_outlined,
                      hint: 'Ví dụ: 106.660172',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                    ),
                    _buildTextFormField(
                      controller: _imageCtrl,
                      label: 'Link ảnh (URL)',
                      icon: Icons.image_outlined,
                      hint: 'https://example.com/image.jpg',
                    ),
                    const SizedBox(height: 24),
                    if (_imageCtrl.text.isNotEmpty) ...[
                      Text(
                        'Xem trước ảnh:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _imageCtrl.text,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Không thể tải ảnh',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveForm,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(
                          _isEditing ? 'Cập nhật' : 'Thêm mới',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0891B2),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Color(0xFF0891B2)),
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
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng không để trống';
          }
          if (controller == _ratingCtrl) {
            final rating = double.tryParse(value);
            if (rating == null || rating < 0 || rating > 5) {
              return 'Đánh giá phải từ 0 đến 5';
            }
          }
          if (controller == _latitudeCtrl) {
            final lat = double.tryParse(value);
            if (lat == null || lat < -90 || lat > 90) {
              return 'Vĩ độ phải từ -90 đến 90';
            }
          }
          if (controller == _longitudeCtrl) {
            final lng = double.tryParse(value);
            if (lng == null || lng < -180 || lng > 180) {
              return 'Kinh độ phải từ -180 đến 180';
            }
          }
          return null;
        },
        onChanged: (value) {
          if (controller == _imageCtrl) {
            setState(() {});
          }
        },
      ),
    );
  }
}
