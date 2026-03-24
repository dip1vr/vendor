import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';
import 'package:vendor_fixed/desh.dart';
import 'package:vendor_fixed/menu.dart';
import 'package:vendor_fixed/order.dart';
import 'package:vendor_fixed/setting.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final ThemeController themeController = Get.put(ThemeController());

  final List<Widget> _pages = const [Desh(), Order(), Menu(), Setting()];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: themeController.isDarkMode.value
              ? Brightness.light
              : Brightness.dark,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: themeController.isDarkMode.value
              ? Brightness.light
              : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: IndexedStack(index: _currentIndex, children: _pages),
          bottomNavigationBar: _GlassBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            themeController: themeController,
          ),
        ),
      ),
    );
  }
}

class _GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final ThemeController themeController;

  const _GlassBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          height: 70,
          decoration: BoxDecoration(
            color: themeController.isDarkMode.value
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.dashboard_rounded, "Home", 0),
                  _buildNavItem(Icons.receipt_long_rounded, "Orders", 1),
                  _buildNavItem(Icons.restaurant_menu_rounded, "Menu", 2),
                  _buildNavItem(Icons.settings_rounded, "Settings", 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? Colors.deepOrangeAccent
                : themeController.secondaryText,
            size: isSelected ? 26 : 22,
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.deepOrangeAccent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
