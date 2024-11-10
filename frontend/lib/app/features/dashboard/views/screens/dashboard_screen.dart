// My lib/app/features/dashboard/views/screens/dashboard_screen.dart
// If this file is part of the problem, provide me a full update to the code, without omitting a single part. Include these note lines in the code as well, please. Otherwise do not update.

import 'package:daily_task/app/constans/app_constants.dart';
import 'package:daily_task/app/shared_components/header_text.dart';
import 'package:daily_task/app/shared_components/responsive_builder.dart';
import 'package:daily_task/app/shared_components/task_progress.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/dashboard_controller.dart';

class DashboardScreen extends GetWidget<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = controller.isDarkMode.value;
      final isPrintMode = controller.isPrintMode.value;
      return Scaffold(
        key: controller.scafoldKey,
        backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
        drawer: ResponsiveBuilder.isDesktop(context)
            ? null
            : Drawer(
                child: SafeArea(
                  child: SingleChildScrollView(
                      child: _buildSidebar(context, isDarkMode)),
                ),
              ),
        bottomNavigationBar: _BottomNavbar(isDarkMode: isDarkMode),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (controller.showOrderSummary.value) {
              return _buildOrderSummary();
            } else {
              return ResponsiveBuilder(
                mobileBuilder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hide banner when in print mode
                      if (!isPrintMode) _buildImageBanner(),
                      Expanded(
                        child: isPrintMode
                            ? _buildPrintSection()
                            : SingleChildScrollView(
                                child: _buildTaskContent(
                                  onPressedMenu: () =>
                                      Scaffold.of(context).openDrawer(),
                                  isDarkMode: isDarkMode,
                                ),
                              ),
                      ),
                      _buildOrderTracking(isDarkMode),
                    ],
                  );
                },
                tabletBuilder: (context, constraints) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        flex: constraints.maxWidth > 800 ? 8 : 7,
                        child: Column(
                          children: [
                            // Hide banner when in print mode
                            if (!isPrintMode) _buildImageBanner(),
                            Expanded(
                              child: isPrintMode
                                  ? _buildPrintSection()
                                  : SingleChildScrollView(
                                      controller: ScrollController(),
                                      child: _buildTaskContent(
                                        onPressedMenu: () =>
                                            Scaffold.of(context).openDrawer(),
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),
                            ),
                          ],
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
                          child: _buildOrderTracking(isDarkMode),
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
                        child: Column(
                          children: [
                            // Hide banner when in print mode
                            if (!isPrintMode) _buildImageBanner(),
                            Expanded(
                              child: isPrintMode
                                  ? _buildPrintSection()
                                  : SingleChildScrollView(
                                      controller: ScrollController(),
                                      child: _buildTaskContent(
                                        isDarkMode: isDarkMode,
                                      ),
                                    ),
                            ),
                          ],
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
                          child: _buildOrderTracking(isDarkMode),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          }),
        ),
      );
    });
  }

  Widget _buildImageBanner() {
    // Placeholder implementation for _buildImageBanner
    return Container(
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: const Center(
        child: Text(
          'Welcome to Your Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isDarkMode) {
    final DateTime now = DateTime.now();
    final bool isWeekend =
        now.weekday == DateTime.sunday || now.weekday == DateTime.friday;
    final String printingTimeText = isWeekend
        ? "Current printing time: 2 days"
        : "Current printing time: 1 day";
    final Color printingTimeColor = isWeekend ? Colors.orange : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Image.asset(
                  isDarkMode
                      ? 'assets/images/logo_darkmode.png'
                      : 'assets/images/logo.png',
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
                    user != null
                        ? "Logged in as:"
                        : "Order / manage your orders:",
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
                                backgroundColor:
                                    isDarkMode ? Colors.white : Colors.black,
                                foregroundColor:
                                    isDarkMode ? Colors.black : Colors.white,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: controller.signInWithGoogle,
                          child: const Text("Log in with Google"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDarkMode ? Colors.white : Colors.black,
                            foregroundColor:
                                isDarkMode ? Colors.black : Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                }),
              ],
            ),
          ),
        ),

        const Divider(height: 20, thickness: 1),

        // Features Section
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
                description:
                    "There's no reason for 5 small stickers to cost €20.",
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 15),
              _buildFeatureItem(
                icon: Icons.done_all,
                title: "No misunderstandings",
                description:
                    "Automated process, no risk of a worker screwing up your order.",
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),

        const Divider(height: 20, thickness: 1),

        // Print Button and Order Management
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.print),
                label: const Text("Print"),
                onPressed: () => controller.togglePrintMode(),
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

        // Printing Time Display
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

  Widget _buildPrintSection() {
    return Obx(() {
      if (controller.stickers.isEmpty) {
        // No stickers: center the upload button and text vertically and horizontally
        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Upload as many images for stickers as you want.",
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Upload Images"),
                  onPressed: () => controller.uploadImages(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // There are stickers: show the upload images button and text at the top
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Upload as many images for stickers as you want.",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload Images"),
                onPressed: () => controller.uploadImages(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.stickers.length,
                itemBuilder: (context, index) {
                  return _buildStickerConfigCard(index);
                },
              ),
              const SizedBox(height: 20),
              Obx(() {
                final allConfirmed = controller.stickers
                    .every((sticker) => sticker.confirmed.value);
                return ElevatedButton(
                  onPressed:
                      allConfirmed ? controller.proceedToOrderSummary : null,
                  child: const Text("Proceed with Order"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                );
              }),
            ],
          ),
        );
      }
    });
  }

  Widget _buildStickerConfigCard(int index) {
    final sticker = controller.stickers[index];
    final isDarkMode = controller.isDarkMode.value;
    return Obx(() {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            // Full-size image preview
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 500),
              child: Image.memory(
                sticker.imageData.value,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            ExpansionTile(
              key: PageStorageKey('sticker_tile_$index'),
              title: Text("Sticker ${index + 1}"),
              subtitle: Text(
                  "Quantity: ${sticker.quantity.value} | Price: €${sticker.totalPrice.toStringAsFixed(2)}"),
              initiallyExpanded: sticker.isExpanded.value,
              onExpansionChanged: (expanded) {
                sticker.isExpanded.value = expanded;
              },
              children: [
                const SizedBox(height: 10),
                // Hide sections when confirmed
                if (!sticker.confirmed.value)
                  _buildSizeSelection(sticker, index),
                if (!sticker.confirmed.value) const SizedBox(height: 10),
                if (!sticker.confirmed.value)
                  _buildCustomSizeFields(sticker, index),
                if (!sticker.confirmed.value) const SizedBox(height: 10),
                if (!sticker.confirmed.value)
                  _buildQuantitySelection(sticker, index),
                if (!sticker.confirmed.value) const SizedBox(height: 10),
                if (!sticker.confirmed.value)
                  Text(
                    "Price: €${sticker.totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                OverflowBar(
                  alignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => controller.removeStickerConfig(index),
                      child: const Text("Delete"),
                    ),
                    sticker.confirmed.value
                        ? TextButton(
                            onPressed: () =>
                                controller.editStickerSettings(index),
                            child: const Text("Edit"),
                          )
                        : TextButton(
                            onPressed: () =>
                                controller.confirmStickerSettings(index),
                            child: const Text("Confirm"),
                          ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSizeSelection(StickerConfig sticker, int index) {
    final isDarkMode = controller.isDarkMode.value;
    final selectedColor = isDarkMode ? Colors.white : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Printing Format:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Obx(() {
          return Wrap(
            spacing: 10,
            children: List.generate(
              9,
              (i) {
                final size = '${i + 2}x${i + 2}cm';
                return ChoiceChip(
                  label: Text(size),
                  selected: sticker.size.value == size,
                  onSelected: sticker.confirmed.value
                      ? null
                      : (selected) {
                          if (selected) {
                            controller.setSelectedFormatForSticker(index, size);
                          }
                        },
                  selectedColor: selectedColor,
                  backgroundColor:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                  labelStyle: TextStyle(
                    color: sticker.size.value == size
                        ? (isDarkMode ? Colors.black : Colors.white)
                        : null,
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCustomSizeFields(StickerConfig sticker, int index) {
    final isDarkMode = controller.isDarkMode.value;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Or select custom size:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text("Width (X) in cm"),
                  Obx(() {
                    return TextField(
                      enabled: !sticker.confirmed.value,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        double width =
                            double.tryParse(value.replaceAll(',', '.')) ??
                                sticker.customWidth.value;
                        controller.setCustomDimensionsForSticker(
                            index, width, sticker.customHeight.value);
                      },
                      decoration: InputDecoration(
                        hintText: "Width",
                        errorText: controller.widthErrorText.value,
                      ),
                      controller: TextEditingController(
                          text: sticker.customWidth.value.toString()),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  const Text("Height (Y) in cm"),
                  Obx(() {
                    return TextField(
                      enabled: !sticker.confirmed.value,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        double height =
                            double.tryParse(value.replaceAll(',', '.')) ??
                                sticker.customHeight.value;
                        controller.setCustomDimensionsForSticker(
                            index, sticker.customWidth.value, height);
                      },
                      decoration: InputDecoration(
                        hintText: "Height",
                        errorText: controller.heightErrorText.value,
                      ),
                      controller: TextEditingController(
                          text: sticker.customHeight.value.toString()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelection(StickerConfig sticker, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Quantity:",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Obx(() {
          return TextField(
            enabled: !sticker.confirmed.value,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              int quantity = int.tryParse(value) ?? sticker.quantity.value;
              if (quantity < 1) quantity = 1;
              controller.setQuantityForSticker(index, quantity);
            },
            controller:
                TextEditingController(text: sticker.quantity.value.toString()),
          );
        }),
      ],
    );
  }

  Widget _buildTaskContent(
      {Function()? onPressedMenu, required bool isDarkMode}) {
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
                  DateFormat('d MMMM yyyy').format(DateTime.now()),
                  color: textColor,
                ),
              ),
              const SizedBox(width: kSpacing / 2),
              SizedBox(
                width: 200,
                child: TaskProgress(
                    data: controller.dataTask, textColor: textColor),
              ),
            ],
          ),
          const SizedBox(height: kSpacing),
        ],
      ),
    );
  }

  Widget _buildOrderTracking(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final currentStep = controller.currentOrderStep.value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: kSpacing),
          Row(
            children: [
              Expanded(
                child: HeaderText("Order Tracking", color: textColor),
              ),
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
          // Order Steps
          _buildOrderSteps(isDarkMode, currentStep),
        ],
      ),
    );
  }

  Widget _buildOrderSteps(bool isDarkMode, int currentStep) {
    final steps = [
      {
        'title': '1. Image upload',
        'description':
            'This is where you upload the files you want to be printed as stickers. As many as you want!',
      },
      {
        'title': '2. Payment',
        'description':
            'Pay for your order. Within mere hours, your order will be printed!',
      },
      {
        'title': '3. Printing start',
        'description': 'Your order is being printed!',
      },
      {
        'title': '4. Printing finish',
        'description':
            'Your order has been successfully printed and will be sent as soon as possible.',
      },
      {
        'title': '5. Order shipped out',
        'description': 'Your order has been shipped!',
      },
    ];

    return Column(
      children: List.generate(steps.length, (index) {
        final isActive = index <= currentStep;
        return Column(
          children: [
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 2,
                        height: 50,
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[index]['title']!,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        steps[index]['description']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  Widget _buildOrderSummary() {
    final isDarkMode = controller.isDarkMode.value;
    final totalPrice = controller.totalOrderPrice.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: controller.stickers.length,
                  itemBuilder: (context, index) {
                    final sticker = controller.stickers[index];
                    return Card(
                      child: ListTile(
                        leading: Image.memory(
                          sticker.imageData.value,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                            'Sticker ${index + 1} - €${sticker.totalPrice.toStringAsFixed(2)}'),
                        subtitle: Text(
                            'Size: ${sticker.size.value}, Quantity: ${sticker.quantity.value}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            controller.editStickerSettings(index);
                            controller.showOrderSummary.value = false;
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Total Price: €${totalPrice.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.initiatePayment,
                child: const Text('Proceed to Payment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BottomNavbar extends StatelessWidget {
  final bool isDarkMode;
  const _BottomNavbar({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      unselectedItemColor: isDarkMode ? Colors.white70 : Colors.black54,
      selectedItemColor: isDarkMode ? Colors.white : Colors.black,
    );
  }
}
