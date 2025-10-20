// lib/screens/admin/manage_branches_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/branch.dart';

class ManageBranchesScreen extends StatefulWidget {
  const ManageBranchesScreen({super.key});

  @override
  State<ManageBranchesScreen> createState() => _ManageBranchesScreenState();
}

class _ManageBranchesScreenState extends State<ManageBranchesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _hoursController = TextEditingController();
  final _imageController = TextEditingController();
  final _ratingController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  bool _isLoading = false;
  Branch? _editingBranch;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    _imageController.dispose();
    _ratingController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateBranch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final branchData = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'hours': _hoursController.text.trim(),
        'image': _imageController.text.trim(),
        'rating': double.parse(_ratingController.text.trim()),
        'latitude': double.parse(_latitudeController.text.trim()),
        'longitude': double.parse(_longitudeController.text.trim()),
      };

      if (_editingBranch != null) {
        await _firestore.collection('branches').doc(_editingBranch!.id).update(branchData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật chi nhánh thành công!')),
        );
      } else {
        await _firestore.collection('branches').add(branchData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm chi nhánh thành công!')),
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
    _addressController.clear();
    _hoursController.clear();
    _imageController.clear();
    _ratingController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _editingBranch = null;
  }

  void _editBranch(Branch branch) {
    setState(() {
      _editingBranch = branch;
      _nameController.text = branch.name;
      _addressController.text = branch.address;
      _hoursController.text = branch.hours;
      _imageController.text = branch.image;
      _ratingController.text = branch.rating.toString();
      _latitudeController.text = branch.latitude.toString();
      _longitudeController.text = branch.longitude.toString();
    });
  }

  Future<void> _deleteBranch(String branchId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa chi nhánh này?'),
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
        await _firestore.collection('branches').doc(branchId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa chi nhánh thành công!')),
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
        title: const Text('Quản lý chi nhánh'),
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
                      labelText: 'Tên chi nhánh',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng nhập tên chi nhánh';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Địa chỉ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Vui lòng nhập địa chỉ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _hoursController,
                          decoration: const InputDecoration(
                            labelText: 'Giờ hoạt động',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập giờ hoạt động';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latitudeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Vĩ độ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập vĩ độ';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Vĩ độ không hợp lệ';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _longitudeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Kinh độ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập kinh độ';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Kinh độ không hợp lệ';
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
                          onPressed: _isLoading ? null : _addOrUpdateBranch,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(_editingBranch != null ? 'Cập nhật' : 'Thêm mới'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_editingBranch != null)
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
              stream: _firestore.collection('branches').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                
                final branches = snapshot.data?.docs
                    .map((doc) => Branch.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
                    .toList() ?? [];
                
                if (branches.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có chi nhánh nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      color: const Color(0xFF1A1A1A),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: branch.image.isNotEmpty
                              ? NetworkImage(branch.image)
                              : null,
                          child: branch.image.isEmpty
                              ? const Icon(Icons.store)
                              : null,
                        ),
                        title: Text(
                          branch.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              branch.address,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              branch.hours,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editBranch(branch),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteBranch(branch.id),
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
