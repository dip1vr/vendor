import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_item.dart';
 // ✅ Make sure to import model

final priceProvider = StateProvider<double>((ref) => 0.0);

final platformFeeProvider = Provider<double>((ref) {
  final price = ref.watch(priceProvider);
  return price * 0.15;
});

final earningProvider = Provider<double>((ref) {
  final price = ref.watch(priceProvider);
  final fee = price * 0.15;
  return price - fee;
});

/// ✅ New: Menu list provider
final menuListProvider = StateProvider<List<MenuItem>>((ref) => []);
