import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';

class OrderController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();
  final RxString vendorId = ''.obs;
  final RxString selectedFilter = 'All'.obs;

  Stream<QuerySnapshot> get ordersStream {
    if (vendorId.value.isEmpty) {
      return const Stream.empty();
    }

    Query query = FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorId.value)
        .collection('orders');

    if (selectedFilter.value != 'All') {
      query = query.where(
        'status',
        isEqualTo: selectedFilter.value.toLowerCase(),
      );
    }

    // Sort logic depends on compound indexes.
    // To be safe and simple without complex index creation for every status filter,
    // we can stream all and filter/sort client side or rely on default ordering if created.
    // However, usually one wants to order by time.
    // For now, let's just return the query and let the client list sort it or add orderBy if indexes exist.
    // Adding orderBy('createdAt', descending: true) usually requires an index for each filter combo.
    return query.snapshots();
  }

  @override
  void onInit() {
    super.onInit();
    _checkVendor();
  }

  void _checkVendor() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      vendorId.value = user.uid;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
}
