// lib/screens/profile/about_us_screen.dart
import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🏠 Về chúng tôi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Thông tin thương hiệu'),
            const SizedBox(height: 16),
            _buildInfoRow('Tên thương hiệu:', 'Genz Barber Studio'),
            _buildInfoRow('Lĩnh vực:', 'Cắt tóc, tạo kiểu, chăm sóc tóc, và đặt lịch trực tuyến.'),
            _buildInfoRow('Mục tiêu:', 'Đem đến trải nghiệm làm đẹp nhanh chóng – tiện lợi – đúng phong cách cho khách hàng.'),
            
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'Mục tiêu phát triển ứng dụng'),
            const SizedBox(height: 16),
            _buildGoalItem(
              'Đặt lịch dễ dàng:',
              'Giúp khách hàng đặt lịch thuận tiện, tra cứu dịch vụ và giá cả minh bạch.',
            ),
            _buildGoalItem(
              'Tạo cầu nối:',
              'Kết nối khách hàng và stylist, giúp việc tư vấn trở nên cá nhân hóa hơn.',
            ),
            _buildGoalItem(
              'Xây dựng cộng đồng:',
              'Tạo một môi trường làm đẹp thân thiện, tôn trọng phong cách riêng của mỗi người.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildInfoRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
          children: [
            TextSpan(
              text: '$title ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}