// app/config/routes/app_pages.dart
// Do not remove this comment text when giving me the new code.

import 'package:daily_task/app/features/dashboard/views/screens/dashboard_screen.dart';
import 'package:daily_task/app/features/payment/pages/cancel_page.dart';
import 'package:daily_task/app/features/payment/pages/success_page.dart';
import 'package:get/get.dart';

import '../../features/dashboard/controllers/dashboard_controller.dart';
import 'app_routes.dart';
// Import other pages as needed

class AppPages {
  static const initial = Routes.DASHBOARD;

  static final routes = [
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController()); // Initializes DashboardController
      }),
    ),
    GetPage(
      name: Routes.SUCCESS,
      page: () => const SuccessPage(),
    ),
    GetPage(
      name: Routes.CANCEL,
      page: () => const CancelPage(),
    ),
    // Add other GetPages here
  ];
}
