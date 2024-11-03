// My dashboard_controller.dart
// Do not remove this comment text when giving me the new code.

import 'dart:typed_data';

import 'package:daily_task/app/shared_components/task_progress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  DashboardController() {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() async {
    debugPrint("Initializing Google Sign-In...");
    _googleSignIn.onCurrentUserChanged.listen((account) {
      user.value = account;
      debugPrint("User signed in: ${account?.displayName ?? "None"}");
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

  Future<void> signInWithGoogle() async {
    try {
      debugPrint("Attempting Google Sign-In...");
      await _googleSignIn.signIn();
    } catch (error) {
      debugPrint("Google Sign-In error: $error");
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      debugPrint("Attempting to sign out...");
      await _googleSignIn.disconnect();
      user.value = null;
      userProfile.value = null;
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
    if (isPrintMode.value) {
      stickers.clear();
      debugPrint("Stickers list cleared.");
    }
  }

  void addStickerConfig(StickerConfig stickerConfig) {
    stickers.add(stickerConfig);
    debugPrint("Sticker added: ${stickerConfig.toString()}");
  }

  void removeStickerConfig(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers.removeAt(index);
      debugPrint("Sticker at index $index removed.");
    } else {
      debugPrint("Invalid index for sticker removal: $index");
    }
  }

  void confirmStickerSettings(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers[index].confirmed.value = true;
      debugPrint("Sticker settings confirmed for index $index");
    } else {
      debugPrint("Invalid index for confirming sticker settings: $index");
    }
  }

  void editStickerSettings(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers[index].confirmed.value = false;
      debugPrint("Sticker settings set to editable for index $index");
    } else {
      debugPrint("Invalid index for editing sticker settings: $index");
    }
  }

  void proceedWithOrder() {
    debugPrint("Proceeding with order for ${stickers.length} stickers...");
    for (var sticker in stickers) {
      debugPrint("Sticker Config: ${sticker.toString()}");
    }
    // Proceed with order processing logic here
  }

  Future<void> uploadImages() async {
    final ImagePicker _picker = ImagePicker();
    debugPrint("Opening image picker...");
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          Uint8List imageData = await image.readAsBytes();
          final stickerConfig = StickerConfig(
            imageData: imageData,
            size: '10x10cm',
            quantity: 1,
            confirmed: false,
          );
          addStickerConfig(stickerConfig);
          debugPrint("Image selected: ${image.path}");
        }
      } else {
        debugPrint("No images selected.");
      }
    } catch (e) {
      debugPrint("Error picking images: $e");
    }
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
      debugPrint("Sticker at index $index size set to: $format");
    }
  }

  void setCustomDimensionsForSticker(int index, double width, double height) {
    if (index >= 0 && index < stickers.length) {
      final sticker = stickers[index];

      // Apply constraints
      width = width.clamp(0, 40);
      height = height.clamp(0, 40);

      if (width > 28 && height > 28) {
        if (width > height) {
          width = 28;
          widthErrorText.value =
              'Max combined size exceeded. Width set to 28cm.';
        } else {
          height = 28;
          heightErrorText.value =
              'Max combined size exceeded. Height set to 28cm.';
        }
      } else {
        widthErrorText.value = '';
        heightErrorText.value = '';
      }

      sticker.customWidth.value = width;
      sticker.customHeight.value = height;
      sticker.size.value =
          '${width.toStringAsFixed(1)}x${height.toStringAsFixed(1)}cm';
      debugPrint(
          "Sticker at index $index custom dimensions set to: ${sticker.size.value}");
    }
  }

  void setQuantityForSticker(int index, int quantity) {
    if (index >= 0 && index < stickers.length) {
      final sticker = stickers[index];
      sticker.quantity.value = quantity;
      debugPrint("Sticker at index $index quantity set to: $quantity");
    }
  }

  void onPressedProfil() {}
  void onSelectedMainMenu(int index, SelectionButtonData value) {}
  void onPressedTask(int index, ListTaskAssignedData data) {}
  void onPressedAssignTask(int index, ListTaskAssignedData data) {}
  void onPressedMemberTask(int index, ListTaskAssignedData data) {}
  void onPressedCalendar() {}

  void openDrawer() {
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
        isExpanded = isExpanded.obs;

  @override
  String toString() {
    return 'StickerConfig(size: ${size.value}, quantity: ${quantity.value}, confirmed: ${confirmed.value})';
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
