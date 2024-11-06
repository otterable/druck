part of 'app_pages.dart';

/// used to switch pages
class Routes {
  static const dashboard = _Paths.dashboard;
}

/// contains a list of route names.
// made separately to make it easier to manage route naming
class _Paths {
  static const dashboard = '/dashboard';

  // Example :
  // static const index = '/';
  // static const splash = '/splash';
  // static const product = '/product';
}
// app/config/routes/app_routes.dart

part of 'app_pages.dart';

abstract class Routes {
  static const DASHBOARD = '/';
  static const SUCCESS = '/success';
  static const CANCEL = '/cancel';
  // Add other route names here
}
