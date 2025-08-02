import 'package:flutter/material.dart';
import 'package:vendor_fixed/order.dart';
import 'package:vendor_fixed/desh.dart';

class Menu extends StatefulWidget {
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E5EC), // Cream background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7E5EC),
        title: const Text(
          'Order Page',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.all(8.0),
        color: const Color(0xFFF7E5EC), // Match background here too
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Menu Management",
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Manage your restaurant menu item",
              style: TextStyle(color: Colors.black, fontSize: 14),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                minimumSize: Size(500, 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text("+ Add Menu"),
            ),
            SizedBox(height: 10),
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
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.orangeAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "  All Categories",
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
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
                              "Margereted pizza",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text("Category: pizza"),
                          ],
                        ),
                        Icon(Icons.visibility, color: Colors.green),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text("Discraption ", style: TextStyle(fontSize: 14)),
                    Text(
                      "chizz pizza , salad, souce puch , onine, origeno",
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹ 120",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(isSwitched ? "On" : "Off"),
                            Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                value: isSwitched,
                                onChanged: (value) {
                                  setState(() {
                                    isSwitched = value;
                                  });
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
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 180,
                          height: 30,
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.edit),
                            label: Text(
                              "data",
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
                                side: BorderSide(
                                  color: Colors.grey,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        TextButton.icon(
                          onPressed: () {
                            print('Delete pressed');
                          },
                          icon: Icon(Icons.delete, color: Colors.red),
                          label: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: TextButton.styleFrom(
                            side: BorderSide(
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
            ),
          ],
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
              currentIndex: 2, // Menu tab
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Desh()),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Order()),
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
