import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:vendor_fixed/menu.dart';
import 'package:vendor_fixed/setting.dart';
import 'dart:ui' show ImageFilter;

final toggleProvider = StateProvider<bool>((ref) => false);

class Desh extends ConsumerStatefulWidget {
  const Desh({super.key});

  @override
  ConsumerState<Desh> createState() => _DeshState();
}

class _DeshState extends ConsumerState<Desh> {
  String? vendorId;
  Set<String> shownOrders = {};

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      vendorId = user.uid;

      FirebaseFirestore.instance
          .collection('vendors')
          .doc(vendorId)
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .listen((snapshot) {
            for (var change in snapshot.docChanges) {
              if (change.type == DocumentChangeType.added) {
                final data = change.doc.data();
                final orderId = data?['orderId'];

                if (orderId != null && !shownOrders.contains(orderId)) {
                  shownOrders.add(orderId);
                  _showNewOrderDialog(data!);
                }
              }
            }
          });
    } else {
      debugPrint("⚠️ Vendor not logged in!");
    }
  }

  void _showNewOrderDialog(Map<String, dynamic> orderData) {
    if (!mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: _ModernOrderDialog(
            orderData: orderData,
            vendorId: vendorId,
            onActionComplete: () => Navigator.pop(context),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  // Helper function to get the start and end of the most recent date
  Map<String, DateTime> _getDateRange() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return {'start': startOfDay, 'end': endOfDay};
  }

  @override
  Widget build(BuildContext context) {
    final isOn = ref.watch(toggleProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF7E5EC),
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
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF7E5EC)),
        margin: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Welcome back to KFD Restaurant",
                style: TextStyle(fontSize: 12.0, color: Colors.black),
              ),
              const SizedBox(height: 20.0),
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
                    width: 50.0,
                    height: 25.0,
                    toggleSize: 15.0,
                    value: isOn,
                    borderRadius: 30.0,
                    padding: 5.0,
                    activeToggleColor: Colors.white,
                    inactiveToggleColor: Colors.white,
                    activeColor: Colors.green,
                    inactiveColor: Colors.redAccent,
                    activeIcon: const Icon(Icons.check, color: Colors.green),
                    inactiveIcon: const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                    ),
                    onToggle: (val) {
                      ref.read(toggleProvider.notifier).state = val;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
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
                            vendorId == null
                                ? const Center(
                                    child: Text(
                                      "Vendor not logged in",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('vendors')
                                        .doc(vendorId)
                                        .collection('orders')
                                        .where(
                                          'completedAt',
                                          isGreaterThanOrEqualTo:
                                              Timestamp.fromDate(
                                                _getDateRange()['start']!,
                                              ),
                                        )
                                        .where(
                                          'completedAt',
                                          isLessThan: Timestamp.fromDate(
                                            _getDateRange()['end']!,
                                          ),
                                        )
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Today's Orders",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 25),
                                            const BlurLineLoading(),
                                            StreamBuilder<QuerySnapshot>(
                                              stream: FirebaseFirestore.instance
                                                  .collection('vendors')
                                                  .doc(vendorId)
                                                  .collection('orders')
                                                  .where(
                                                    'status',
                                                    isEqualTo: 'accepted',
                                                  )
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                int newOrders = 0;
                                                if (snapshot.hasData) {
                                                  newOrders =
                                                      snapshot.data!.docs.length;
                                                }
                                                return Text(
                                                  "$newOrders New order",
                                                  style: const TextStyle(
                                                    fontSize: 10.0,
                                                    color: Colors.black54,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                      int orderCount = 0;
                                      if (snapshot.hasData) {
                                        orderCount = snapshot.data!.docs.length;
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Today's Orders",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 25),
                                          Text(
                                            'Orders: $orderCount',
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('vendors')
                                                .doc(vendorId)
                                                .collection('orders')
                                                .where(
                                                  'status',
                                                  isEqualTo: 'accepted',
                                                )
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              int newOrders = 0;
                                              if (snapshot.hasData) {
                                                newOrders =
                                                    snapshot.data!.docs.length;
                                              }
                                              return Text(
                                                "$newOrders New order",
                                                style: const TextStyle(
                                                  fontSize: 10.0,
                                                  color: Colors.black54,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            Positioned(
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
                            vendorId == null
                                ? const Center(
                                    child: Text(
                                      "Vendor not logged in",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('vendors')
                                        .doc(vendorId)
                                        .collection('orders')
                                        .where(
                                          'completedAt',
                                          isGreaterThanOrEqualTo:
                                              Timestamp.fromDate(
                                                _getDateRange()['start']!,
                                              ),
                                        )
                                        .where(
                                          'completedAt',
                                          isLessThan: Timestamp.fromDate(
                                            _getDateRange()['end']!,
                                          ),
                                        )
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Total Revenue",
                                              style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 25),
                                            const BlurLineLoading(),
                                            const Text(
                                              "Total revenue today",
                                              style: TextStyle(
                                                fontSize: 10.0,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      double totalRevenue = 0.0;
                                      if (snapshot.hasData &&
                                          snapshot.data!.docs.isNotEmpty) {
                                        for (var doc in snapshot.data!.docs) {
                                          final data = doc.data()
                                              as Map<String, dynamic>;
                                          totalRevenue += (data['total'] ?? 0)
                                              .toDouble();
                                        }
                                      }
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Total Revenue",
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 25),
                                          Text(
                                            '₹ ${totalRevenue.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Text(
                                            "Total revenue today",
                                            style: TextStyle(
                                              fontSize: 10.0,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                            Positioned(
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
                      child: SizedBox(
                        height: 120, // fixed height
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: vendorId == null
                              ? const Center(
                                  child: Text(
                                    "Vendor not logged in",
                                    style: TextStyle(
                                        fontSize: 14.0, color: Colors.grey),
                                  ),
                                )
                              : StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('vendors')
                                      .doc(vendorId)
                                      .collection('orders')
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    // Always show content space
                                    Map<String, int> itemCount = {};
                                    String mostOrderedItem = "N/A";
                                    int maxCount = 0;

                                    if (snapshot.hasData &&
                                        snapshot.data!.docs.isNotEmpty) {
                                      for (var doc in snapshot.data!.docs) {
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        final items =
                                            data['items'] as List<dynamic>? ??
                                                [];

                                        for (var item in items) {
                                          if (item is Map<String, dynamic>) {
                                            final title = item['title']
                                                    ?.toString() ??
                                                'Unknown';
                                            final quantity = item['quantity']
                                                    is int
                                                ? item['quantity'] as int
                                                : int.tryParse(item['quantity']
                                                        ?.toString() ??
                                                    '0') ??
                                                0;
                                            itemCount[title] =
                                                (itemCount[title] ?? 0) +
                                                    quantity;
                                          }
                                        }
                                      }

                                      itemCount.forEach((key, value) {
                                        if (value > maxCount) {
                                          maxCount = value;
                                          mostOrderedItem = key;
                                        }
                                      });
                                    }

                                    return Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Most Ordered Item",
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              mostOrderedItem,
                                              style: const TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              "Total ordered quantity: $maxCount",
                                              style: const TextStyle(
                                                  fontSize: 10.0,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Icon(
                                            Icons.restaurant_menu,
                                            size: 20.0,
                                            color: Colors.amberAccent,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
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
                            Positioned(
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
              const SizedBox(height: 20.0),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                color: Colors.white.withOpacity(0.4),
                shadowColor: Colors.black.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.shopping_bag,
                                color: Colors.blueAccent,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Recent Orders (Accepted)',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              // refresh logic
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 220.0,
                        child: vendorId == null
                            ? const Center(
                                child: Text(
                                  "Vendor not logged in",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('vendors')
                                    .doc(vendorId)
                                    .collection('orders')
                                    .where('status', isEqualTo: 'accepted')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "No accepted orders yet",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  }

                                  final acceptedOrders = snapshot.data!.docs;
                                  return ListView.builder(
                                    itemCount: acceptedOrders.length,
                                    itemBuilder: (context, index) {
                                      final order = acceptedOrders[index].data()
                                          as Map<String, dynamic>;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green.shade100,
                                              Colors.green.shade50,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            15.0,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.green.withOpacity(0.1),
                                              blurRadius: 5,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          leading: CircleAvatar(
                                            backgroundColor:
                                                Colors.green.shade300,
                                            child: const Icon(
                                              Icons.receipt_long,
                                              color: Colors.white,
                                              size: 20.0,
                                            ),
                                          ),
                                          title: Text(
                                            "Order #${order['orderId']}",
                                            style: const TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Customer: ${order['customerId']}",
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              Text(
                                                "Price: ₹${order['total'] ?? 0}",
                                                style: const TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          trailing: TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.green.shade600,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('vendors')
                                                  .doc(vendorId)
                                                  .collection('orders')
                                                  .doc(order['orderId'])
                                                  .update({
                                                'status': 'completed',
                                                'completedAt':
                                                    FieldValue.serverTimestamp(),
                                              });
                                            },
                                            child: const Text(
                                              "Completed",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
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
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Menu()),
                  );
                }
                if (index == 3) {
                  Navigator.push(
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

// Custom loading widget with two blurred lines effect
class BlurLineLoading extends StatefulWidget {
  const BlurLineLoading({Key? key}) : super(key: key);

  @override
  _BlurLineLoadingState createState() => _BlurLineLoadingState();
}

class _BlurLineLoadingState extends State<BlurLineLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22.0, // Match the height of the revenue Text widget
      width: 100.0, // Approximate width for the loading effect
      child: Stack(
        children: [
          // Background blurred line (softer blur)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation.value * 100, 0),
                child: Container(
                  height: 10,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(),
                    ),
                  ),
                ),
              );
            },
          ),
          // Foreground blurred line (harder blur)
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset((1 - _animation.value) * 100, 0),
                child: Container(
                  height: 10,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModernOrderDialog extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String? vendorId;
  final VoidCallback onActionComplete;

  const _ModernOrderDialog({
    required this.orderData,
    this.vendorId,
    required this.onActionComplete,
  });

  @override
  __ModernOrderDialogState createState() => __ModernOrderDialogState();
}

class __ModernOrderDialogState extends State<_ModernOrderDialog>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isAccepted = false;
  bool _isRejected = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(-100.0, 100.0);
      _isAccepted = _dragPosition > 80;
      _isRejected = _dragPosition < -80;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragPosition.abs() > 80) {
      if (_dragPosition > 0) {
        _isAccepted = true;
        FirebaseFirestore.instance
            .collection('vendors')
            .doc(widget.vendorId)
            .collection('orders')
            .doc(widget.orderData['orderId'])
            .update({'status': 'accepted'});
      } else {
        _isRejected = true;
        FirebaseFirestore.instance
            .collection('vendors')
            .doc(widget.vendorId)
            .collection('orders')
            .doc(widget.orderData['orderId'])
            .update({'status': 'rejected'});
      }
      _controller.forward().then((_) {
        widget.onActionComplete();
      });
    } else {
      setState(() {
        _dragPosition = 0.0;
        _isAccepted = false;
        _isRejected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData arrowIcon;
    Color sliderColor;
    if (_dragPosition > 0) {
      arrowIcon = Icons.arrow_forward_ios;
      sliderColor = Colors.green.withOpacity(
        (_dragPosition / 100).clamp(0.3, 1.0),
      );
    } else if (_dragPosition < 0) {
      arrowIcon = Icons.arrow_back_ios;
      sliderColor = Colors.red.withOpacity(
        ((-_dragPosition) / 100).clamp(0.3, 1.0),
      );
    } else {
      arrowIcon = Icons.arrow_forward_ios;
      sliderColor = Colors.white;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '🚀 New Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: widget.onActionComplete,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: ${widget.orderData['orderId'] ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total: ₹${widget.orderData['total'] ?? 0}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Customer: ${widget.orderData['customerId'] ?? 'Unknown'}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isRejected ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Text(
                          'Accept',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isAccepted ? Colors.green : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_dragPosition * _animation.value, 0),
                      child: GestureDetector(
                        onHorizontalDragUpdate: _handleDragUpdate,
                        onHorizontalDragEnd: _handleDragEnd,
                        child: Container(
                          width: 60,
                          height: 40,
                          decoration: BoxDecoration(
                            color: sliderColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            arrowIcon,
                            color: _isAccepted || _isRejected
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Slide to accept or reject',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}