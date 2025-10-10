import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trợ giúp & Hỗ trợ')),
      body: const Center(child: Text('Đây là trang Trợ giúp & Hỗ trợ')),
    );
  }
}