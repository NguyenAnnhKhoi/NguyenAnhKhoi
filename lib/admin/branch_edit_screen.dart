// lib/admin/branch_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';

class BranchEditScreen extends StatefulWidget {
  final Branch? branch; // null = thêm mới

  const BranchEditScreen({super.key, this.branch});

  @override
  State<BranchEditScreen> createState() => _BranchEditScreenState();
}

class _BranchEditScreenState extends State<BranchEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();

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
        name: _nameCtrl.text,
        address: _addressCtrl.text,
        hours: _hoursCtrl.text,
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        image: _imageCtrl.text,
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
        title: Text(_isEditing ? 'Chỉnh sửa Chi nhánh' : 'Thêm Chi nhánh mới'),
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
                    _buildTextFormField(_nameCtrl, 'Tên chi nhánh'),
                    _buildTextFormField(_addressCtrl, 'Địa chỉ'),
                    _buildTextFormField(_hoursCtrl, 'Giờ mở cửa (vd: 8:00 - 22:00)'),
                    _buildTextFormField(_ratingCtrl, 'Đánh giá (vd: 4.5)', keyboardType: TextInputType.number),
                    _buildTextFormField(_latitudeCtrl, 'Vĩ độ (Latitude)', keyboardType: TextInputType.number),
                    _buildTextFormField(_longitudeCtrl, 'Kinh độ (Longitude)', keyboardType: TextInputType.number),
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
        onChanged: (value) {
          if (controller == _imageCtrl) {
            setState(() {});
          }
        },
      ),
    );
  }
}