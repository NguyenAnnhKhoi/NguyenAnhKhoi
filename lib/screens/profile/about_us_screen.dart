import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Về chúng tôi')),
      body: const Center(child: Text('Đây là trang Về chúng tôi')),
    );
  }
}