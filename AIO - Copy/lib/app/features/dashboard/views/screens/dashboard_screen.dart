// My lib/app/views/screens/dashboard_screen.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

library dashboard;

import 'package:daily_task/app/constans/app_constants.dart';
import 'package:daily_task/app/shared_components/card_task.dart';
import 'package:daily_task/app/shared_components/header_text.dart';
import 'package:daily_task/app/shared_components/list_task_assigned.dart';
import 'package:daily_task/app/shared_components/list_task_date.dart';
import 'package:daily_task/app/shared_components/responsive_builder.dart';
import 'package:daily_task/app/shared_components/task_progress.dart';
import 'package:daily_task/app/shared_components/user_profile.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daily_task/app/utils/helpers/app_helpers.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

// binding
part '../../bindings/dashboard_binding.dart';

// controller
part '../../controllers/dashboard_controller.dart';

// component
part '../components/bottom_navbar.dart';
part '../components/header_order_history.dart';
part '../components/main_menu.dart';
part '../components/task_in_progress.dart';
part '../components/weekly_task.dart';
part '../components/task_group.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = controller.isDarkMode.value;
      return Scaffold(
        key: controller.scafoldKey,
        backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
        drawer: ResponsiveBuilder.isDesktop(context)
            ? null
            : Drawer(
                child: SafeArea(
                  child: SingleChildScrollView(child: _buildSidebar(context, isDarkMode)),
                ),
              ),
        bottomNavigationBar: _BottomNavbar(isDarkMode: isDarkMode),
        body: SafeArea(
          child: ResponsiveBuilder(
            mobileBuilder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageBanner(),
                    _buildTaskContent(
                      onPressedMenu: () => controller.openDrawer(),
                      isDarkMode: isDarkMode,
                    ),
                    _buildCalendarContent(isDarkMode),
                  ],
                ),
              );
            },
            tabletBuilder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: constraints.maxWidth > 800 ? 8 : 7,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: Column(
                        children: [
                          _buildImageBanner(),
                          _buildTaskContent(
                            onPressedMenu: () => controller.openDrawer(),
                            isDarkMode: isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const VerticalDivider(),
                  ),
                  Flexible(
                    flex: 4,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: _buildCalendarContent(isDarkMode),
                    ),
                  ),
                ],
              );
            },
            desktopBuilder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: constraints.maxWidth > 1350 ? 3 : 4,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: _buildSidebar(context, isDarkMode),
                    ),
                  ),
                  Flexible(
                    flex: constraints.maxWidth > 1350 ? 10 : 9,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: Column(
                        children: [
                          _buildImageBanner(),
                          _buildTaskContent(isDarkMode: isDarkMode),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const VerticalDivider(),
                  ),
                  Flexible(
                    flex: 4,
                    child: SingleChildScrollView(
                      controller: ScrollController(),
                      child: _buildCalendarContent(isDarkMode),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  // Sidebar with updated UI elements
  Widget _buildSidebar(BuildContext context, bool isDarkMode) {
    final DateTime now = DateTime.now();
    final bool isWeekend = now.weekday == DateTime.sunday || now.weekday == DateTime.friday;
    final String printingTimeText = isWeekend ? "Current printing time: 2 days" : "Current printing time: 1 day";
    final Color printingTimeColor = isWeekend ? Colors.orange : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and Service Title
        Container(
          width: double.infinity,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                child: Image.asset(
                  isDarkMode ? 'assets/images/logo_darkmode.png' : 'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Sticker Printing Service",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Divider(height: 20, thickness: 1),

        // Google Login Button
        Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: [
                Obx(() {
                  final user = controller.user.value;
                  return Text(
                    user != null ? "Logged in as:" : "Order / manage your orders:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  );
                }),
                const SizedBox(height: 10),
                Obx(() {
                  final user = controller.user.value;
                  return user != null
                      ? Column(
                          children: [
                            Text(
                              user.displayName ?? "User",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: controller.signOutFromGoogle,
                              child: const Text("Log out"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode ? Colors.white : Colors.black,
                                foregroundColor: isDarkMode ? Colors.black : Colors.white,
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: controller.signInWithGoogle,
                          child: const Text("Log in with Google"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode ? Colors.white : Colors.black,
                            foregroundColor: isDarkMode ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                }),
              ],
            ),
          ),
        ),

        const Divider(height: 20, thickness: 1),

        // Second Headline Section with Icons and Separate Points
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureItem(
                icon: Icons.check_circle_outline,
                title: "No requests",
                description: "No emailing. No chatting. No humans.",
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 15),
              _buildFeatureItem(
                icon: Icons.attach_money,
                title: "Reasonable pricing",
                description: "There's no reason for 5 small stickers to cost €20. That's why we created this service.",
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 15),
              _buildFeatureItem(
                icon: Icons.done_all,
                title: "No misunderstandings",
                description: "Automated process, no risk of a worker screwing up your order.",
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),

        const Divider(height: 20, thickness: 1),

        // Bottom Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text("Print"),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  padding: const EdgeInsets.all(10),
                  backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.shopping_bag),
                label: const Text("My Orders"),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  padding: const EdgeInsets.all(10),
                  backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 20, thickness: 1),

        // Printing Time Section
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: printingTimeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: printingTimeColor.withOpacity(0.8),
                      spreadRadius: 2,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                printingTimeText,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: isDarkMode ? Colors.white : Colors.black, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Image.asset(
          'assets/images/banner.png',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTaskContent({Function()? onPressedMenu, required bool isDarkMode}) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Column(
        children: [
          const SizedBox(height: kSpacing),
          Row(
            children: [
              if (onPressedMenu != null)
                Padding(
                  padding: const EdgeInsets.only(right: kSpacing / 2),
                  child: IconButton(
                    onPressed: onPressedMenu,
                    icon: Icon(Icons.menu, color: textColor),
                  ),
                ),
              Expanded(
                child: HeaderText(
                  DateTime.now().formatdMMMMY(),
                  color: textColor,
                ),
              ),
              const SizedBox(width: kSpacing / 2),
              SizedBox(
                width: 200,
                child: TaskProgress(data: controller.dataTask, textColor: textColor),
              ),
            ],
          ),
          const SizedBox(height: kSpacing),
          _TaskInProgress(data: controller.taskInProgress, textColor: textColor),
          const SizedBox(height: kSpacing * 2),
          _HeaderOrderHistory(textColor: textColor),
          const SizedBox(height: kSpacing),
          _WeeklyTask(
            data: controller.weeklyTask,
            onPressed: controller.onPressedTask,
            onPressedAssign: controller.onPressedAssignTask,
            onPressedMember: controller.onPressedMemberTask,
            textColor: textColor,
          )
        ],
      ),
    );
  }

  Widget _buildCalendarContent(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Column(
        children: [
          const SizedBox(height: kSpacing),
          Row(
            children: [
              Expanded(child: HeaderText("Order Tracking", color: textColor)),
              IconButton(
                onPressed: controller.onPressedCalendar,
                icon: Icon(EvaIcons.calendarOutline, color: textColor),
                tooltip: "order tracking",
              ),
              Switch(
                value: controller.isDarkMode.value,
                onChanged: (value) => controller.toggleDarkMode(value),
                activeColor: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: kSpacing),
          ...controller.taskGroup.map(
            (e) => _TaskGroup(
              title: DateFormat('d MMMM').format(e[0].date),
              data: e,
              onPressed: controller.onPressedTaskGroup,
              textColor: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
