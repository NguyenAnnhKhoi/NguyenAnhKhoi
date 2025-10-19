// lib/admin/service_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/firestore_service.dart';

class ServiceEditScreen extends StatefulWidget {
  final Service? service; // null nghĩa là thêm mới, có data nghĩa là chỉnh sửa

  const ServiceEditScreen({super.key, this.service});

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();

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
        id: _isEditing ? widget.service!.id : '', // ID sẽ được gán tự động khi thêm mới
        name: _nameCtrl.text,
        price: double.tryParse(_priceCtrl.text) ?? 0.0,
        duration: _durationCtrl.text,
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        image: _imageCtrl.text,
      );

      if (_isEditing) {
        await _firestoreService.updateService(serviceData);
      } else {
        await _firestoreService.addService(serviceData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Cập nhật thành công!' : 'Thêm mới thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi: $e'),
            backgroundColor: Colors.red,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextFormField(_nameCtrl, 'Tên dịch vụ'),
                    _buildTextFormField(_priceCtrl, 'Giá', keyboardType: TextInputType.number),
                    _buildTextFormField(_durationCtrl, 'Thời lượng (vd: 30 phút)'),
                    _buildTextFormField(_ratingCtrl, 'Đánh giá (vd: 4.5)', keyboardType: TextInputType.number),
                    _buildTextFormField(_imageCtrl, 'Link ảnh (URL)'),
                    const SizedBox(height: 20),
                    if (_imageCtrl.text.isNotEmpty)
                      Image.network(
                        _imageCtrl.text,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.error, color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng không để trống';
          }
          return null;
        },
        // Cập nhật ảnh preview khi thay đổi link
        onChanged: (value) {
          if (controller == _imageCtrl) {
            setState(() {});
          }
        },
      ),
    );
  }
}