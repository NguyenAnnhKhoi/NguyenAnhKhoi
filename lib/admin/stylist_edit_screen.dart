// lib/admin/stylist_edit_screen.dart
import 'package:flutter/material.dart';
import '../models/stylist.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';

class StylistEditScreen extends StatefulWidget {
  final Stylist? stylist;

  const StylistEditScreen({super.key, this.stylist});

  @override
  State<StylistEditScreen> createState() => _StylistEditScreenState();
}

class _StylistEditScreenState extends State<StylistEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  final _nameCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();

  String? _selectedBranchId; // Lưu ID của chi nhánh được chọn
  bool _isLoading = false;

  bool get _isEditing => widget.stylist != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.stylist!.name;
      _imageCtrl.text = widget.stylist!.image;
      _ratingCtrl.text = widget.stylist!.rating.toString();
      _experienceCtrl.text = widget.stylist!.experience;
      _selectedBranchId = widget.stylist!.branchId; // Lưu branchId
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

    // Kiểm tra đã chọn chi nhánh chưa
    if (_selectedBranchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn chi nhánh'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Lấy thông tin branch từ Firestore
      final branchDoc = await _firestoreService.getBranches().first;
      final selectedBranch = branchDoc.firstWhere(
        (b) => b.id == _selectedBranchId,
      );

      final stylistData = Stylist(
        id: _isEditing ? widget.stylist!.id : '',
        name: _nameCtrl.text,
        image: _imageCtrl.text,
        rating: double.tryParse(_ratingCtrl.text) ?? 0.0,
        experience: _experienceCtrl.text,
        branchId: selectedBranch.id,
        branchName: selectedBranch.name,
      );

      if (_isEditing) {
        await _firestoreService.updateStylist(stylistData);
      } else {
        await _firestoreService.addStylist(stylistData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Cập nhật stylist thành công!'
                  : 'Thêm stylist mới thành công!',
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
        title: Text(_isEditing ? 'Chỉnh sửa Stylist' : 'Thêm Stylist mới'),
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
          : StreamBuilder<List<Branch>>(
              stream: _firestoreService.getBranches(),
              builder: (context, branchSnapshot) {
                if (branchSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final branches = branchSnapshot.data ?? [];

                // Tìm Branch object từ _selectedBranchId
                Branch? selectedBranch;
                if (_selectedBranchId != null) {
                  try {
                    selectedBranch = branches.firstWhere(
                      (b) => b.id == _selectedBranchId,
                    );
                  } catch (e) {
                    // Branch không tồn tại, reset về null
                    _selectedBranchId = null;
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTextFormField(
                          controller: _nameCtrl,
                          label: 'Tên Stylist',
                          icon: Icons.person_outline,
                        ),
                        _buildTextFormField(
                          controller: _experienceCtrl,
                          label: 'Kinh nghiệm',
                          icon: Icons.work_outline,
                          hint: 'Ví dụ: 5 năm',
                        ),
                        _buildTextFormField(
                          controller: _ratingCtrl,
                          label: 'Đánh giá',
                          icon: Icons.star_outline,
                          hint: 'Ví dụ: 4.8',
                          keyboardType: TextInputType.number,
                        ),

                        // Dropdown chọn chi nhánh
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: DropdownButtonFormField<Branch>(
                            value:
                                selectedBranch, // Sử dụng selectedBranch từ scope
                            decoration: InputDecoration(
                              labelText: 'Chi nhánh',
                              prefixIcon: const Icon(
                                Icons.store_outlined,
                                color: Color(0xFF0891B2),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0891B2),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            items: branches.map((branch) {
                              return DropdownMenuItem<Branch>(
                                value: branch,
                                child: Text(branch.name),
                              );
                            }).toList(),
                            onChanged: (Branch? value) {
                              setState(() {
                                _selectedBranchId =
                                    value?.id; // Lưu ID thay vì object
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Vui lòng chọn chi nhánh';
                              }
                              return null;
                            },
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
                );
              },
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
