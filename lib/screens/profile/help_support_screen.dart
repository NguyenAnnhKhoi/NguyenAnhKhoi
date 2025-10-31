// lib/screens/profile/help_support_screen.dart
import 'package:flutter/material.dart';
import 'about_us_screen.dart';
import 'terms_policy_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0891B2),
        title: const Text(
          'Thông tin & Hỗ trợ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header với icon và text
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0891B2).withOpacity(0.1),
                  const Color(0xFF06B6D4).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0891B2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    size: 48,
                    color: Color(0xFF0891B2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chúng tôi luôn sẵn sàng hỗ trợ bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tìm hiểu thêm về chúng tôi và các chính sách',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Section title
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Thông tin chung',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          
          // Menu items
          _buildMenuCard(
            context,
            icon: Icons.shield_outlined,
            title: 'Cam kết của chúng tôi',
            subtitle: 'Tìm hiểu về cam kết chất lượng dịch vụ',
            color: const Color(0xFF0891B2),
            screen: const CareCommitmentScreen(),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            icon: Icons.storefront_outlined,
            title: 'Về chúng tôi',
            subtitle: 'Câu chuyện và giá trị của Barber Shop',
            color: const Color(0xFF06B6D4),
            screen: const AboutUsScreen(),
          ),
          
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Chính sách & Điều khoản',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          
          _buildMenuCard(
            context,
            icon: Icons.description_outlined,
            title: 'Điều kiện giao dịch chung',
            subtitle: 'Quy định và điều khoản sử dụng dịch vụ',
            color: const Color(0xFF0284C7),
            screen: const TermsPolicyScreen(mode: 'terms'),
          ),
          const SizedBox(height: 12),
          _buildMenuCard(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách bảo mật',
            subtitle: 'Cách chúng tôi bảo vệ thông tin của bạn',
            color: const Color(0xFF0369A1),
            screen: const TermsPolicyScreen(mode: 'privacy'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget screen,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _navigateTo(context, screen),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Màn hình con cho "Cam kết của chúng tôi"
class CareCommitmentScreen extends StatelessWidget {
  const CareCommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0891B2),
        title: const Text(
          'Cam kết của chúng tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0891B2).withOpacity(0.1),
                    const Color(0xFF06B6D4).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0891B2).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 48,
                      color: Color(0xFF0891B2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chất lượng là ưu tiên hàng đầu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Nội dung chính
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'Chúng tôi cam kết mang đến cho khách hàng dịch vụ cắt tóc – tạo kiểu chuyên nghiệp, an toàn và minh bạch nhất.\n\nMỗi dịch vụ được thực hiện bởi thợ tóc có tay nghề, sử dụng sản phẩm chăm sóc tóc chính hãng và đảm bảo vệ sinh tuyệt đối.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            Text(
              'Các cam kết cụ thể',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildCommitmentCard(
              context,
              icon: Icons.price_check_rounded,
              title: 'Minh bạch giá cả',
              text: 'Dịch vụ đúng giá, không phát sinh chi phí ngoài báo giá.',
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 12),
            _buildCommitmentCard(
              context,
              icon: Icons.health_and_safety_outlined,
              title: 'An toàn sức khỏe',
              text: 'Sử dụng sản phẩm rõ nguồn gốc, đảm bảo sức khỏe người dùng.',
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 12),
            _buildCommitmentCard(
              context,
              icon: Icons.event_available_outlined,
              title: 'Linh hoạt đặt lịch',
              text: 'Hỗ trợ đặt lịch nhanh – hủy lịch linh hoạt – phục vụ đúng giờ.',
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 12),
            _buildCommitmentCard(
              context,
              icon: Icons.support_agent_rounded,
              title: 'Hỗ trợ tận tâm',
              text: 'Tiếp nhận phản hồi và giải quyết khiếu nại trong vòng 24 giờ làm việc.',
              color: const Color(0xFFF59E0B),
            ),
            const SizedBox(height: 12),
            _buildCommitmentCard(
              context,
              icon: Icons.receipt_long_outlined,
              title: 'Hóa đơn rõ ràng',
              text: 'Cung cấp hóa đơn điện tử khi khách hàng yêu cầu.',
              color: const Color(0xFF06B6D4),
            ),
            
            const SizedBox(height: 24),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF0891B2).withOpacity(0.1),
                    const Color(0xFF06B6D4).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: const Color(0xFF0891B2),
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sự hài lòng của bạn là thành công của chúng tôi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}