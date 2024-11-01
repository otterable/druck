
// My lib/app/shared_components/responsive_builder.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.
import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobileBuilder,
    required this.tabletBuilder,
    required this.desktopBuilder,
    Key? key,
  }) : super(key: key);

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
  ) mobileBuilder;

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
  ) tabletBuilder;

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
  ) desktopBuilder;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100) {
          return desktopBuilder(context, constraints);
        } else if (constraints.maxWidth >= 600) {
          return tabletBuilder(context, constraints);
        } else {
          return mobileBuilder(context, constraints);
        }
      },
    );
  }
}
