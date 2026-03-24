import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_fixed/controllers/desh_controller.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';
import 'package:vendor_fixed/offer_management.dart';
import 'package:vendor_fixed/widgets/shimmer_loading.dart';

class Desh extends StatelessWidget {
  const Desh({super.key});

  @override
  Widget build(BuildContext context) {
    // dependency injection
    final DeshController controller = Get.put(DeshController());
    final ThemeController themeController = controller.themeController;

    // Listen for new orders to show dialog
    ever(controller.newOrderData, (data) {
      if (data != null) {
        _showNewOrderDialog(
          context,
          data,
          controller.vendorId.value,
          themeController,
        );
      }
    });

    return Obx(
      () => Stack(
        children: [
          // 1. Background (Theme Aware)
          Positioned.fill(
            child: _AnimatedGradientBackground(
              colors: themeController.backgroundGradient,
            ),
          ),

          // 2. Main Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Header
                  _buildHeader(controller, themeController),

                  const SizedBox(height: 30),

                  // Stats Grid
                  _buildStatsGrid(controller, themeController),

                  const SizedBox(height: 30),

                  // Active Orders
                  Text(
                    "Active Orders",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeController.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActiveOrders(controller, themeController),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewOrderDialog(
    BuildContext context,
    Map<String, dynamic> orderData,
    String vendorId,
    ThemeController themeController,
  ) {
    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: "Order",
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: _ModernOrderDialog(
            orderData: orderData,
            vendorId: vendorId,
            onActionComplete: () => Get.back(),
            themeController: themeController,
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Widget _buildHeader(
    DeshController controller,
    ThemeController themeController,
  ) {
    // Removed _FadeSlideTransition
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back,",
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: themeController.secondaryText,
              ),
            ),
          ],
        ),
        Obx(
          () => _GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: 30,
            color: themeController.glassColor,
            borderColor: themeController.glassBorderColor,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isOnline.value
                        ? Colors.green
                        : Colors.red,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (controller.isOnline.value
                                    ? Colors.green
                                    : Colors.red)
                                .withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  controller.isOnline.value ? "Online" : "Offline",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: controller.isOnline.value
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
    DeshController controller,
    ThemeController themeController,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              // Removed _FadeSlideTransition
              child: _buildOrderStatCard(controller, themeController),
            ),
            const SizedBox(width: 16),
            Expanded(
              // Removed _FadeSlideTransition
              child: _buildRevenueStatCard(controller, themeController),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              // Removed _FadeSlideTransition
              child: _buildMostOrderedCard(controller, themeController),
            ),
            const SizedBox(width: 16),
            Expanded(
              // Removed _FadeSlideTransition
              child: _buildLatestOfferCard(controller, themeController),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLatestOfferCard(
    DeshController controller,
    ThemeController themeController,
  ) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const OfferManagement());
      },
      child: _GlassCard(
        icon: Icons.local_offer_outlined,
        iconColor: Colors.deepOrangeAccent,
        title: "Latest Offer",
        themeController: themeController,
        child: Obx(() {
          if (controller.vendorId.value.isEmpty)
            return ShimmerWidgets.latestOfferCard();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('restaurants')
                .doc(controller.vendorId.value)
                .collection('offers')
                .orderBy('createdAt', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ShimmerWidgets.latestOfferCard();
              }
              if (!snapshot.hasData) return ShimmerWidgets.latestOfferCard();
              if (snapshot.data!.docs.isEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Create Offer",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: themeController.primaryText,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: themeController.secondaryText,
                    ),
                  ],
                );
              }

              final data =
                  snapshot.data!.docs.first.data() as Map<String, dynamic>;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'Offer',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: themeController.primaryText,
                          ),
                        ),
                        Text(
                          data['code'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepOrangeAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepOrangeAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      "Manage",
                      style: GoogleFonts.outfit(
                        color: Colors.deepOrangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildOrderStatCard(
    DeshController controller,
    ThemeController themeController,
  ) {
    return _GlassCard(
      icon: Icons.shopping_bag_outlined,
      iconColor: themeController.iconColor,
      title: "Today's Orders",
      themeController: themeController,
      child: Obx(() {
        if (controller.vendorId.value.isEmpty)
          return ShimmerWidgets.statsCard();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vendors')
              .doc(controller.vendorId.value)
              .collection('orders')
              .where(
                'completedAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                  controller.getDateRange()['start']!,
                ),
              )
              .where(
                'completedAt',
                isLessThan: Timestamp.fromDate(
                  controller.getDateRange()['end']!,
                ),
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerWidgets.statsCard();
            }
            if (!snapshot.hasData) return ShimmerWidgets.statsCard();
            int orderCount = snapshot.data!.docs.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$orderCount',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeController.primaryText,
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildRevenueStatCard(
    DeshController controller,
    ThemeController themeController,
  ) {
    return _GlassCard(
      icon: Icons.attach_money,
      iconColor: Colors.green,
      title: "Revenue",
      themeController: themeController,
      child: Obx(() {
        if (controller.vendorId.value.isEmpty)
          return ShimmerWidgets.statsCard();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vendors')
              .doc(controller.vendorId.value)
              .collection('orders')
              .where(
                'completedAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(
                  controller.getDateRange()['start']!,
                ),
              )
              .where(
                'completedAt',
                isLessThan: Timestamp.fromDate(
                  controller.getDateRange()['end']!,
                ),
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerWidgets.statsCard();
            }
            if (!snapshot.hasData) return ShimmerWidgets.statsCard();
            double totalRevenue = 0.0;
            for (var doc in snapshot.data!.docs) {
              totalRevenue +=
                  ((doc.data() as Map<String, dynamic>)['total'] ?? 0)
                      .toDouble();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹${totalRevenue.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: themeController.primaryText,
                  ),
                ),
                Text(
                  "Today",
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.green),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildMostOrderedCard(
    DeshController controller,
    ThemeController themeController,
  ) {
    return _GlassCard(
      icon: Icons.star_border,
      iconColor: Colors.amber,
      title: "Trending Item",
      themeController: themeController,
      child: Obx(() {
        if (controller.vendorId.value.isEmpty)
          return ShimmerWidgets.statsCard();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('vendors')
              .doc(controller.vendorId.value)
              .collection('orders')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerWidgets.statsCard();
            }
            if (!snapshot.hasData) return ShimmerWidgets.statsCard();

            // Logic same as original
            Map<String, int> itemCount = {};
            int maxCount = 0;
            String mostOrderedItem = "None";

            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final items = data['items'] as List<dynamic>? ?? [];
              for (var item in items) {
                if (item is Map<String, dynamic>) {
                  final title = item['title']?.toString() ?? 'Unknown';
                  final quantity =
                      int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
                  itemCount[title] = (itemCount[title] ?? 0) + quantity;
                }
              }
            }
            itemCount.forEach((key, value) {
              if (value > maxCount) {
                maxCount = value;
                mostOrderedItem = key;
              }
            });

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mostOrderedItem,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: themeController.primaryText,
                        ),
                      ),
                      Text(
                        "$maxCount sold all time",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: themeController.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildActiveOrders(
    DeshController controller,
    ThemeController themeController,
  ) {
    // Removed _FadeSlideTransition
    return Obx(() {
      if (controller.vendorId.value.isEmpty) {
        return Center(
          child: Text(
            "Login required",
            style: TextStyle(color: themeController.primaryText),
          ),
        );
      }

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vendors')
            .doc(controller.vendorId.value)
            .collection('orders')
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Using YouTube-style skeleton list for active orders
            return Column(
              children: List.generate(
                3,
                (index) => ShimmerWidgets.dashboardOrderSkeleton(),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _GlassContainer(
              height: 100,
              color: themeController.glassColor,
              borderColor: themeController.glassBorderColor,
              child: Center(
                child: Text(
                  "No active orders pending",
                  style: GoogleFonts.outfit(
                    color: themeController.secondaryText,
                  ),
                ),
              ),
            );
          }

          final orders = snapshot.data!.docs;
          // Client-side sorting
          orders.sort((a, b) {
            final dataA = a.data() as Map<String, dynamic>;
            final dataB = b.data() as Map<String, dynamic>;
            final timeA =
                (dataA['acceptedAt'] as Timestamp?)?.toDate() ??
                (dataA['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now();
            final timeB =
                (dataB['acceptedAt'] as Timestamp?)?.toDate() ??
                (dataB['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.now();
            return timeB.compareTo(timeA);
          });

          return ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _ActiveOrderCard(
                  key: ValueKey(order['orderId']),
                  order: order,
                  vendorId: controller.vendorId.value,
                  themeController: themeController,
                ),
              );
            },
          );
        },
      );
    });
  }
}

// --- HELPER WIDGETS ---

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;

  const _GlassContainer({
    required this.child,
    this.padding,
    this.width,
    this.height,
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
          width: width,
          height: height,
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

class _GlassCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final ThemeController? themeController;

  const _GlassCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final tController = themeController ?? Get.find<ThemeController>();
    return _GlassContainer(
      padding: const EdgeInsets.all(16),
      color: tController.glassColor,
      borderColor: tController.glassBorderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: tController.secondaryText,
                ),
              ),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
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

class _ModernOrderDialog extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String? vendorId;
  final VoidCallback onActionComplete;
  final ThemeController themeController;

  const _ModernOrderDialog({
    required this.orderData,
    required this.vendorId,
    required this.onActionComplete,
    required this.themeController,
  });

  @override
  State<_ModernOrderDialog> createState() => _ModernOrderDialogState();
}

class _ModernOrderDialogState extends State<_ModernOrderDialog> {
  // Slider state
  double _sliderValue =
      0.0; // -1.0 to 1.0. Negative = reject, Positive = accept
  double _dragExtent = 0.0;
  final double _sliderWidth = 280.0;
  final double _knobSize = 50.0;
  final double _threshold = 0.4; // 40% of travel needed to trigger
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    // Determine max drag distance (from center to either side)
    final double maxTravel = (_sliderWidth - _knobSize) / 2;

    final orderId = widget.orderData['orderId'] ?? 'Unknown';
    // Customer Info
    final customerName = widget.orderData['customerName'] ?? 'Unknown Customer';
    final customerPhone = widget.orderData['customerPhone'] ?? 'No Phone';
    final customerProfileImage = widget.orderData['customerProfileImage'];
    final deliveryAddress = widget.orderData['deliveryAddress'] ?? 'No Address';

    // Financials
    final total = (widget.orderData['total'] ?? 0).toDouble();
    final subTotal = (widget.orderData['subTotal'] ?? total).toDouble();
    final discount = (widget.orderData['discount'] ?? 0).toDouble();
    final tax = (widget.orderData['tax'] ?? 0).toDouble();
    final deliveryCharge = (widget.orderData['deliveryCharge'] ?? 0).toDouble();

    // Items
    final items = (widget.orderData['items'] as List<dynamic>? ?? []);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF141414), // Dark background
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text("🚀", style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "New Order #$orderId",
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onActionComplete,
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Scrollable Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Details Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer Profile Row
                            Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withValues(
                                      alpha: 0.1,
                                    ),
                                    shape: BoxShape.circle,
                                    image:
                                        customerProfileImage != null &&
                                            customerProfileImage.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                              customerProfileImage,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child:
                                      customerProfileImage == null ||
                                          customerProfileImage.isEmpty
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.blueAccent,
                                          size: 24,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        customerName,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        customerPhone,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                                height: 1,
                              ),
                            ),
                            // Address
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    deliveryAddress,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Order Items List
                      Text(
                        "Items",
                        style: GoogleFonts.outfit(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...items.map<Widget>((item) {
                        final i = item as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00E676,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00E676,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  "${i['quantity']}x",
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFF00E676),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  i['title'] ?? 'Unknown Item',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "₹${i['price']}",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 8),
                      Divider(color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 12),

                      // Bill Details
                      _buildBillRow("Subtotal", "₹$subTotal"),
                      if (discount > 0)
                        _buildBillRow(
                          "Discount",
                          "-₹$discount",
                          valueColor: const Color(0xFFFF5252),
                        ),
                      if (tax > 0) _buildBillRow("Tax", "₹$tax"),
                      if (deliveryCharge > 0)
                        _buildBillRow("Delivery", "₹$deliveryCharge"),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "₹$total",
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF00E676),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Slider Area
              if (_isProcessing)
                const SizedBox(
                  height: 60,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF00E676)),
                  ),
                )
              else
                SizedBox(
                  width: _sliderWidth,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Track
                      Container(
                        width: _sliderWidth,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 24.0),
                              child: Text(
                                "Reject",
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 24.0),
                              child: Text(
                                "Accept",
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withOpacity(0.3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Central Text
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: (_dragExtent.abs() / maxTravel > 0.1)
                            ? 0.0
                            : 1.0,
                        child: Text(
                          "Slide to accept or reject",
                          style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                          ),
                        ),
                      ),

                      // Draggable Knob
                      Align(
                        alignment: Alignment.center,
                        child: Transform.translate(
                          offset: Offset(_dragExtent, 0),
                          child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              setState(() {
                                _dragExtent += details.delta.dx;
                                _dragExtent = _dragExtent.clamp(
                                  -maxTravel,
                                  maxTravel,
                                );
                                _sliderValue = _dragExtent / maxTravel;
                              });
                            },
                            onHorizontalDragEnd: (details) async {
                              if (_sliderValue > _threshold) {
                                // Accepted
                                setState(() {
                                  _dragExtent = maxTravel;
                                  _isProcessing = true;
                                });
                                await _handleAccept();
                              } else if (_sliderValue < -_threshold) {
                                // Rejected
                                setState(() {
                                  _dragExtent = -maxTravel;
                                  _isProcessing = true;
                                });
                                await _handleReject();
                              } else {
                                // Snap back
                                setState(() {
                                  _dragExtent = 0.0;
                                  _sliderValue = 0.0;
                                });
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: _knobSize,
                              height: _knobSize,
                              decoration: BoxDecoration(
                                color: _sliderValue > 0.1
                                    ? Colors.green.withOpacity(
                                        (_sliderValue.abs()).clamp(0.4, 1.0),
                                      )
                                    : _sliderValue < -0.1
                                    ? Colors.red.withOpacity(
                                        (_sliderValue.abs()).clamp(0.4, 1.0),
                                      )
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_sliderValue > 0.1
                                                ? Colors.green
                                                : _sliderValue < -0.1
                                                ? Colors.red
                                                : Colors.white)
                                            .withOpacity(0.3),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _sliderValue < -0.1
                                    ? Icons.keyboard_arrow_left
                                    : Icons.keyboard_arrow_right,
                                color: _sliderValue.abs() > 0.1
                                    ? Colors.white
                                    : Colors.black,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: valueColor ?? Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccept() async {
    if (widget.vendorId == null) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _dragExtent = 0;
          _sliderValue = 0;
        });
      }
      return;
    }

    try {
      // Use a timeout to prevent infinite loading on network issues
      await FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.vendorId)
          .collection('orders')
          .doc(widget.orderData['orderId'])
          .update({
            'status': 'accepted',
            'acceptedAt': FieldValue.serverTimestamp(),
          })
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint("Error accepting order: $e");
      // Optionally show error toast here
    } finally {
      if (mounted) {
        widget.onActionComplete();
      }
    }
  }

  Future<void> _handleReject() async {
    // Currently just ignoring/closing as per original implementation preference,
    // but visual feedback was "Reject".
    // If actual reject logic is needed later, we can add database update here.
    // For now, it just closes the dialog effectively treating it as "Ignore".
    if (mounted) widget.onActionComplete();
  }
}

class _ActiveOrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final String vendorId;
  final ThemeController themeController;

  const _ActiveOrderCard({
    super.key,
    required this.order,
    required this.vendorId,
    required this.themeController,
  });

  @override
  State<_ActiveOrderCard> createState() => _ActiveOrderCardState();
}

class _ActiveOrderCardState extends State<_ActiveOrderCard> {
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final items = (order['items'] as List<dynamic>? ?? []);
    final total = (order['total'] ?? 0).toDouble();
    final isPrepaid = order['isPrepaid'] ?? false;

    // Updated data extraction based on usage
    final customerName = order['customerName'] ?? 'Unknown Customer';
    final customerPhone = order['customerPhone'] ?? 'No Phone';
    final customerProfileImage = order['customerProfileImage'];
    final deliveryAddress = order['deliveryAddress'] ?? 'No Address';

    final discount = (order['discount'] ?? 0).toDouble();
    final subTotal = (order['subTotal'] ?? total).toDouble();

    return _GlassContainer(
      padding: const EdgeInsets.all(16),
      color: widget.themeController.glassColor,
      borderColor: widget.themeController.glassBorderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${order['orderId']}",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.themeController.primaryText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPrepaid
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isPrepaid
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  isPrepaid ? "Prepaid" : "COD",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPrepaid ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  image:
                      customerProfileImage != null &&
                          customerProfileImage.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(customerProfileImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    customerProfileImage == null || customerProfileImage.isEmpty
                    ? Icon(
                        Icons.person_outline,
                        color: Colors.blueAccent,
                        size: 24,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.themeController.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customerPhone,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: widget.themeController.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deliveryAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: widget.themeController.secondaryText.withOpacity(
                          0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: widget.themeController.dividerColor),
          ),
          ...items.map<Widget>((item) {
            final i = item as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${i['quantity']}x  ${i['title']}",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: widget.themeController.primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "₹${i['price']}",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.themeController.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.themeController.isDarkMode.value
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (discount > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subtotal",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: widget.themeController.secondaryText,
                        ),
                      ),
                      Text(
                        "₹$subTotal",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: widget.themeController.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Discount",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "- ₹$discount",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 12, color: Colors.white12),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Amount",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.themeController.primaryText,
                      ),
                    ),
                    Text(
                      "₹$total",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.themeController.primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCompleting
                  ? null
                  : () async {
                      setState(() => _isCompleting = true);
                      try {
                        await FirebaseFirestore.instance
                            .collection('vendors')
                            .doc(widget.vendorId)
                            .collection('orders')
                            .doc(order['orderId'])
                            .update({
                              'status': 'completed',
                              'completedAt': FieldValue.serverTimestamp(),
                            });
                      } catch (e) {
                        debugPrint("Error completing order: $e");
                        setState(() => _isCompleting = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: Colors.green.withValues(alpha: 0.4),
              ),
              child: _isCompleting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Mark as Completed",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
