// app/features/dashboard/controllers/dashboard_controller.dart
// Do not remove this comment text when giving me the new code.

import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../shared_components/task_progress.dart';

class DashboardController extends GetxController {
  final scafoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '545461705793-3v0101rqbcp0hqkeiqt0ohca9me9d0b3.apps.googleusercontent.com',
  );

  final Rx<UserProfileData?> userProfile = Rx<UserProfileData?>(null);
  final dataTask = const TaskProgressData(totalTask: 5, totalCompleted: 1);
  Rx<GoogleSignInAccount?> user = Rx<GoogleSignInAccount?>(null);
  RxBool isDarkMode = false.obs;
  RxBool isPrintMode = false.obs;
  RxList<StickerConfig> stickers = <StickerConfig>[].obs;
  RxString widthErrorText = ''.obs;
  RxString heightErrorText = ''.obs;
  RxInt currentOrderStep = 0.obs;
  RxBool showOrderSummary = false.obs;
  RxDouble totalOrderPrice = 0.0.obs;
  RxBool isLoading = false.obs;
  RxString selectedAddress = ''.obs;
  DateTime orderCreatedTime = DateTime.now();
  String orderNumber = '';

  DashboardController() {
    debugPrint("DashboardController initialized.");
    _initializeGoogleSignIn();
    _initializeStripe();
  }

  Future<void> _initializeGoogleSignIn() async {
    debugPrint("Initializing Google Sign-In...");
    _googleSignIn.onCurrentUserChanged.listen((account) {
      user.value = account;
      if (account != null) {
        userProfile.value = UserProfileData(
          image: account.photoUrl != null
              ? NetworkImage(account.photoUrl!) as ImageProvider<Object>
              : const AssetImage('assets/images/raster/man.png'),
          name: account.displayName ?? "User",
          jobDesk: account.email,
        );
      } else {
        userProfile.value = null;
      }
    });
    await _googleSignIn.signInSilently();
  }

  void _initializeStripe() {
    if (!kIsWeb) {
      debugPrint("Initializing Stripe...");
    } else {
      debugPrint("Skipping Stripe initialization on Web platform.");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      debugPrint("Attempting Google Sign-In...");
      await _googleSignIn.signIn();
      debugPrint("Google Sign-In successful.");
    } catch (error) {
      debugPrint("Google Sign-In error: $error");
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      debugPrint("Attempting to sign out from Google...");
      await _googleSignIn.disconnect();
      user.value = null;
      userProfile.value = null;
      debugPrint("Google Sign-Out successful.");
    } catch (error) {
      debugPrint("Google Sign-Out error: $error");
    }
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    debugPrint("Dark mode toggled: $value");
  }

  void togglePrintMode() {
    isPrintMode.value = !isPrintMode.value;
    debugPrint("Print mode toggled: ${isPrintMode.value}");
  }

  void addStickerConfig(StickerConfig stickerConfig) {
    stickers.add(stickerConfig);
    calculateTotalPrice();
  }

  void removeStickerConfig(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers.removeAt(index);
      calculateTotalPrice();
    }
  }

  void editStickerSettings(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers[index].confirmed.value = false;
      showOrderSummary.value = false;
    }
  }

  void confirmStickerSettings(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers[index].confirmed.value = true;
      calculateTotalPrice();
    }
  }

  void calculateTotalPrice() {
    double total = 0.0;
    for (var sticker in stickers) {
      total += sticker.totalPrice.value;
    }
    totalOrderPrice.value = total;
  }

  void proceedToOrderSummary() {
    showOrderSummary.value = true;
    calculateTotalPrice();
  }

  Future<void> initiatePayment() async {
    isLoading.value = true;
    debugPrint("Initiating payment...");

    try {
      final List<Map<String, Object>> lineItems = stickers.map((sticker) {
        return {
          "name": "Sticker ${sticker.size.value}",
          "amount": (sticker.totalPrice.value * 100).toInt(),
          "quantity": sticker.quantity.value,
        };
      }).toList();

      final url = Uri.parse('http://localhost:4242/create-checkout-session');
      debugPrint("Attempting to post to: $url with data: ${jsonEncode({
            "items": lineItems,
            "address": selectedAddress.value,
          })}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(<String, Object>{
          "items": lineItems,
          "address": selectedAddress.value,
        }),
      );

      debugPrint("Response status code: ${response.statusCode}");
      debugPrint("Response headers: ${response.headers}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final sessionId = jsonDecode(response.body)['id'];
        debugPrint(
            "Stripe session created successfully. Session ID: $sessionId");
        redirectToCheckout(sessionId);
      } else {
        debugPrint(
            "Failed to create checkout session. Status code: ${response.statusCode}");
        Get.snackbar('Payment Error',
            'Failed to create checkout session. Please try again.',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      debugPrint("Payment Error: ${e.toString()}");
      Get.snackbar(
          'Payment Error', 'An error occurred during payment: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void redirectToCheckout(String sessionId) {
    if (kIsWeb) {
      const String stripePublishableKey = kReleaseMode
          ? 'pk_live_51Lxm6sEgtx1au46GHhDtjk3JZ04OaA8p7T6xM4lQFLxfbPotRsuT4AhoM4WA0myCsirZeQN32vnUvUSmn1zVyD3m00docojbx7'
          : 'pk_test_51Lxm6sEgtx1au46GFqvv2vkvZM9eB92E5WBzrG1DPEJOW1w6mPJolzlmnG0qNNRF3hh7WQaZAHhz3lYSQW6Pql4n00eb4DuvxX';

      final redirectToCheckoutJs = '''
      var stripe = Stripe('$stripePublishableKey');
      stripe.redirectToCheckout({
        sessionId: '$sessionId'
      }).then(function (result) {
        if (result.error) {
          console.error("Stripe redirect error:", result.error.message);
        } else {
          window.location.href = "/success";
        }
      });
    ''';
      executeJs(redirectToCheckoutJs);
    }
  }

  void executeJs(String jsCode) {
    if (kIsWeb) {
      final html.ScriptElement script = html.ScriptElement();
      script.type = 'application/javascript';
      script.innerHtml = jsCode;
      html.document.body!.append(script);
      debugPrint("Injected JS script into the document.");
    }
  }

  void generateOrderNumber() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    orderNumber = String.fromCharCodes(
      Iterable.generate(10, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
    debugPrint('Order Number generated: $orderNumber');
  }

  Future<void> uploadImages() async {
    final ImagePicker _picker = ImagePicker();
    debugPrint("Opening image picker...");
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        debugPrint("${images.length} image(s) selected.");
        for (var image in images) {
          Uint8List imageData = await image.readAsBytes();
          final stickerConfig = StickerConfig(
            imageData: imageData,
            size: '10x10cm',
            quantity: 1,
            confirmed: false,
          );
          addStickerConfig(stickerConfig);
          debugPrint("Image added to stickers: ${image.path}");
        }
        currentOrderStep.value = 0;
      } else {
        debugPrint("No images selected.");
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
  }

  void onPressedCalendar() {
    debugPrint("Calendar button pressed.");
    // Implement calendar-related functionality here.
  }

  void setSelectedFormatForSticker(int index, String format) {
    if (index >= 0 && index < stickers.length) {
      final sticker = stickers[index];
      sticker.size.value = format;
      final dimensions = format.replaceAll('cm', '').split('x');
      double width = double.parse(dimensions[0]);
      double height = double.parse(dimensions[1]);
      sticker.customWidth.value = width;
      sticker.customHeight.value = height;
      widthErrorText.value = '';
      heightErrorText.value = '';
      sticker.calculatePrice();
    }
  }

  void setCustomDimensionsForSticker(int index, double width, double height) {
    if (index >= 0 && index < stickers.length) {
      final sticker = stickers[index];
      width = width.clamp(0, 40);
      height = height.clamp(0, 40);
      if (width > 28 && height > 28) {
        if (width > height) {
          width = 28;
          widthErrorText.value = 'Max size exceeded. Width set to 28cm.';
        } else {
          height = 28;
          heightErrorText.value = 'Max size exceeded. Height set to 28cm.';
        }
      } else {
        widthErrorText.value = '';
        heightErrorText.value = '';
      }
      sticker.customWidth.value = width;
      sticker.customHeight.value = height;
      sticker.size.value =
          '${width.toStringAsFixed(1)}x${height.toStringAsFixed(1)}cm';
      sticker.calculatePrice();
    }
  }

  void setQuantityForSticker(int index, int quantity) {
    if (index >= 0 && index < stickers.length) {
      final sticker = stickers[index];
      sticker.quantity.value = quantity;
      sticker.calculatePrice();
    }
  }

  void showSuccessPage(String sessionId) {
    Get.defaultDialog(
      title: "Success! Your order number $orderNumber has been received.",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Items ordered:"),
          ...stickers.map((sticker) => ListTile(
                title: Text(
                    "Size: ${sticker.size.value}, Quantity: ${sticker.quantity.value}"),
                subtitle: Text(
                    "Price: €${sticker.totalPrice.value.toStringAsFixed(2)}"),
                leading: Image.memory(sticker.imageData.value,
                    width: 50, height: 50),
              )),
          Text("Order will be shipped to: $selectedAddress"),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (DateTime.now()
                .isBefore(orderCreatedTime.add(const Duration(minutes: 1)))) {
              cancelOrder();
              Get.snackbar("Order Cancelled",
                  "Your order has been cancelled successfully.");
            } else {
              Get.snackbar("Error", "Cancellation period has expired.");
            }
          },
          child: const Text("Cancel Order"),
        ),
      ],
    );
  }

  void cancelOrder() {
    stickers.clear();
    totalOrderPrice.value = 0.0;
    selectedAddress.value = '';
  }
}

