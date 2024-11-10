// app/features/payment/pages/success_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../dashboard/controllers/dashboard_controller.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    print("Entering SuccessPage: ${Uri.base.toString()}");

    // Obtain the DashboardController instance
    final controller = Get.find<DashboardController>();
    final DateTime expiryTime =
        controller.orderCreatedTime.add(const Duration(minutes: 1));

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Successful')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Displaying order number and success message
              Text(
                "Success! Your order number ${controller.orderNumber} has been received.",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                "Items ordered:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Limited height ListView to display ordered items
              Obx(() {
                return SizedBox(
                  height: 200, // Set a fixed height to prevent overflow
                  child: ListView.builder(
                    itemCount: controller.stickers.length,
                    itemBuilder: (context, index) {
                      final sticker = controller.stickers[index];
                      print(
                          "Displaying item ${index + 1}: ${sticker.size.value} x ${sticker.quantity.value} - €${sticker.totalPrice.value.toStringAsFixed(2)}");
                      return ListTile(
                        leading: Image.memory(
                          sticker.imageData.value,
                          width: 50,
                          height: 50,
                        ),
                        title: Text(
                          "Sticker ${index + 1} - Size: ${sticker.size.value}, Quantity: ${sticker.quantity.value}",
                        ),
                        subtitle: Text(
                          "Price: €${sticker.totalPrice.value.toStringAsFixed(2)}",
                        ),
                      );
                    },
                  ),
                );
              }),

              const SizedBox(height: 20),
              Text(
                "Order will be shipped to: ${controller.selectedAddress.value}",
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Display cancellation button with proper Obx usage
              Obx(() {
                final currentTime = DateTime.now();
                final canCancel = currentTime.isBefore(expiryTime);
                print(
                    "Current time: ${DateFormat.Hms().format(currentTime)} - Can cancel until: ${DateFormat.Hms().format(expiryTime)} - Can cancel: $canCancel");
                return ElevatedButton(
                  onPressed: canCancel
                      ? () {
                          print(
                              "Attempting to cancel order: ${controller.orderNumber}");
                          controller.cancelOrder();
                          Get.snackbar("Order Cancelled",
                              "Your order has been cancelled successfully.");
                        }
                      : null,
                  child: Text(
                    canCancel ? "Cancel Order" : "Cancellation period expired",
                  ),
                );
              }),

              // "Back to Dashboard" button
              ElevatedButton(
                onPressed: () {
                  print("Navigating back to dashboard");
                  Get.offAllNamed('/dashboard');
                },
                child: const Text("Back to Dashboard"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
