import 'package:flutter/material.dart';

class FavoriteServicesScreen extends StatelessWidget {
  const FavoriteServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dịch vụ yêu thích')),
      body: const Center(child: Text('Đây là trang Dịch vụ yêu thích')),
    );
  }
}