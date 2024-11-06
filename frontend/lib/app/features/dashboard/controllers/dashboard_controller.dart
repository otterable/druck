// My lib/app/dashboard_controller.dart
// Do not remove this comment text when giving me the new code.

import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'package:daily_task/app/shared_components/task_progress.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
      debugPrint("User account changed: ${account?.displayName ?? "None"}");
      if (account != null) {
        userProfile.value = UserProfileData(
          image: account.photoUrl != null
              ? NetworkImage(account.photoUrl!) as ImageProvider<Object>
              : const AssetImage('assets/images/raster/man.png'),
          name: account.displayName ?? "User",
          jobDesk: account.email,
        );
        debugPrint("User profile updated: ${userProfile.value?.name}");
      } else {
        userProfile.value = null;
        debugPrint("User signed out.");
      }
    });
    await _googleSignIn.signInSilently();
    debugPrint("Sign-in silently attempted.");
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
    debugPrint("Sticker added: ${stickerConfig.toString()}");
    calculateTotalPrice();
  }

  void removeStickerConfig(int index) {
    if (index >= 0 && index < stickers.length) {
      debugPrint("Removing sticker at index $index...");
      stickers.removeAt(index);
      debugPrint("Sticker at index $index removed.");
      calculateTotalPrice();
    } else {
      debugPrint("Invalid index for sticker removal: $index");
    }
  }

  void confirmStickerSettings(int index) {
    if (index >= 0 && index < stickers.length) {
      debugPrint("Confirming sticker settings at index $index...");
      stickers[index].confirmed.value = true;
      debugPrint("Sticker settings confirmed for index $index");
      calculateTotalPrice();
    } else {
      debugPrint("Invalid index for confirming sticker settings: $index");
    }
  }

  void editStickerSettings(int index) {
    if (index >= 0 && index < stickers.length) {
      debugPrint("Editing sticker settings at index $index...");
      stickers[index].confirmed.value = false;
      showOrderSummary.value = false;
      debugPrint("Sticker settings set to editable for index $index");
    } else {
      debugPrint("Invalid index for editing sticker settings: $index");
    }
  }

  void proceedToOrderSummary() {
    debugPrint("Proceeding to order summary...");
    showOrderSummary.value = true;
    calculateTotalPrice();
  }

  void calculateTotalPrice() {
    debugPrint("Calculating total order price...");
    double total = 0.0;
    for (var sticker in stickers) {
      total += sticker.totalPrice.value;
      debugPrint(
          "Added sticker price: €${sticker.totalPrice.value.toStringAsFixed(2)}");
    }
    totalOrderPrice.value = total;
    debugPrint(
        "Total order price: €${totalOrderPrice.value.toStringAsFixed(2)}");
  }

  void proceedWithOrder() {
    debugPrint("Proceeding with order...");
    if (stickers.isEmpty) {
      debugPrint("No stickers to order.");
      Get.snackbar(
          'No Stickers', 'Please add stickers to proceed with the order.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    bool allConfirmed = stickers.every((sticker) => sticker.confirmed.value);
    if (!allConfirmed) {
      debugPrint("Not all stickers are confirmed.");
      Get.snackbar('Unconfirmed Stickers',
          'Please confirm all stickers before proceeding.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    proceedToOrderSummary();
    debugPrint("All stickers confirmed. Moving to order summary.");
  }

  Future<void> initiatePayment() async {
    isLoading.value = true;
    debugPrint("Initiating payment...");

    try {
      final List<Map<String, dynamic>> lineItems = stickers.map((sticker) {
        return {
          "name": "Sticker ${sticker.size.value}",
          "amount": (sticker.totalPrice.value * 100).toInt(),
          "quantity": sticker.quantity.value,
        };
      }).toList();

      final url = Uri.parse('http://localhost:4242/create-checkout-session');
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"items": lineItems}));

      if (response.statusCode == 200) {
        final sessionId = jsonDecode(response.body)['id'];
        redirectToCheckout(sessionId);
      } else {
        debugPrint("Failed to create checkout session: ${response.body}");
      }
    } catch (e) {
      debugPrint("Payment Error: $e");
      Get.snackbar('Payment Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void redirectToCheckout(String sessionId) {
    if (kIsWeb) {
      final String redirectToCheckoutJs = '''
        var stripe = Stripe('pk_test_your_publishable_key');
        stripe.redirectToCheckout({
          sessionId: '$sessionId'
        }).then(function (result) {
          if (result.error) {
            console.error(result.error.message);
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

  void setSelectedFormatForSticker(int index, String format) {
    if (index >= 0 && index < stickers.length) {
      debugPrint(
          "Setting selected format for sticker at index $index to $format...");
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
      debugPrint("Sticker at index $index size set to: $format");
    } else {
      debugPrint("Invalid index for setting sticker format: $index");
    }
  }

  void setCustomDimensionsForSticker(int index, double width, double height) {
    if (index >= 0 && index < stickers.length) {
      debugPrint("Setting custom dimensions for sticker at index $index...");
      final sticker = stickers[index];

      width = width.clamp(0, 40);
      height = height.clamp(0, 40);
      debugPrint("Clamped dimensions: width=$width, height=$height");

      if (width > 28 && height > 28) {
        if (width > height) {
          width = 28;
          widthErrorText.value =
              'Max combined size exceeded. Width set to 28cm.';
          debugPrint(widthErrorText.value);
        } else {
          height = 28;
          heightErrorText.value =
              'Max combined size exceeded. Height set to 28cm.';
          debugPrint(heightErrorText.value);
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
      debugPrint(
          "Sticker at index $index custom dimensions set to: ${sticker.size.value}");
    } else {
      debugPrint("Invalid index for setting custom dimensions: $index");
    }
  }

  void setQuantityForSticker(int index, int quantity) {
    if (index >= 0 && index < stickers.length) {
      debugPrint(
          "Setting quantity for sticker at index $index to $quantity...");
      final sticker = stickers[index];
      sticker.quantity.value = quantity;
      sticker.calculatePrice();
      debugPrint("Sticker at index $index quantity set to: $quantity");
    } else {
      debugPrint("Invalid index for setting sticker quantity: $index");
    }
  }

  void onPressedProfil() {
    debugPrint("Profile button pressed.");
  }

  void onSelectedMainMenu(int index, SelectionButtonData value) {
    debugPrint("Main menu item selected: index=$index, value=$value");
  }

  void onPressedTask(int index, ListTaskAssignedData data) {
    debugPrint("Task pressed: index=$index, data=$data");
  }

  void onPressedAssignTask(int index, ListTaskAssignedData data) {
    debugPrint("Assign Task pressed: index=$index, data=$data");
  }

  void onPressedMemberTask(int index, ListTaskAssignedData data) {
    debugPrint("Member Task pressed: index=$index, data=$data");
  }

  void onPressedCalendar() {
    debugPrint("Calendar button pressed.");
  }

  void openDrawer() {
    debugPrint("Opening drawer...");
    scafoldKey.currentState?.openDrawer();
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
    debugPrint("Calculating price for sticker...");
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
      debugPrint("Price from price table: €$unitPrice");
    } else {
      double area = customWidth.value * customHeight.value;
      unitPrice = (area * 0.0035) * 2;
      debugPrint("Calculated price based on area: €$unitPrice");
    }

    totalPrice.value = unitPrice * quantity.value;
    debugPrint(
        "Total price for sticker: €${totalPrice.value.toStringAsFixed(2)}");
  }

  @override
  String toString() {
    return 'StickerConfig(size: ${size.value}, quantity: ${quantity.value}, confirmed: ${confirmed.value}, price: €${totalPrice.value.toStringAsFixed(2)})';
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

class SelectionButtonData {}

class ListTaskAssignedData {}

class ListTaskDateData {}