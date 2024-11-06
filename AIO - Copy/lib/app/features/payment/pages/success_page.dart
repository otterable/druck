// app/features/payment/pages/success_page.dart

import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Customize your success page UI here
      appBar: AppBar(title: const Text('Payment Successful')),
      body: const Center(
        child: Text(
          'Thank you for your purchase!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
