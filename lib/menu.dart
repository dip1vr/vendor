import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_menu.dart';
import 'menu_item.dart';
import 'desh.dart';
import 'setting.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E5EC),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: const Color(0xFFF7E5EC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Menu Management",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Manage your restaurant menu item",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddMenu()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(500, 25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text("+ Add Menu"),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 30,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search menu item',
                              hintStyle: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.orangeAccent,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "  All Categories",
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Live Firestore data with search filter
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('restaurants')
                      .doc(currentUserId)
                      .collection('menuItems')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No menu items found.");
                    }
                    final menuItems = snapshot.data!.docs.where((doc) {
                      final data = doc.data()! as Map<String, dynamic>;
                      final name = data['name']?.toString().toLowerCase() ?? '';
                      final category =
                          data['category']?.toString().toLowerCase() ?? '';
                      return name.contains(_searchQuery) ||
                          category.contains(_searchQuery);
                    }).toList();

                    if (menuItems.isEmpty) {
                      return const Text("No matching menu items found.");
                    }

                    return Column(
                      children: menuItems.map((doc) {
                        final data = doc.data()! as Map<String, dynamic>;
                        return Card(
                          key: ValueKey(doc.id),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Category: ${data['category'] ?? ''}",
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.visibility,
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Description",
                                  style: TextStyle(fontSize: 14),
                                ),
                                Text(
                                  data['description'] ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "₹${(data['price'] ?? 0).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          data['isActive'] == true
                                              ? "On"
                                              : "Off",
                                        ),
                                        Transform.scale(
                                          scale: 0.7,
                                          child: Switch(
                                            value: data['isActive'] ?? false,
                                            onChanged: (val) {
                                              FirebaseFirestore.instance
                                                  .collection('restaurants')
                                                  .doc(currentUserId)
                                                  .collection('menuItems')
                                                  .doc(doc.id)
                                                  .update({'isActive': val});
                                            },
                                            activeColor: Colors.white,
                                            activeTrackColor:
                                                Colors.orangeAccent,
                                            inactiveThumbColor: Colors.grey,
                                            inactiveTrackColor: Colors.black26,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      height: 30,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          final menuItem = MenuItem(
                                            id: doc.id,
                                            name: data['name'] ?? '',
                                            category: data['category'] ?? '',
                                            description:
                                                data['description'] ?? '',
                                            price: (data['price'] ?? 0)
                                                .toDouble(),
                                            isActive: data['isActive'] ?? true,
                                          );

                                          final nameController =
                                              TextEditingController(
                                            text: menuItem.name,
                                          );
                                          final categoryController =
                                              TextEditingController(
                                            text: menuItem.category,
                                          );
                                          final descriptionController =
                                              TextEditingController(
                                            text: menuItem.description,
                                          );
                                          final priceController =
                                              TextEditingController(
                                            text: menuItem.price.toString(),
                                          );
                                          bool listenerAdded = false;

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  if (!listenerAdded) {
                                                    priceController
                                                        .addListener(() {
                                                      setState(() {});
                                                    });
                                                    listenerAdded = true;
                                                  }

                                                  return AlertDialog(
                                                    title:
                                                        const Text('Edit Menu Item'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          TextField(
                                                            controller:
                                                                nameController,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Item Name',
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          TextField(
                                                            controller:
                                                                categoryController,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Category',
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          TextField(
                                                            controller:
                                                                descriptionController,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Description',
                                                            ),
                                                            maxLines: 3,
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          TextField(
                                                            controller:
                                                                priceController,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText:
                                                                  'Price (₹)',
                                                            ),
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            'GST (5%): ₹${(0.05 * (double.tryParse(priceController.text) ?? 0)).toStringAsFixed(2)}',
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            'Platform Fee (15%): ₹${(0.15 * (double.tryParse(priceController.text) ?? 0)).toStringAsFixed(2)}',
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            'Earning (Price + 5% GST - 15% Platform Fee): ₹${(0.90 * (double.tryParse(priceController.text) ?? 0)).toStringAsFixed(2)}',
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black54),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          final newName =
                                                              nameController
                                                                  .text
                                                                  .trim();
                                                          final newCategory =
                                                              categoryController
                                                                  .text
                                                                  .trim();
                                                          final newDescription =
                                                              descriptionController
                                                                  .text
                                                                  .trim();
                                                          final newPrice = double
                                                                  .tryParse(
                                                                      priceController
                                                                          .text
                                                                          .trim()) ??
                                                              0;
                                                          final newGst =
                                                              newPrice *
                                                                  0.05; // 5% GST
                                                          final newPlatformFee =
                                                              newPrice *
                                                                  0.15; // 15% Platform Fee
                                                          final newEarning =
                                                              newPrice *
                                                                  0.90; // Price + 5% GST - 15% Platform Fee

                                                          if (newName
                                                                  .isEmpty ||
                                                              newCategory
                                                                  .isEmpty ||
                                                              newDescription
                                                                  .isEmpty ||
                                                              newPrice <= 0) {
                                                            ScaffoldMessenger.of(
                                                                    context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Please fill all fields correctly and ensure price is positive'),
                                                              ),
                                                            );
                                                            return;
                                                          }

                                                          try {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'restaurants')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                                .collection(
                                                                    'menuItems')
                                                                .doc(menuItem.id)
                                                                .update({
                                                              'name': newName,
                                                              'category':
                                                                  newCategory,
                                                              'description':
                                                                  newDescription,
                                                              'price': newPrice,
                                                              'gst': newGst,
                                                              'platformFee':
                                                                  newPlatformFee,
                                                              'earning':
                                                                  newEarning,
                                                              'updatedAt':
                                                                  FieldValue
                                                                      .serverTimestamp(),
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .pop();

                                                            ScaffoldMessenger.of(
                                                                    context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Menu item updated successfully'),
                                                              ),
                                                            );
                                                          } catch (e) {
                                                            ScaffoldMessenger.of(
                                                                    context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Error updating item: $e'),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        child:
                                                            const Text('Update'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                        icon: const Icon(Icons.edit),
                                        label: const Text(
                                          "Edit",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          iconColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            side: const BorderSide(
                                              color: Colors.grey,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    TextButton.icon(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('restaurants')
                                            .doc(currentUserId)
                                            .collection('menuItems')
                                            .doc(doc.id)
                                            .delete();
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      label: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      style: TextButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.grey,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.deepPurpleAccent,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard, color: Colors.deepPurpleAccent),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long, color: Colors.green),
                  label: 'Orders',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book, color: Colors.cyan),
                  label: 'Menu',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: Colors.amber),
                  label: 'Settings',
                ),
              ],
              currentIndex: 2,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Desh()),
                  );
                } else if (index == 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Setting()),
                  );
                }
              },
              elevation: 0,
              showUnselectedLabels: true,
            ),
          ),
        ),
      ),
    );
  }
}