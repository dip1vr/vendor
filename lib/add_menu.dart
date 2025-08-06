import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_item.dart';// <-- Add this import, create this model as explained before
import 'providers.dart';

class AddMenu extends ConsumerWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  AddMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final price = ref.watch(priceProvider);
    final platformFee = ref.watch(platformFeeProvider);
    final earnings = ref.watch(earningProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SafeArea(
                  child: Text(
                    "🍚 Create Menu Item",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Add a new item to your restaurant menu ",
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              SizedBox(height: 20),
              Text(
                "Item Name",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Enter dish name ",
                  hintStyle: TextStyle(color: Colors.black26),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Category",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  hintText: "Choose category of dish",
                  hintStyle: TextStyle(color: Colors.black26),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Description",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Enter short dish description",
                  hintStyle: TextStyle(color: Colors.black26),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Dish Price (What customer pay)",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final parsed = double.tryParse(value) ?? 0.0;
                  ref.read(priceProvider.notifier).state = parsed;
                },
                decoration: InputDecoration(
                  hintText: "Enter Price (₹)",
                  hintStyle: TextStyle(color: Colors.black26),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 500,
                decoration: BoxDecoration(
                  color: Color(0xFFEDF3FE),
                  border: Border.all(
                    color: Colors.cyan,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
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
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Menu Price:", style: TextStyle(color: Colors.blue)),
                          Text("₹${price.toStringAsFixed(2)}",
                              style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Platform Fee (15%):",
                              style: TextStyle(color: Colors.blue)),
                          Text("₹${platformFee.toStringAsFixed(2)}",
                              style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                      SizedBox(height: 20),
                      Divider(color: Colors.blue, thickness: 0.5),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("You Earn:", style: TextStyle(color: Colors.blue)),
                          Text("₹${earnings.toStringAsFixed(2)}",
                              style: TextStyle(color: Color(0xFF1ABC00))),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        "📌 Customer will pay ₹${price.toStringAsFixed(2)} and you will receive ₹${earnings.toStringAsFixed(2)} after platform fee",
                        style: TextStyle(color: Color(0xFF0365B6)),
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final category = categoryController.text.trim();
                  final description = descriptionController.text.trim();
                  final price = double.tryParse(priceController.text.trim()) ?? 0;

                  if (name.isEmpty ||
                      category.isEmpty ||
                      description.isEmpty ||
                      price == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill all fields correctly")),
                    );
                    return;
                  }

                  final newItem = MenuItem(
                    name: name,
                    category: category,
                    description: description,
                    price: price,
                  );

                  ref.read(menuListProvider.notifier).state = [
                    ...ref.read(menuListProvider),
                    newItem,
                  ];

                  Navigator.pop(context);
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
