// app/features/dashboard/views/screens/my_orders_screen.dart
// Do not remove this comment text when giving me the new code.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/dashboard_controller.dart';

class MyOrdersScreen extends GetWidget<DashboardController> {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("MyOrdersScreen: Building main widget");
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Obx(() {
            final userName = controller.userProfile.value?.name ?? "Guest";
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Logged in as: $userName",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.orders.isEmpty) {
                debugPrint("MyOrdersScreen: No orders available");
                return const Center(child: Text("No orders found."));
              }
              debugPrint(
                  "MyOrdersScreen: ${controller.orders.length} orders loaded.");
              return ListView.builder(
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final order = controller.orders[index];
                  debugPrint(
                      "MyOrdersScreen: Displaying order ID: ${order.id}");
                  return _buildOrderCard(context, order);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ExpansionTile(
        title: Text(
            "Order Date: ${DateFormat.yMMMd().add_jm().format(order.orderDate)}"),
        subtitle: Text("Total Price: €${order.totalPrice.toStringAsFixed(2)}"),
        children: [
          ...order.items.map((item) => _buildOrderItem(context, item)).toList(),
          _buildOrderTracking(context, order.status),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    debugPrint("MyOrdersScreen: Building item view for size ${item.size}");
    return ListTile(
      leading: item.imageData.isNotEmpty
          ? GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildImagePreviewDialog(item.imageData),
                );
              },
              child: Image.memory(
                item.imageData,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(Icons.image_not_supported),
      title: Text("Size: ${item.size}"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quantity: ${item.quantity}"),
          Text(
              "Price per Sticker: €${(item.price / item.quantity).toStringAsFixed(2)}"),
          Text("Total Price: €${item.price.toStringAsFixed(2)}"),
        ],
      ),
    );
  }

  Widget _buildOrderTracking(BuildContext context, OrderStatus status) {
    debugPrint("MyOrdersScreen: Building tracking for status $status");
    final steps = [
      "1. Image upload",
      "2. Payment",
      "3. Printing start",
      "4. Printing finish",
      "5. Order shipped out",
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        int index = entry.key;
        String step = entry.value;
        bool isCompleted = index <= status.index;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isCompleted ? Colors.green : Colors.grey,
            child: Text((index + 1).toString()),
          ),
          title: Text(step),
        );
      }).toList(),
    );
  }

  Widget _buildImagePreviewDialog(Uint8List imageData) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Image.memory(imageData, fit: BoxFit.contain),
      ),
    );
  }
}
