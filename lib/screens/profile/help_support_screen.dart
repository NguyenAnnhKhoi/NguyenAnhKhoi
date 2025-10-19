// lib/screens/profile/help_support_screen.dart
import 'package:flutter/material.dart';
import 'about_us_screen.dart';
import 'terms_policy_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin & Hỗ trợ')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildListTile(
            context,
            icon: Icons.shield_outlined,
            title: 'Cam kết của chúng tôi',
            screen: const CareCommitmentScreen(),
          ),
          _buildListTile(
            context,
            icon: Icons.storefront_outlined,
            title: 'Về chúng tôi',
            screen: const AboutUsScreen(),
          ),
          _buildListTile(
            context,
            icon: Icons.description_outlined,
            title: 'Điều kiện giao dịch chung',
            screen: const TermsPolicyScreen(mode: 'terms'),
          ),
          _buildListTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách bảo mật thông tin',
            screen: const TermsPolicyScreen(mode: 'privacy'),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, required Widget screen}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => _navigateTo(context, screen),
    );
  }
}

// Màn hình con cho "Cam kết của chúng tôi"
class CareCommitmentScreen extends StatelessWidget {
  const CareCommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💈 Cam kết của chúng tôi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chúng tôi cam kết mang đến cho khách hàng dịch vụ cắt tóc – tạo kiểu chuyên nghiệp, an toàn và minh bạch nhất.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
            ),
            const SizedBox(height: 12),
            Text(
              'Mỗi dịch vụ được thực hiện bởi thợ tóc có tay nghề, sử dụng sản phẩm chăm sóc tóc chính hãng và đảm bảo vệ sinh tuyệt đối.',
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey[800]),
            ),
            const SizedBox(height: 24),
            _buildCommitmentItem(
              context,
              icon: Icons.price_check_rounded,
              text: 'Dịch vụ đúng giá, không phát sinh chi phí ngoài báo giá.',
            ),
            _buildCommitmentItem(
              context,
              icon: Icons.health_and_safety_outlined,
              text: 'Sử dụng sản phẩm rõ nguồn gốc, đảm bảo sức khỏe người dùng.',
            ),
            _buildCommitmentItem(
              context,
              icon: Icons.event_available_outlined,
              text: 'Hỗ trợ đặt lịch nhanh – hủy lịch linh hoạt – phục vụ đúng giờ.',
            ),
            _buildCommitmentItem(
              context,
              icon: Icons.support_agent_rounded,
              text: 'Tiếp nhận phản hồi và giải quyết khiếu nại trong vòng 24 giờ làm việc.',
            ),
            _buildCommitmentItem(
              context,
              icon: Icons.receipt_long_outlined,
              text: 'Cung cấp hóa đơn điện tử khi khách hàng yêu cầu.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentItem(BuildContext context, {required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}