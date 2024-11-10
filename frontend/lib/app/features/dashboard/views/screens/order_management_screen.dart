// app/features/dashboard/views/screens/order_management_screen.dart
// Do not remove this comment text when giving me the new code.

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
        if (!controller.isAdmin.value) {
          return const Center(
            child: Text("Access Denied. Admins only."),
          );
        }
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
        title: Text(
            "Order Date: ${DateFormat.yMMMd().add_jm().format(order.orderDate)}"),
        subtitle: Text("Total Price: €${order.totalPrice.toStringAsFixed(2)}"),
        children: [
          ...order.items.map((item) => _buildOrderItem(context, item)).toList(),
          _buildOrderTracking(order),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    debugPrint(
                        "OrderManagementScreen: Changing status for order ${order.id}");
                    _changeOrderStatus(context, order);
                  },
                  child: const Text("Change Status"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _confirmDeleteOrder(context, order);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("Delete Order"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItem item) {
    return ListTile(
      leading: item.imageId.isNotEmpty
          ? GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      _buildImagePreviewDialog(item.imageId),
                );
              },
              child: Image.network(
                'http://localhost:4242/download-image/${item.imageId}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported);
                },
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

  Widget _buildOrderTracking(Order order) {
    debugPrint(
        "OrderManagementScreen: Building tracking for order ${order.id}");
    final steps = [
      "1. Payment",
      "2. Printing start",
      "3. Printing finish",
      "4. Order shipped out",
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
                    controller.updateOrderStatus(order, value);
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

  void _confirmDeleteOrder(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Order"),
          content: const Text("Are you sure you want to delete this order?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                controller.deleteOrder(order);
                Navigator.pop(context);
                debugPrint("OrderManagementScreen: Deleted order ${order.id}");
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreviewDialog(String imageId) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Image.network(
          'http://localhost:4242/download-image/$imageId',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Text('Failed to load image');
          },
        ),
      ),
    );
  }
}
