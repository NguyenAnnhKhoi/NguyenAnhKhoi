// lib/admin/manage_services_screen.dart
import 'package:flutter/material.dart';
import '../models/service.dart';
import '../services/firestore_service.dart';
import 'service_edit_screen.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateAndEdit(Service? service) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceEditScreen(service: service),
      ),
    );
  }

  void _deleteService(String id) async {
    final confirm = await showDialog<bool>(
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteService(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Đã xóa dịch vụ'),
                backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Lỗi khi xóa: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Dịch vụ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _navigateAndEdit(null), // Thêm mới khi service là null
          ),
        ],
      ),
      body: StreamBuilder<List<Service>>(
        stream: _firestoreService.getServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dịch vụ nào.'));
          }

          final services = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(service.image),
                  ),
                  title: Text(service.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${service.price.toStringAsFixed(0)}đ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade400),
                        onPressed: () => _navigateAndEdit(service),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade400),
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
    );
  }
}