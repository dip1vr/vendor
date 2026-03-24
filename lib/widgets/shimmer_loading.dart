import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';

class ShimmerWidgets {
  static final ThemeController themeController = Get.find<ThemeController>();

  // Adjusted colors for better visibility in Dark Mode
  static Color get baseColor => themeController.isDarkMode.value
      ? const Color(0xFF3A3A3A)
      : Colors.grey[300]!;

  static Color get highlightColor => themeController.isDarkMode.value
      ? const Color(0xFF5A5A5A)
      : Colors.grey[100]!;

  // Helper for text placeholders (Ghost Text)
  static Widget _textPlaceholder({double width = 80, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  static Widget statsCard() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static Widget latestOfferCard() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  // Dashboard Active Order Skeleton (Has User Icon Row)
  static Widget dashboardOrderSkeleton() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: ID and Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _textPlaceholder(width: 100, height: 18), // ID
                Container(
                  width: 60,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ), // Pill
              ],
            ),
            const SizedBox(height: 12),

            // User Info Row (Icon + Text)
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ), // User Icon
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textPlaceholder(width: 120, height: 14), // Name
                    const SizedBox(height: 6),
                    _textPlaceholder(width: 90, height: 12), // Phone
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: Colors.white),
            const SizedBox(height: 12),

            // Item Lines
            Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _textPlaceholder(width: 160, height: 14), // Item Name
                      _textPlaceholder(width: 40, height: 14), // Price
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Action Button
            Container(
              width: double.infinity,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Order History Skeleton
  static Widget orderHistorySkeleton() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textPlaceholder(width: 140, height: 18),
                    const SizedBox(height: 6),
                    _textPlaceholder(width: 100, height: 12),
                  ],
                ),
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white),
            const SizedBox(height: 12),
            _textPlaceholder(width: 40, height: 12),
            const SizedBox(height: 8),
            Column(
              children: List.generate(
                2,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _textPlaceholder(width: 180, height: 14),
                      _textPlaceholder(width: 50, height: 14),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _textPlaceholder(width: 40, height: 14),
                const SizedBox(width: 8),
                _textPlaceholder(width: 60, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Menu Item Skeleton (Image + Text Content)
  static Widget menuItemSkeleton() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Box
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _textPlaceholder(width: 140, height: 18), // Title
                      const SizedBox(height: 8),
                      _textPlaceholder(width: 80, height: 12), // Category
                    ],
                  ),
                ),
                // Icon Placeholder
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _textPlaceholder(width: 200, height: 12), // Description line 1
            const SizedBox(height: 6),
            _textPlaceholder(width: 150, height: 12), // Description line 2
            const SizedBox(height: 16),
            const Divider(color: Colors.white),
            const SizedBox(height: 8),

            // Bottom Row: Price + Toggle + Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _textPlaceholder(width: 80, height: 20), // Price
                Row(
                  children: [
                    _textPlaceholder(width: 40, height: 12), // On/Off
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ), // Switch
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget offerCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textPlaceholder(width: 150, height: 18), // Title
                    const SizedBox(height: 6),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ), // Code Pill
                  ],
                ),
                Container(
                  width: 40,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ), // Toggle Switch
              ],
            ),
            const SizedBox(height: 12),
            _textPlaceholder(width: double.infinity, height: 12), // Desc
            const SizedBox(height: 6),
            _textPlaceholder(width: 200, height: 12), // Desc 2
            const SizedBox(height: 12),

            // Discount & Min Order Row
            Row(
              children: [
                Container(width: 16, height: 16, color: Colors.white), // Icon
                const SizedBox(width: 6),
                _textPlaceholder(width: 60, height: 14),
                const SizedBox(width: 20),
                Container(width: 16, height: 16, color: Colors.white), // Icon
                const SizedBox(width: 6),
                _textPlaceholder(width: 80, height: 14),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white),
            const SizedBox(height: 8),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _textPlaceholder(width: 40, height: 14), // Edit
                const SizedBox(width: 16),
                _textPlaceholder(width: 50, height: 14), // Delete
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget profileHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _textPlaceholder(width: 150, height: 20),
                const SizedBox(height: 10),
                _textPlaceholder(width: 100, height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget profileFieldShimmer() {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(width: 24, height: 24, color: Colors.white), // Icon
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _textPlaceholder(width: 60, height: 10), // Label
                  const SizedBox(height: 6),
                  _textPlaceholder(width: 150, height: 14), // Value
                ],
              ),
            ),
            Container(width: 16, height: 16, color: Colors.white), // Arrow
          ],
        ),
      ),
    );
  }
}
