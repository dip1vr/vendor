import 'package:get/get.dart';
import 'package:flutter/material.dart'; // For Colors, TextEditingController
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';

class MenuController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString currentUserId = ''.obs;

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _simulateLoading();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId.value = user.uid;
    }
    searchController.addListener(() {
      searchQuery.value = searchController.text.toLowerCase();
    });
  }

  void _simulateLoading() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void toggleItemStatus(String itemId, bool newValue) {
    if (currentUserId.value.isEmpty) return;
    FirebaseFirestore.instance
        .collection('restaurants')
        .doc(currentUserId.value)
        .collection('menuItems')
        .doc(itemId)
        .update({'isActive': newValue});
  }

  void deleteItem(String itemId) {
    if (currentUserId.value.isEmpty) return;
    Get.defaultDialog(
      title: "Delete Item",
      middleText: "Are you sure you want to delete this item?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: const Color(0xFFFFFFFF),
      buttonColor: const Color(0xFFFF5252),
      onConfirm: () {
        FirebaseFirestore.instance
            .collection('restaurants')
            .doc(currentUserId.value)
            .collection('menuItems')
            .doc(itemId)
            .delete();
        Get.back(); // Close dialog
      },
    );
  }

  Future<void> saveItemOffer(
    String itemId,
    Map<String, dynamic> offerData,
  ) async {
    if (currentUserId.value.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(currentUserId.value)
          .collection('menuItems')
          .doc(itemId)
          .update({'offer': offerData});
      Get.snackbar(
        "Success",
        "Offer updated successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update offer: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteItemOffer(String itemId) async {
    if (currentUserId.value.isEmpty) return;
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(currentUserId.value)
          .collection('menuItems')
          .doc(itemId)
          .update({'offer': FieldValue.delete()});
      Get.snackbar(
        "Success",
        "Offer removed successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to remove offer: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
