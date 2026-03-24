import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';

class OfferController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();
  final RxString currentUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId.value = user.uid;
    }
  }

  Future<void> toggleOfferStatus(DocumentReference ref, bool isActive) async {
    await ref.update({'isActive': isActive});
  }

  Future<void> deleteOffer(DocumentReference ref) async {
    await ref.delete();
  }

  Future<void> forceActivate(DocumentReference ref) async {
    await ref.update({'startDate': FieldValue.serverTimestamp()});
  }

  Future<void> saveOffer({
    required String? docId,
    required Map<String, dynamic> data,
  }) async {
    if (currentUserId.value.isEmpty) return;

    CollectionReference offersRef = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(currentUserId.value)
        .collection('offers');

    if (docId != null) {
      await offersRef.doc(docId).update(data);
    } else {
      await offersRef.add(data);
    }
  }
}
