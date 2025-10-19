// lib/admin/manage_branches_screen.dart
import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/firestore_service.dart';
import 'branch_edit_screen.dart';

class ManageBranchesScreen extends StatefulWidget {
  const ManageBranchesScreen({super.key});

  @override
  State<ManageBranchesScreen> createState() => _ManageBranchesScreenState();
}

class _ManageBranchesScreenState extends State<ManageBranchesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _navigateAndEdit(Branch? branch) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BranchEditScreen(branch: branch),
      ),
    );
  }

  void _deleteBranch(String id) async {
    final confirm = await showDialog<bool>(
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
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestoreService.deleteBranch(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Đã xóa chi nhánh'),
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
        title: const Text('Quản lý Chi nhánh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _navigateAndEdit(null),
          ),
        ],
      ),
      body: StreamBuilder<List<Branch>>(
        stream: _firestoreService.getBranches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có chi nhánh nào.'));
          }

          final branches = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: branches.length,
            itemBuilder: (context, index) {
              final branch = branches[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(branch.image),
                  ),
                  title: Text(branch.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(branch.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue.shade400),
                        onPressed: () => _navigateAndEdit(branch),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade400),
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
    );
  }
}