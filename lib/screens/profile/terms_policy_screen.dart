import 'package:flutter/material.dart';

class TermsPolicyScreen extends StatelessWidget {
  const TermsPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chính sách & Điều khoản')),
      body: const Center(child: Text('Đây là trang Chính sách & Điều khoản')),
    );
  }
}