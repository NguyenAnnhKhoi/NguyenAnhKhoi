// lib/admin/service_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/firestore_service.dart';

class ServiceEditScreen extends StatefulWidget {
  final Service? service;

  const ServiceEditScreen({super.key, this.service});

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  
  bool _isLoading = false;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.service!.name;
      _priceCtrl.text = widget.service!.price.toStringAsFixed(0);
      _durationCtrl.text = widget.service!.duration;
      _ratingCtrl.text = widget.service!.rating.toString();
      _imageCtrl.text = widget.service!.image;
    }
  }
  
  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    _ratingCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final serviceData = Service(
        id: _isEditing ? widget.service!.id : '',
        name: _nameCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        duration: _durationCtrl.text.trim(),
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        image: _imageCtrl.text.trim(),
      );

      if (_isEditing) {
        await _firestoreService.updateService(serviceData);
      } else {
        await _firestoreService.addService(serviceData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Cập nhật dịch vụ thành công!' : 'Thêm dịch vụ mới thành công!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        title: Text(_isEditing ? 'Chỉnh sửa Dịch vụ' : 'Thêm Dịch vụ mới'),
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
                      label: 'Tên dịch vụ',
                      icon: Icons.content_cut_rounded,
                    ),
                    _buildTextFormField(
                      controller: _priceCtrl,
                      label: 'Giá',
                      icon: Icons.attach_money_rounded,
                      hint: 'Ví dụ: 150000',
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      controller: _durationCtrl,
                      label: 'Thời lượng',
                      icon: Icons.schedule_outlined,
                      hint: 'Ví dụ: 30 phút',
                    ),
                    _buildTextFormField(
                      controller: _ratingCtrl,
                      label: 'Đánh giá',
                      icon: Icons.star_outline,
                      hint: 'Ví dụ: 4.5',
                      keyboardType: TextInputType.number,
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
                                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Không thể tải ảnh',
                                    style: TextStyle(color: Colors.grey.shade600),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
          if (controller == _priceCtrl) {
            final price = double.tryParse(value);
            if (price == null || price < 0) {
              return 'Giá phải là số dương';
            }
          }
          if (controller == _ratingCtrl) {
            final rating = double.tryParse(value);
            if (rating == null || rating < 0 || rating > 5) {
              return 'Đánh giá phải từ 0 đến 5';
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