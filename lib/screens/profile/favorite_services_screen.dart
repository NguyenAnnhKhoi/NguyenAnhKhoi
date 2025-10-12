// lib/screens/profile/favorite_services_screen.dart
import 'package:flutter/material.dart';
import '../../models/service.dart';
import '../../services/firestore_service.dart';

class FavoriteServicesScreen extends StatefulWidget {
  const FavoriteServicesScreen({super.key});

  @override
  State<FavoriteServicesScreen> createState() => _FavoriteServicesScreenState();
}

class _FavoriteServicesScreenState extends State<FavoriteServicesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _removeFavorite(String serviceId) async {
    try {
      await _firestoreService.toggleFavoriteService(serviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khỏi danh sách yêu thích'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dịch vụ yêu thích')),
      body: StreamBuilder<List<Service>>(
        stream: _firestoreService.getFavoriteServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Chưa có dịch vụ yêu thích',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final favoriteServices = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favoriteServices.length,
            itemBuilder: (context, index) {
              final service = favoriteServices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      service.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 70),
                    ),
                  ),
                  title: Text(service.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${service.price.toStringAsFixed(0)}đ'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeFavorite(service.id),
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