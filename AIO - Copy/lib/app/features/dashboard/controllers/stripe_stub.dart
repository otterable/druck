// stripe_stub.dart

class StripePlatformInterface {
  static void initialize() {
    // Do nothing on web
  }

  static Future<void> initPaymentSheet({
    required String paymentIntentClientSecret,
    required String merchantDisplayName,
    required bool isDarkMode,
  }) async {
    // Do nothing on web
  }

  static Future<void> presentPaymentSheet() async {
    // Do nothing on web
  }
}

class StripeException implements Exception {
  final String message;
  StripeException(this.message);
}
