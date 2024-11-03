// My dashboard_controller.dart
// Do not remove this comment text when giving me the new code.

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:daily_task/app/shared_components/task_progress.dart';

class DashboardController extends GetxController {
  final scafoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '545461705793-3v0101rqbcp0hqkeiqt0ohca9me9d0b3.apps.googleusercontent.com',
  );

  final Rx<UserProfileData?> userProfile = Rx<UserProfileData?>(null);
  final dataTask = const TaskProgressData(totalTask: 5, totalCompleted: 1);
  Rx<GoogleSignInAccount?> user = Rx<GoogleSignInAccount?>(null);
  RxBool isDarkMode = false.obs;
  RxBool isPrintMode = false.obs;
  RxList<StickerConfig> stickers = <StickerConfig>[].obs;
  RxInt currentStickerIndex = (-1).obs;

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
      currentStickerIndex.value = -1;
      debugPrint("Stickers list cleared.");
    }
  }

  void addStickerConfig(StickerConfig stickerConfig) {
    stickers.add(stickerConfig);
    currentStickerIndex.value = stickers.length - 1;
    debugPrint("Sticker added: ${stickerConfig.toString()}");
  }

  void removeStickerConfig(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers.removeAt(index);
      debugPrint("Sticker at index $index removed.");
      if (currentStickerIndex.value >= stickers.length) {
        currentStickerIndex.value = stickers.length - 1;
      }
    } else {
      debugPrint("Invalid index for sticker removal: $index");
    }
  }

  void confirmStickerSettings(int index) {
    if (index >= 0 && index < stickers.length) {
      stickers[index].confirmed = true;
      debugPrint("Sticker settings confirmed for index $index");
    } else {
      debugPrint("Invalid index for confirming sticker settings: $index");
    }
  }

  void proceedWithOrder() {
    debugPrint("Proceeding with order for ${stickers.length} stickers...");
    for (var sticker in stickers) {
      debugPrint("Sticker Config: ${sticker.toString()}");
    }
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
      stickers[index].size = format;
      debugPrint("Sticker at index $index size set to: $format");
    }
  }

  void setCustomDimensionsForSticker(int index, double width, double height) {
    if (index >= 0 && index < stickers.length) {
      stickers[index].customWidth = width;
      stickers[index].customHeight = height;
      stickers[index].size =
          '${width.toStringAsFixed(1)}x${height.toStringAsFixed(1)}cm';
      debugPrint(
          "Sticker at index $index custom dimensions set to: ${stickers[index].size}");
    }
  }

  void setQuantityForSticker(int index, int quantity) {
    if (index >= 0 && index < stickers.length) {
      stickers[index].quantity = quantity;
      debugPrint("Sticker at index $index quantity set to: $quantity");
    }
  }

  void onPressedProfil() {}
  void onSelectedMainMenu(int index, SelectionButtonData value) {}
  void onPressedTask(int index, ListTaskAssignedData data) {}
  void onPressedAssignTask(int index, ListTaskAssignedData data) {}
  void onPressedMemberTask(int index, ListTaskAssignedData data) {}
  void onPressedCalendar() {}
  void onPressedTaskGroup(int index, ListTaskDateData data) {}

  void openDrawer() {
    scafoldKey.currentState?.openDrawer();
  }
}

class StickerConfig {
  Uint8List imageData;
  String size;
  int quantity;
  bool confirmed;
  double customWidth;
  double customHeight;

  StickerConfig({
    required this.imageData,
    this.size = '10x10cm',
    this.quantity = 1,
    this.confirmed = false,
    this.customWidth = 10.0,
    this.customHeight = 10.0,
  });

  @override
  String toString() {
    return 'StickerConfig(size: $size, quantity: $quantity, confirmed: $confirmed)';
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
