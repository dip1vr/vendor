  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:get/get.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'menu_item.dart';
  import 'providers.dart';

  class AddMenu extends ConsumerWidget {
    AddMenu({Key? key}) : super(key: key);

    final TextEditingController nameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    static const double platformFeePercent = 0.15; // 15%
    static const double gstPercent = 0.05; // 5%

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final price = ref.watch(priceProvider);

      // Calculate commission and GST dynamically from priceProvider state
      final commission = price * platformFeePercent;
      final gstAmount = price * gstPercent;
      final earning = price - commission + gstAmount;

      Future<void> submitMenuItem() async {
        final name = nameController.text.trim();
        final category = categoryController.text.trim();
        final description = descriptionController.text.trim();
        final priceVal = double.tryParse(priceController.text.trim()) ?? 0;

        if (name.isEmpty ||
            category.isEmpty ||
            description.isEmpty ||
            priceVal <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill all fields correctly")),
          );
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not logged in")),
          );
          return;
        }

        final newItem = MenuItem(
           id: '',
          name: name,
          category: category,
          description: description,
          price: priceVal,
        );

        try {
          await FirebaseFirestore.instance
              .collection("restaurants")
              .doc(user.uid)
              .collection("menuItems")
              .add({
            "name": name,
            "category": category,
            "description": description,
            "price": priceVal,
            "commission": priceVal * platformFeePercent,
            "gst": priceVal * gstPercent,
            "earning": priceVal - (priceVal * platformFeePercent) + (priceVal * gstPercent),
            "createdAt": FieldValue.serverTimestamp(),
          });

          // Update local menu list state (optional)
          ref.read(menuListProvider.notifier).state = [
            ...ref.read(menuListProvider),
            newItem,
          ];

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Menu item uploaded successfully")),
          );

          Get.back();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      }

      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "🍚 Create Menu Item",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Add a new item to your restaurant menu",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Item Name
                const Text(
                  "Item Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter dish name",
                    hintStyle: const TextStyle(color: Colors.black26),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Category
                const Text(
                  "Category",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    hintText: "Choose category of dish",
                    hintStyle: const TextStyle(color: Colors.black26),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Description
                const Text(
                  "Description",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Enter short dish description",
                    hintStyle: const TextStyle(color: Colors.black26),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Price
                const Text(
                  "Dish Price (What customer pay)",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsed = double.tryParse(value) ?? 0.0;
                    ref.read(priceProvider.notifier).state = parsed;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Price (₹)",
                    hintStyle: const TextStyle(color: Colors.black26),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // earning Breakdown UI
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF3FE),
                    border: Border.all(color: Colors.cyan, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.calculate, color: Colors.lightBlue),
                          SizedBox(width: 10),
                          Text(
                            "Earning Breakdown",
                            style: TextStyle(
                              color: Color.fromARGB(255, 3, 101, 182),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Menu Price:", style: TextStyle(color: Colors.blue)),
                          Text("₹${price.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.blue)),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Platform Fee (15%):", style: TextStyle(color: Colors.blue)),
                          Text("₹${commission.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.redAccent)),
                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("GST (5%):", style: TextStyle(color: Colors.blue)),
                          Text("₹${gstAmount.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.green)),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Colors.blue, thickness: 0.5),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("You Earn:", style: TextStyle(color: Colors.blue)),
                          Text("₹${earning.toStringAsFixed(2)}",
                              style: const TextStyle(color: Color(0xFF1ABC00))),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        "📌 Customer pays ₹${price.toStringAsFixed(2)}, platform fee ₹${commission.toStringAsFixed(2)}, GST ₹${gstAmount.toStringAsFixed(2)}. You earn ₹${earning.toStringAsFixed(2)}",
                        style: const TextStyle(color: Color(0xFF0365B6)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: submitMenuItem,
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
