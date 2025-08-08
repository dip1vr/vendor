import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_item.dart';
import 'providers.dart';
import 'add_menu.dart'; 
import 'order.dart';
import 'desh.dart';
import 'setting.dart';

class Menu extends ConsumerWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final isSwitched = ref.watch(toggleProvider);
    final menuList = ref.watch(menuListProvider);

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
                    // Navigate to AddMenu screen
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
                            // You can add search logic later here
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
          
                // Display dynamic menu cards 
                ...menuList.map((item) {
                  return Card(
                    key: ValueKey(item.name),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("Category: ${item.category}"),
                                ],
                              ),
                              const Icon(Icons.visibility, color: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Description",
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹ ${item.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(item.isActive ? "On" : "Off"),
                                  Transform.scale(
                                    scale: 0.7,
                                    child: Switch(
                                      value: item.isActive,
                                      onChanged: (val) {
                                        final updatedList = [...menuList];
                                        final index = updatedList.indexOf(item);
                                        updatedList[index] = MenuItem(
                                          name: item.name,
                                          category: item.category,
                                          description: item.description,
                                          price: item.price,
                                          isActive: val,
                                        );
                                        ref
                                                .read(menuListProvider.notifier)
                                                .state =
                                            updatedList;
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: Colors.orangeAccent,
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
                                      borderRadius: BorderRadius.circular(12),
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
                                  // Remove item from the list
                                  final updatedList = [...menuList];
                                  updatedList.remove(item);
                                  ref.read(menuListProvider.notifier).state =
                                      updatedList;
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
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
                }),
              ],
            ),
          ),
        ),
      ),

      // Bottom navigation
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
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Order()),
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
