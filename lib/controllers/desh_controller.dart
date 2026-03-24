import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:get/get.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';

class DeshController extends GetxController {
  // Dependencies
  final ThemeController themeController = Get.find<ThemeController>();

  // State
  final RxBool isOnline = false.obs;
  final RxString vendorId = ''.obs;
  final Rx<Map<String, dynamic>?> newOrderData = Rx<Map<String, dynamic>?>(
    null,
  );

  // Track shown orders to prevent duplicates
  final Set<String> _shownOrders = {};

  // Streams/Subscriptions
  StreamSubscription? _orderSubscription;
  StreamSubscription? _vendorSubscription;
  Timer? _schedulerTimer;

  @override
  void onInit() {
    super.onInit();
    _checkVendor();
  }

  void _checkVendor() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      vendorId.value = user.uid;
      _listenToNewOrders();
      _listenToVendorProfile(); // Realtime Sync
      _startAutoScheduler();
    }
  }

  void _listenToVendorProfile() {
    if (vendorId.value.isEmpty) return;
    _vendorSubscription?.cancel(); // Cancel existing
    _vendorSubscription = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(vendorId.value)
        .snapshots()
        .listen((doc) {
          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            if (data['isOpen'] != null) {
              isOnline.value = data['isOpen'];
            }
          }
        });
  }

  void _listenToNewOrders() {
    if (vendorId.value.isEmpty) return;

    _orderSubscription?.cancel(); // Cancel existing
    _shownOrders.clear(); // Clear tracked orders on restart
    bool isFirstLoad = true;

    _orderSubscription = FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId.value)
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
          if (isFirstLoad) {
            // On initial load, just mark existing pending orders as shown
            // so we don't bombard the user with popups for old orders
            for (var doc in snapshot.docs) {
              final orderId = doc.data()['orderId'];
              if (orderId != null) {
                _shownOrders.add(orderId);
              }
            }
            isFirstLoad = false;
            return;
          }

          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data();
              final orderId = data?['orderId'];

              if (orderId != null && !_shownOrders.contains(orderId)) {
                _shownOrders.add(orderId);
                newOrderData.value = data; // Trigger dialog show
              }
            }
          }
        });
  }

  void _startAutoScheduler() {
    // Check every minute for specific trigger times
    _schedulerTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _runScheduleCheck(),
    );
  }

  Future<void> _runScheduleCheck() async {
    if (vendorId.value.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(vendorId.value)
          .get();

      if (!doc.exists) return;
      final data = doc.data()!;

      // Get scheduled times
      final isAlwaysOpen = data['isAlwaysOpen'] == true;

      // 24x7 Logic: Enforce ON
      if (isAlwaysOpen) {
        if (data['isOpen'] != true) {
          await _updateStatus(true);
          print("Auto-Schedule: Enforced 24x7 Open");
        }
        return; // Skip event checks
      }

      final openTime = data['openingTime'] ?? "09:00";
      final closeTime = data['closingTime'] ?? "22:00";

      final now = TimeOfDay.now();
      final nowStr =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Event Logic: Only trigger at the exact minute match
      if (nowStr == openTime) {
        if (data['isOpen'] != true) {
          await _updateStatus(true);
          print("Auto-Schedule: Opened Store at $nowStr");
        }
      } else if (nowStr == closeTime) {
        if (data['isOpen'] != false) {
          await _updateStatus(false);
          print("Auto-Schedule: Closed Store at $nowStr");
        }
      }
    } catch (e) {
      print("Scheduler Error: $e");
    }
  }

  Future<void> _updateStatus(bool isOpen) async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(vendorId.value)
        .update({'isOpen': isOpen});

    // Also update UI state immediately logic is handled by _syncInitialStatus or listener usually,
    // but explicit update here ensures responsiveness if listener lags.
    isOnline.value = isOpen;
  }

  void toggleOnline(bool val) {
    // Manual Toggle directly updates 'isOpen'.
    // Scheduler will only interfere if/when the next time event occurs.
    isOnline.value = val;
    if (vendorId.value.isNotEmpty) {
      _updateStatus(val);
    }
  }

  void clearNewOrder() {
    newOrderData.value = null;
  }

  @override
  void onClose() {
    _orderSubscription?.cancel();
    _vendorSubscription?.cancel();
    _schedulerTimer?.cancel();
    super.onClose();
  }

  // Helper for Date Ranges (migrated from Desh)
  Map<String, DateTime> getDateRange() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return {'start': startOfDay, 'end': endOfDay};
  }
}
