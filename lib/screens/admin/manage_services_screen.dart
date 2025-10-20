// lib/screens/admin/manage_services_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/service.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageController = TextEditingController();
  final _ratingController = TextEditingController();
  
  bool _isLoading = false;
  Service? _editingService;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _imageController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final serviceData = {
        'name': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'duration': _durationController.text.trim(),
        'image': _imageController.text.trim(),
        'rating': double.parse(_ratingController.text.trim()),
      };

      if (_editingService != null) {
        await _firestore.collection('services').doc(_editingService!.id).update(serviceData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật dịch vụ thành công!')),
        );
      } else {
        await _firestore.collection('services').add(serviceData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm dịch vụ thành công!')),
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
    _priceController.clear();
    _durationController.clear();
    _imageController.clear();
    _ratingController.clear();
    _editingService = null;
  }

  void _editService(Service service) {
    setState(() {
      _editingService = service;
      _nameController.text = service.name;
      _priceController.text = service.price.toString();
      _durationController.text = service.duration;
      _imageController.text = service.image;
      _ratingController.text = service.rating.toString();
    });
  }

  Future<void> _deleteService(String serviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa dịch vụ này?'),
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
        await _firestore.collection('services').doc(serviceId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa dịch vụ thành công!')),
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
        title: const Text('Quản lý dịch vụ'),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Tên dịch vụ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập tên dịch vụ';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Giá (VNĐ)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập giá';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Giá không hợp lệ';
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
                          controller: _durationController,
                          decoration: const InputDecoration(
                            labelText: 'Thời gian',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Vui lòng nhập thời gian';
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
                          onPressed: _isLoading ? null : _addOrUpdateService,
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Text(_editingService != null ? 'Cập nhật' : 'Thêm mới'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_editingService != null)
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
              stream: _firestore.collection('services').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                
                final services = snapshot.data?.docs
                    .map((doc) => Service.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
                    .toList() ?? [];
                
                if (services.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có dịch vụ nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      color: const Color(0xFF1A1A1A),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: service.image.isNotEmpty
                              ? NetworkImage(service.image)
                              : null,
                          child: service.image.isEmpty
                              ? const Icon(Icons.build)
                              : null,
                        ),
                        title: Text(
                          service.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${service.price.toStringAsFixed(0)} VNĐ - ${service.duration}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editService(service),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteService(service.id),
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
