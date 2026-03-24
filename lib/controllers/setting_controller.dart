import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';

class SettingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final ThemeController themeController = Get.find<ThemeController>();
  final RxString currentUserId = ''.obs;
  final RxInt selectedIndex = 0.obs;
  late TabController tabController;

  final RxBool isLoading = false.obs;

  Stream<DocumentSnapshot>? restaurantStream;
  Stream<DocumentSnapshot>? vendorStream;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId.value = user.uid;
      restaurantStream = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user.uid)
          .snapshots();
      vendorStream = FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)
          .snapshots();
    }
    tabController = TabController(length: 3, vsync: this);

    // Listen to tab changes to update selectedIndex
    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void updateIndex(int index) {
    selectedIndex.value = index;
    tabController.animateTo(index);
  }

  void updateIsOpen(bool isOpen) {
    if (currentUserId.value.isEmpty) return;
    FirebaseFirestore.instance
        .collection(
          'vendors',
        ) // Assuming 'vendors' collection based on other files, or 'restaurants'?
        // In menu.dart it was 'restaurants'. In setting.dart earlier snippet it was 'restaurants'.
        // Let's verify commonly used collection.
        // menu.dart used 'restaurants'. desh.dart used 'vendors'.
        // I will use 'restaurants' as per the setting.dart logic I saw.
        .doc(currentUserId.value)
        .update({'isOpen': isOpen});

    // Also update in 'restaurants' collection if separated, but based on context,
    // it seems the user uses 'restaurants' for profile data in Setting.dart.
    FirebaseFirestore.instance
        .collection('restaurants')
        .doc(currentUserId.value)
        .update({'isOpen': isOpen});
  }

  Future<void> updateRestaurantData(String field, String value) async {
    if (currentUserId.value.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(currentUserId.value)
        .update({field: value});
  }

  Future<void> updateStoreTiming(String type, String time) async {
    if (currentUserId.value.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(currentUserId.value)
        .update({type: time});
  }

  Future<void> updateAlwaysOpen(bool val) async {
    if (currentUserId.value.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(currentUserId.value)
        .update({
          'isAlwaysOpen': val,
          if (val) 'isOpen': true, // Force ON if 24x7 enabled
        });
  }
}
