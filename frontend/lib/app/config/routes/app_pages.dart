// app/config/routes/app_pages.dart
// Do not remove this comment text when giving me the new code.

import 'package:daily_task/app/features/dashboard/views/screens/dashboard_screen.dart';
import 'package:daily_task/app/features/dashboard/views/screens/my_orders_screen.dart'; // Import MyOrdersScreen
import 'package:daily_task/app/features/payment/pages/cancel_page.dart';
import 'package:daily_task/app/features/payment/pages/success_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/dashboard/controllers/dashboard_controller.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.dashboard;

  static final routes = [
    GetPage(
      name: Routes.dashboard,
      page: () {
        print("Navigating to DashboardScreen");
        print("Current URL: ${Uri.base.toString()}");
        return const DashboardScreen();
      },
      binding: BindingsBuilder(() {
        print("Binding DashboardController for DashboardScreen");
        Get.put(DashboardController());
      }),
    ),
    GetPage(
      name: Routes.success,
      page: () {
        print("Navigating to SuccessPage");
        print("Current URL: ${Uri.base.toString()}");
        return const SuccessPage();
      },
      binding: BindingsBuilder(() {
        print("Lazy binding DashboardController for SuccessPage");
        Get.lazyPut<DashboardController>(() => DashboardController());
      }),
    ),
    GetPage(
      name: Routes.cancel,
      page: () {
        print("Navigating to CancelPage");
        print("Current URL: ${Uri.base.toString()}");
        return const CancelPage();
      },
    ),
    GetPage(
      name: Routes.myOrders, // Added route for MyOrdersScreen
      page: () {
        print("Navigating to MyOrdersScreen");
        return const MyOrdersScreen();
      },
      binding: BindingsBuilder(() {
        print("Binding DashboardController for MyOrdersScreen");
        Get.put(DashboardController());
      }),
    ),
  ];

  static final unknownRoute = GetPage(
    name: '/notfound',
    page: () => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('404 - Page Not Found')),
    ),
  );
}
