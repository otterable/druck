// stripe_real.dart

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePlatformInterface {
  static void initialize() {
    // Initialize Stripe with your publishable key
    Stripe.publishableKey =
        'pk_live_51Lxm6sEgtx1au46GHhDtjk3JZ04OaA8p7T6xM4lQFLxfbPotRsuT4AhoM4WA0myCsirZeQN32vnUvUSmn1zVyD3m00docojbx7';
    Stripe.merchantIdentifier = 'merchant.com.example'; // Update as needed
    Stripe.urlScheme = 'flutterstripe'; // Update with your URL scheme if needed
  }

  static Future<void> initPaymentSheet({
    required String paymentIntentClientSecret,
    required String merchantDisplayName,
    required bool isDarkMode,
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: paymentIntentClientSecret,
        merchantDisplayName: merchantDisplayName,
        style: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        applePay: const PaymentSheetApplePay(
          merchantCountryCode: 'US', // Replace with your country code
        ),
        googlePay: const PaymentSheetGooglePay(
          merchantCountryCode: 'US', // Replace with your country code
          testEnv: false, // Set to true for testing
        ),
      ),
    );
  }

  static Future<void> presentPaymentSheet() async {
    await Stripe.instance.presentPaymentSheet();
  }
}

class StripeException implements Exception {
  final String message;
  StripeException(this.message);
}
