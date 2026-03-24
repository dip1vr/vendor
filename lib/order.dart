import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_fixed/controllers/order_controller.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';
import 'package:vendor_fixed/widgets/shimmer_loading.dart';

class Order extends StatelessWidget {
  const Order({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());
    final ThemeController themeController = controller.themeController;

    return Obx(
      () => Stack(
        children: [
          // 1. Background Gradient
          _AnimatedGradientBackground(
            colors: themeController.backgroundGradient,
          ),

          // 2. Main Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Header
                _buildHeader(controller, themeController),

                const SizedBox(height: 20),

                // Filters
                _buildFilters(controller, themeController),

                const SizedBox(height: 20),

                // Orders List
                Expanded(
                  child: controller.vendorId.value.isEmpty
                      ? Center(
                          child: Text(
                            "Vendor not logged in",
                            style: GoogleFonts.outfit(
                              color: themeController.primaryText,
                            ),
                          ),
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: controller.ordersStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: 5,
                                itemBuilder: (context, index) =>
                                    ShimmerWidgets.orderHistorySkeleton(),
                              );
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 48,
                                      color: themeController.secondaryText,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No orders found",
                                      style: GoogleFonts.outfit(
                                        color: themeController.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            final orders = snapshot.data!.docs;
                            // Client-side sorting because we removed OrderBy to prevent index issues
                            orders.sort((a, b) {
                              final dataA = a.data() as Map<String, dynamic>;
                              final dataB = b.data() as Map<String, dynamic>;
                              final timeA =
                                  (dataA['acceptedAt'] as Timestamp?)
                                      ?.toDate() ??
                                  (dataA['createdAt'] as Timestamp?)
                                      ?.toDate() ??
                                  DateTime.now();
                              final timeB =
                                  (dataB['acceptedAt'] as Timestamp?)
                                      ?.toDate() ??
                                  (dataB['createdAt'] as Timestamp?)
                                      ?.toDate() ??
                                  DateTime.now();
                              return timeB.compareTo(timeA);
                            });
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount:
                                  orders.length + 1, // +1 for spacing at bottom
                              itemBuilder: (context, index) {
                                if (index == orders.length) {
                                  return const SizedBox(
                                    height: 100,
                                  ); // Bottom padding for nav bar
                                }
                                final order =
                                    orders[index].data()
                                        as Map<String, dynamic>;
                                return _buildOrderCard(order, themeController);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    OrderController controller,
    ThemeController themeController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Orders",
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeController.primaryText,
                ),
              ),
              Text(
                "Manage your orders",
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: themeController.secondaryText,
                ),
              ),
            ],
          ),
          _GlassContainer(
            padding: const EdgeInsets.all(10),
            borderRadius: 14,
            color: themeController.glassColor,
            borderColor: themeController.glassBorderColor,
            child: Icon(
              Icons.filter_list,
              color: Colors.deepOrangeAccent,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    OrderController controller,
    ThemeController themeController,
  ) {
    final filters = ["All", "Accepted", "Completed", "Rejected"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: filters.map((filter) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  controller.setFilter(filter);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.deepOrangeAccent
                        : themeController.glassColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? Colors.deepOrangeAccent
                          : themeController.glassBorderColor,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.deepOrangeAccent.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    filter,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : themeController.secondaryText,
                    ),
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildOrderCard(
    Map<String, dynamic> order,
    ThemeController themeController,
  ) {
    final orderId = order["orderId"] ?? "N/A";
    final total = order["total"] ?? 0;
    final items = (order["items"] ?? []) as List<dynamic>;
    final status = order["status"] ?? "pending";

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case "accepted":
        statusColor = Colors.blueAccent;
        statusLabel = "Accepted";
        statusIcon = Icons.check_circle_outline;
        break;
      case "completed":
        statusColor = Colors.green;
        statusLabel = "Completed";
        statusIcon = Icons.task_alt;
        break;
      case "rejected":
        statusColor = Colors.redAccent;
        statusLabel = "Cancelled";
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.orangeAccent;
        statusLabel = status.capitalize();
        statusIcon = Icons.hourglass_empty;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: _GlassContainer(
        padding: const EdgeInsets.all(16),
        color: themeController.glassColor,
        borderColor: themeController.glassBorderColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ID: $orderId",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeController.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Customer: ${order['customerName'] ?? order['customerId'] ?? 'Unknown'}",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: themeController.secondaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (order['customerPhone'] != null)
                        Text(
                          "Phone: ${order['customerPhone']}",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: themeController.secondaryText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: GoogleFonts.outfit(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: themeController.dividerColor),
            ),

            Text(
              "Items:",
              style: GoogleFonts.outfit(
                color: themeController.secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),

            items.isNotEmpty
                ? Column(
                    children: List.generate(items.length, (index) {
                      final item = items[index] as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${item['title']} x${item['quantity']}",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: themeController.primaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "₹${item['price']}",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: themeController.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  )
                : Text(
                    "No items",
                    style: GoogleFonts.outfit(
                      color: themeController.secondaryText,
                    ),
                  ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Total:",
                  style: GoogleFonts.outfit(
                    color: themeController.secondaryText,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "₹$total",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
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

// --- SHARED UI WIDGETS ---

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AnimatedGradientBackground extends StatefulWidget {
  final List<Color>? colors;
  const _AnimatedGradientBackground({this.colors});
  @override
  State<_AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<_AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _topAlignmentAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    ).animate(_controller);
    _bottomAlignmentAnimation = Tween<Alignment>(
      begin: Alignment.bottomRight,
      end: Alignment.bottomLeft,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _topAlignmentAnimation.value,
            end: _bottomAlignmentAnimation.value,
            colors:
                widget.colors ??
                const [Color(0xFF141414), Color(0xFF1E1E1E), Color(0xFF141414)],
          ),
        ),
      ),
    );
  }
}