class StickerConfig extends GetxController {
  Rx<Uint8List> imageData;
  RxString size;
  RxInt quantity;
  RxBool confirmed;
  RxDouble customWidth;
  RxDouble customHeight;
  RxBool isExpanded;
  RxDouble totalPrice;

  StickerConfig({
    required Uint8List imageData,
    String size = '10x10cm',
    int quantity = 1,
    bool confirmed = false,
    double customWidth = 10.0,
    double customHeight = 10.0,
    bool isExpanded = true,
  })  : imageData = imageData.obs,
        size = size.obs,
        quantity = quantity.obs,
        confirmed = confirmed.obs,
        customWidth = customWidth.obs,
        customHeight = customHeight.obs,
        isExpanded = isExpanded.obs,
        totalPrice = 0.0.obs {
    calculatePrice();
  }

  void calculatePrice() {
    final priceTable = {
      '2x2': 0.03,
      '3x3': 0.06,
      '4x4': 0.11,
      '5x5': 0.18,
      '6x6': 0.25,
      '7x7': 0.34,
      '8x8': 0.45,
      '9x9': 0.57,
      '10x10': 0.70,
      '12x12': 1.01,
      '15x15': 1.58,
      '18x18': 2.27,
      '20x20': 2.80,
      '22x22': 3.39,
      '24x24': 4.03,
      '26x26': 4.73,
      '28x28': 5.49,
    };

    String key = '${customWidth.value.toInt()}x${customHeight.value.toInt()}';
    double unitPrice;

    if (priceTable.containsKey(key)) {
      unitPrice = priceTable[key]!;
    } else {
      double area = customWidth.value * customHeight.value;
      unitPrice = (area * 0.0035) * 2;
    }

    totalPrice.value = unitPrice * quantity.value;
  }
}

class UserProfileData {
  final ImageProvider<Object> image;
  final String name;
  final String jobDesk;

  UserProfileData({
    required this.image,
    required this.name,
    required this.jobDesk,
  });
}
