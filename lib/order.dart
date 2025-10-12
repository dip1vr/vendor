import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendor_fixed/desh.dart';
import 'package:vendor_fixed/menu.dart';
import 'package:vendor_fixed/setting.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? vendorId;
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      vendorId = user.uid;
    }
  }

  // Firestore query based on filter
  Stream<QuerySnapshot> _getOrders() {
    final baseQuery = FirebaseFirestore.instance
        .collection("vendors")
        .doc(vendorId)
        .collection("orders");
       
    if (selectedFilter == "All") return baseQuery.snapshots();

    return baseQuery
        .where("status", isEqualTo: selectedFilter.toLowerCase())
        .snapshots();
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order["orderId"] ?? "N/A";
    final customerId = order["customerId"] ?? "Unknown";
    final total = order["total"] ?? 0;
    final items = (order["items"] ?? []) as List<dynamic>;
    

    final status = order["status"] ?? "pending";

    // Status color and label
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case "accepted":
        statusColor = Colors.blue;
        statusLabel = "Accepted";
        statusIcon = Icons.check_circle;
        break;
      case "completed":
        statusColor = Colors.green;
        statusLabel = "Completed";
        statusIcon = Icons.done_all;
        break;
      case "rejected":
        statusColor = Colors.red;
        statusLabel = "Cancelled";
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = status.capitalize(); // helper
        statusIcon = Icons.hourglass_empty;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Order ID: $orderId",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("Customer: $customerId", style: const TextStyle(fontSize: 12)),
                  ],
                ),
                Card(
                  color: Colors.white54,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 12),
                        const SizedBox(width: 5),
                        Text(statusLabel,
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Items
            Text("Items:", style: const TextStyle(fontSize: 14)),
const SizedBox(height: 5),

items.isNotEmpty
    ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(items.length, (index) {
          final item = items[index] as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              "${item['title']} x${item['quantity']}  -  ₹${item['price']}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          );
        }),
      )
    : const Text("No items"),

const SizedBox(height: 10),

            // Total
            Text("Total Amount: ₹$total",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00D1B2), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Orders",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("Manage your orders here",
                          style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Filters
              SingleChildScrollView(
              
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (var filter in ["All", "Accepted", "Completed", "Rejected"])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedFilter == filter
                                ? Colors.deepPurpleAccent
                                : Colors.grey[300],
                            foregroundColor: selectedFilter == filter
                                ? Colors.white
                                : Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(filter,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Orders List
              Expanded(
                child: vendorId == null
                    ? const Center(child: Text("Vendor not logged in"))
                    : StreamBuilder<QuerySnapshot>(
                        stream: _getOrders(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text("No orders found"));
                          }
                          final orders = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: orders.length,
                            itemBuilder: (context, index) {
                              final order =
                                  orders[index].data() as Map<String, dynamic>;
                              return _buildOrderCard(order);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepPurpleAccent,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard), label: "Dashboard"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long), label: "Orders"),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: "Menu"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Settings"),
            ],
            currentIndex: 1,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Desh()),
                    (route) => false);
              } else if (index == 2) {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Menu()));
              } else if (index == 3) {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const Setting()));
              }
            },
          ),
        ),
      ),
    );
  }
}

// Extension helper for status capitalize
extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}  