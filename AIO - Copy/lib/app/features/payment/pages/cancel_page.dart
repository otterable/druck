// app/features/payment/pages/cancel_page.dart

import 'package:flutter/material.dart';

class CancelPage extends StatelessWidget {
  const CancelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Customize your cancellation page UI here
      appBar: AppBar(title: const Text('Payment Canceled')),
      body: const Center(
        child: Text(
          'Your payment was canceled.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
