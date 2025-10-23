// lib/screens/profile/favorite_services_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';

class FavoriteServicesScreen extends StatefulWidget {
  const FavoriteServicesScreen({super.key});

  @override
  State<FavoriteServicesScreen> createState() => _FavoriteServicesScreenState();
}

class _FavoriteServicesScreenState extends State<FavoriteServicesScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách yêu thích khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  void _removeFavorite(String serviceId) async {
    await context.read<FavoritesProvider>().toggleFavorite(serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dịch vụ yêu thích')),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          return StreamBuilder(
            stream: favoritesProvider.getFavoriteServicesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Chưa có dịch vụ yêu thích'),
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
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          service.image,
                          width: 60, height: 60, fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
          );
        },
      ),
    );
  }
}