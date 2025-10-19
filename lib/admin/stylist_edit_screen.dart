// lib/admin/stylist_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/stylist.dart';
import '../services/firestore_service.dart';

class StylistEditScreen extends StatefulWidget {
  final Stylist? stylist; // null = thêm mới

  const StylistEditScreen({super.key, this.stylist});

  @override
  State<StylistEditScreen> createState() => _StylistEditScreenState();
}

class _StylistEditScreenState extends State<StylistEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  bool get _isEditing => widget.stylist != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.stylist!.name;
      _imageCtrl.text = widget.stylist!.image;
      _ratingCtrl.text = widget.stylist!.rating.toString();
      _experienceCtrl.text = widget.stylist!.experience;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _imageCtrl.dispose();
    _ratingCtrl.dispose();
    _experienceCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final stylistData = Stylist(
        id: _isEditing ? widget.stylist!.id : '',
        name: _nameCtrl.text,
        image: _imageCtrl.text,
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        experience: _experienceCtrl.text,
      );

      if (_isEditing) {
        await _firestoreService.updateStylist(stylistData);
      } else {
        await _firestoreService.addStylist(stylistData);
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
        title: Text(_isEditing ? 'Chỉnh sửa Stylist' : 'Thêm Stylist mới'),
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
                    _buildTextFormField(_nameCtrl, 'Tên Stylist'),
                    _buildTextFormField(_experienceCtrl, 'Kinh nghiệm (vd: 5 năm)'),
                    _buildTextFormField(_ratingCtrl, 'Đánh giá (vd: 4.8)', keyboardType: TextInputType.number),
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