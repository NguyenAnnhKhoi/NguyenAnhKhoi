import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF1E3A8A);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 24, errorBuilder: (_, __, ___) => const SizedBox()),
            const SizedBox(width: 8),
            const Text('30 SHINE SHOP', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: const [
          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.search, color: Colors.black)),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.shopping_cart_outlined, color: Colors.black)),
          Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.menu, color: Colors.black)),
        ],
      ),
      body: ListView(
        children: [
          // Top chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _chip('Sổ địa chỉ'),
                const SizedBox(width: 12),
                _chip('Đơn hàng'),
              ],
            ),
          ),

          // Banner (placeholder)
          AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://i.imgur.com/1kT6g2b.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Benefits row
          Row(
            children: [
              _benefit(primary, Icons.local_shipping_outlined, 'Hỗ trợ giao hàng hoả tốc'),
              _benefit(primary, Icons.attach_money, 'Hoàn tiền 120%'),
            ],
          ),

          const SizedBox(height: 12),

          // Categories circles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circle(primary, Icons.local_fire_department, 'Hot'),
                _circle(primary, Icons.sell_outlined, 'Sale'),
                _circle(primary, Icons.military_tech_outlined, 'Độc quyền'),
                _circle(primary, Icons.sentiment_satisfied_alt_outlined, 'Hết mụn'),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _benefit(Color primary, IconData icon, String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: primary),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _circle(Color primary, IconData icon, String text) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}


