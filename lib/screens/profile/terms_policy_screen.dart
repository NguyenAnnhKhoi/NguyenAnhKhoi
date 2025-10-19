// lib/screens/profile/terms_policy_screen.dart
import 'package:flutter/material.dart';

class TermsPolicyScreen extends StatelessWidget {
  final String mode;

  const TermsPolicyScreen({
    super.key,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTerms = (mode == 'terms');
    final String title = isTerms ? '📜 Điều kiện giao dịch' : '🔒 Chính sách bảo mật';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: isTerms ? _buildTermsContent(context) : _buildPolicyContent(context),
      ),
    );
  }

  // --- NỘI DUNG ĐIỀU KIỆN GIAO DỊCH ---
  Widget _buildTermsContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '3. Điều kiện giao dịch chung'),
        const SizedBox(height: 24),
        _buildSubSectionTitle('3.1. Phạm vi áp dụng'),
        _buildContentText('Điều kiện giao dịch này áp dụng cho tất cả khách hàng sử dụng dịch vụ tại tiệm hoặc qua ứng dụng/website đặt lịch của chúng tôi.'),
        const SizedBox(height: 24),

        _buildSubSectionTitle('3.2. Quy trình đặt và xác nhận lịch'),
        _buildBulletPoint('Khách hàng có thể đặt lịch qua app, website hoặc trực tiếp tại tiệm.'),
        _buildBulletPoint('Lịch hẹn chỉ được xác nhận khi hệ thống thông báo “Đặt lịch thành công”.'),
        _buildBulletPoint('Trường hợp cần hủy hoặc thay đổi lịch, vui lòng thao tác trước 2 giờ so với thời gian hẹn.'),
        const SizedBox(height: 24),

        _buildSubSectionTitle('3.3. Giá dịch vụ và thanh toán'),
        _buildBulletPoint('Giá dịch vụ được niêm yết công khai, có thể thay đổi tùy chương trình khuyến mãi.'),
        _buildBulletPoint('Hình thức thanh toán: Tiền mặt, chuyển khoản, hoặc qua ví điện tử.'),
        _buildBulletPoint('Hóa đơn sẽ được cấp sau khi hoàn tất thanh toán.'),
        const SizedBox(height: 24),

        _buildSubSectionTitle('3.4. Trách nhiệm của hai bên'),
        _buildContentText('Khách hàng: Cung cấp thông tin chính xác, hợp tác trong quá trình sử dụng dịch vụ.'),
        _buildContentText('Tiệm: Cung cấp dịch vụ đúng cam kết, bảo vệ thông tin khách hàng, hỗ trợ sau dịch vụ.'),
        const SizedBox(height: 24),

        _buildSubSectionTitle('3.5. Chính sách khiếu nại'),
        _buildContentText('Khi có vấn đề về chất lượng dịch vụ, khách hàng có thể gửi phản hồi qua app hoặc hotline. Chúng tôi sẽ phản hồi trong 24–48 giờ kể từ thời điểm tiếp nhận.'),
      ],
    );
  }

  // --- NỘI DUNG CHÍNH SÁCH BẢO MẬT ---
  Widget _buildPolicyContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, '4. Chính sách bảo mật thông tin'),
        const SizedBox(height: 16),
        _buildContentText('Chúng tôi tôn trọng và cam kết bảo vệ tuyệt đối thông tin cá nhân của khách hàng theo quy định pháp luật.'),
        const SizedBox(height: 24),

        _buildSubSectionTitle('4.1. Thu thập thông tin'),
        _buildContentText('Chúng tôi chỉ thu thập các thông tin cần thiết khi khách hàng đăng ký hoặc đặt lịch:'),
        _buildBulletPoint('Họ tên, số điện thoại, email.'),
        _buildBulletPoint('Thông tin lịch hẹn, kiểu tóc yêu cầu, thời gian sử dụng dịch vụ.'),
        _buildBulletPoint('Dữ liệu kỹ thuật (thiết bị, địa chỉ IP) phục vụ cải thiện trải nghiệm người dùng.'),
        const SizedBox(height: 24),

        _buildSubSectionTitle('4.2. Mục đích sử dụng'),
        _buildBulletPoint('Quản lý lịch hẹn và chăm sóc khách hàng.'),
        _buildBulletPoint('Gửi thông báo, khuyến mãi, và phản hồi dịch vụ.'),
        _buildBulletPoint('Nâng cao chất lượng phục vụ và hỗ trợ kỹ thuật.'),
        const SizedBox(height: 24),
        
        _buildSubSectionTitle('4.3. Bảo mật và chia sẻ'),
        _buildBulletPoint('Thông tin khách hàng được mã hóa và lưu trữ an toàn.'),
        _buildBulletPoint('Không chia sẻ cho bên thứ ba trừ khi có yêu cầu của cơ quan nhà nước có thẩm quyền.'),
        _buildBulletPoint('Khách hàng có quyền yêu cầu chỉnh sửa hoặc xóa thông tin bất cứ lúc nào.'),
        const SizedBox(height: 24),

        _buildSubSectionTitle('4.4. Liên hệ'),
        _buildContentText('Mọi thắc mắc về chính sách bảo mật, vui lòng liên hệ:'),
        _buildContactInfo(Icons.phone, 'Hotline', '[09xxxxxxx]'),
        _buildContactInfo(Icons.email, 'Email', '[email.@example.com]'),
        _buildContactInfo(Icons.location_on, 'Địa chỉ', '[123 Đường ABC, Quận XYZ, TP. HCM]'),
      ],
    );
  }

  // --- WIDGETS HỖ TRỢ ĐỊNH DẠNG ---
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildContentText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String type, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text(
            '$type: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}