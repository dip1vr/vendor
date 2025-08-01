import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:vendor_fixed/menu.dart';

import 'order.dart';

class Desh extends StatefulWidget {
  const Desh({super.key});

  @override
  State<Desh> createState() => _DeshState();
}

class _DeshState extends State<Desh> {
  bool ison = true;

  // Mock order data (replace with backend fetch)
  final List<Map<String, String>> orders = [
    {'id': '1234', 'customer': 'John Doe', 'status': 'Pending'},
    {'id': '1235', 'customer': 'Jane Smith', 'status': 'Accepted'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E5EC), // Cream color
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7E5EC),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7E5EC), // Cream color
        ),
        margin: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Welcome Text
              const Text(
                "Welcome back to KFD Restaurant",
                style: TextStyle(fontSize: 12.0, color: Colors.black),
              ),
              const SizedBox(height: 20.0),
              // Restaurant Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Restaurant Status",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  FlutterSwitch(
                    width: 50.0, // Increased size for better usability
                    height: 25.0,
                    toggleSize: 15.0,
                    value: ison,
                    borderRadius: 30.0,
                    padding: 5.0,
                    activeToggleColor: Colors.white,
                    inactiveToggleColor: Colors.white,
                    activeColor: Colors.green,
                    inactiveColor: Colors.redAccent,
                    activeIcon: const Icon(Icons.check, color: Colors.green),
                    inactiveIcon: const Icon(Icons.close, color: Colors.redAccent),
                    onToggle: (val) {
                      setState(() {
                        ison = val;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // Existing Cards (Orders, Revenue, etc.)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.blue[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Today's Orders",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Text(
                                      '10',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "1 new order",
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.shopping_cart,
                                    size: 20.0,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Card(
                          color: Colors.yellow[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Total Revenue",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Text(
                                      'Rp 9,000', // Formatted currency
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Total revenue today",
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.attach_money,
                                    size: 20.0,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.green[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Most Ordered Item",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Text(
                                      'Samosa',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Most ordered item today",
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    size: 20.0,
                                    color: Colors.amberAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Card(
                          color: Colors.indigo[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4.0,
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Restaurant Status",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 25),
                                    Text(
                                      'Open',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Time: 10:00 AM - 11:00 PM",
                                      style: TextStyle(
                                        fontSize: 10.0,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                                const Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Icon(
                                    Icons.power_settings_new,
                                    size: 20.0,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              // New: Recent Orders Section
              Card(
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Orders',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      SizedBox(
                        height: 150.0, // Fixed height for list
                        child: ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: const Icon(Icons.fastfood),
                              title: Text('Order #${orders[index]['id']}'),
                              subtitle: Text('Customer: ${orders[index]['customer']}'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Handle order action (e.g., accept)
                                },
                                child: Text(orders[index]['status']!),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              // New: Settings Button
              
            ],
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
              boxShadow: [
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
                  backgroundColor: Color(0xFFEDE7F6),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long, color: Colors.green),
                  label: 'Orders',
                  backgroundColor: Color(0xFFE8F5E9),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book, color: Colors.cyan),
                  label: 'Menu',
                  backgroundColor: Color(0xFFEDE7F6),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: Colors.amber),
                  label: 'Settings',
                  backgroundColor: Color(0xFFFFF8E1),
                ),
              ],
              currentIndex: 0,
              onTap: (index) {
                // Handle navigation logic here
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Order()),
                  );
                }
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Menu()),
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