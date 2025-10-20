// lib/screens/admin/manage_stylists_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/stylist.dart';

class ManageStylistsScreen extends StatefulWidget {
  const ManageStylistsScreen({super.key});

  @override
  State<ManageStylistsScreen> createState() => _ManageStylistsScreenState();
}

class _ManageStylistsScreenState extends State<ManageStylistsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();
  final _ratingController = TextEditingController();
  final _experienceController = TextEditingController();
  
  bool _isLoading = false;
  Stylist? _editingStylist;

  @override
  void dispose() {
    _nameController.dispose();
    _imageController.dispose();
    _ratingController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateStylist() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final stylistData = {
        'name': _nameController.text.trim(),
        'image': _imageController.text.trim(),
        'rating': double.parse(_ratingController.text.trim()),
        'experience': _experienceController.text.trim(),
      };

      if (_editingStylist != null) {
        await _firestore.collection('stylists').doc(_editingStylist!.id).update(stylistData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật stylist thành công!')),
        );
      } else {
        await _firestore.collection('stylists').add(stylistData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm stylist thành công!')),
        );
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _imageController.clear();
    _ratingController.clear();
    _experienceController.clear();
    _editingStylist = null;
  }

  void _editStylist(Stylist stylist) {
    setState(() {
      _editingStylist = stylist;
      _nameController.text = stylist.name;
      _imageController.text = stylist.image;
      _ratingController.text = stylist.rating.toString();
      _experienceController.text = stylist.experience;
    });
  }

  Future<void> _deleteStylist(String stylistId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa stylist này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('stylists').doc(stylistId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa stylist thành công!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Quản lý Stylist'),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      body: Column(
        children: [
          // Form
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade800),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên stylist',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng nhập tên stylist';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ratingController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Đánh giá',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập đánh giá';
                            }
                            final rating = double.tryParse(value!);
                            if (rating == null || rating < 0 || rating > 5) {
                              return 'Đánh giá phải từ 0-5';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _experienceController,
                          decoration: const InputDecoration(
                            labelText: 'Kinh nghiệm',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập kinh nghiệm';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(
                      labelText: 'URL hình ảnh',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng nhập URL hình ảnh';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addOrUpdateStylist,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(_editingStylist != null ? 'Cập nhật' : 'Thêm mới'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_editingStylist != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _clearForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade600,
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('stylists').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                
                final stylists = snapshot.data?.docs
                    .map((doc) => Stylist.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
                    .toList() ?? [];
                
                if (stylists.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có stylist nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: stylists.length,
                  itemBuilder: (context, index) {
                    final stylist = stylists[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      color: const Color(0xFF1A1A1A),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: stylist.image.isNotEmpty
                              ? NetworkImage(stylist.image)
                              : null,
                          child: stylist.image.isEmpty
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          stylist.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kinh nghiệm: ${stylist.experience}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Đánh giá: ${stylist.rating.toStringAsFixed(1)}/5',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editStylist(stylist),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStylist(stylist.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
