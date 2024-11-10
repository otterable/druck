// app/features/dashboard/views/screens/order_management_screen.dart
// Do not remove this comment text when giving me the new code.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';

class OrderManagementScreen extends GetWidget<DashboardController> {
  const OrderManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("OrderManagementScreen: Building main widget");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Obx(() {
        if (controller.orders.isEmpty) {
          debugPrint("OrderManagementScreen: No orders available");
          return const Center(child: Text("No orders found."));
        }
        return ListView.builder(
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final order = controller.orders[index];
            debugPrint(
                "OrderManagementScreen: Displaying order ID: ${order.id}");
            return _buildAdminOrderCard(context, order);
          },
        );
      }),
    );
  }

  Widget _buildAdminOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ExpansionTile(
        title: Text("Order Date: ${order.orderDate}"),
        subtitle: Text("Total Price: €${order.totalPrice.toStringAsFixed(2)}"),
        children: [
          _buildOrderTracking(order),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: ElevatedButton(
              onPressed: () {
                debugPrint(
                    "OrderManagementScreen: Changing status for order ${order.id}");
                _changeOrderStatus(context, order);
              },
              child: const Text("Change Status"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTracking(Order order) {
    debugPrint(
        "OrderManagementScreen: Building tracking for order ${order.id}");
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
        bool isCompleted = index <= order.status.index;

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

  Future<void> _changeOrderStatus(BuildContext context, Order order) async {
    const statuses = OrderStatus.values;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Order Status"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return RadioListTile<OrderStatus>(
                title: Text(status.toString().split('.').last),
                value: status,
                groupValue: order.status,
                onChanged: (value) {
                  if (value != null) {
                    order.status = value;
                    controller.update(); // Ensure UI updates immediately
                    Navigator.pop(context);
                    debugPrint(
                        "OrderManagementScreen: Updated order status to ${status.toString()}");
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
