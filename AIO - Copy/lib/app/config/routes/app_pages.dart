// My app/config/routes/app_pages.dart
import '../../features/dashboard/views/screens/dashboard_screen.dart';
import '../../features/dashboard/bindings/dashboard_binding.dart'; // Import the DashboardBinding class
import 'package:get/get.dart';

part 'app_routes.dart';

/// contains all configuration pages
class AppPages {
  /// when the app is opened, this page will be the first to be shown
  static const initial = Routes.dashboard;

  static final routes = [
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
  ];
}
