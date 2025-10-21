import 'package:vietqr_core/vietqr_core.dart';
import 'package:flutter/foundation.dart';

class VietQRGenerator {
  // Thông tin tài khoản test
  static const String TEST_ACCOUNT = "0967353909";
  static const String TEST_NAME = "Le Huynh Cong Vinh";

  static String generateQRString({
    required String amount,
    String? purpose,
    String content = "Cat Toc",
  }) {
    try {
      // Chuẩn hóa amount
      final sanitizedAmount = amount.replaceAll(RegExp(r'[^0-9]'), '');
      if (sanitizedAmount.isEmpty) {
        throw Exception('Số tiền không hợp lệ');
      }

      // Tạo nội dung chuyển khoản
      final transferContent = content.length > 25
          ? content.substring(0, 25)
          : content;

      final payment = VietQrData(
        bankBinCode: SupportedBank.mbbank,
        bankAccount: TEST_ACCOUNT,
        amount: sanitizedAmount,
        merchantName: TEST_NAME,
        merchantCity: 'Ho Chi Minh',
        additional: AdditionalData(
          purpose: transferContent, // Sử dụng content làm purpose
          billNumber: 'DH${DateTime.now().millisecondsSinceEpoch}'.substring(
            0,
            15,
          ),
        ),
      );

      if (kDebugMode) {
        print('VietQR Generated:');
        print('- Account: $TEST_ACCOUNT');
        print('- Amount: $sanitizedAmount');
        print('- Content: $transferContent');
      }

      return VietQr.encode(payment);
    } catch (e) {
      if (kDebugMode) {
        print('VietQR Error: $e');
      }
      throw Exception('Không thể tạo mã QR: $e');
    }
  }
}
