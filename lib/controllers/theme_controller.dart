import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Observable boolean for dark mode, default is true
  RxBool isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    updateSystemChrome();
  }

  void updateSystemChrome() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode.value
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode.value
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // --- Color Getters for easy access ---

  // Background Colors (Flat, no gradient)
  // Background Colors (Flat, no gradient)
  List<Color> get backgroundGradient => isDarkMode.value
      ? const [Color(0xFF121212), Color(0xFF121212)] // Flat Dark
      : const [Color(0xFFF5F5F5), Color(0xFFF5F5F5)]; // Soft Off-White

  // Text Colors
  Color get primaryText => isDarkMode.value ? Colors.white : Colors.black87;
  Color get secondaryText => isDarkMode.value ? Colors.white70 : Colors.black54;
  Color get accentText => Colors.deepOrange; // Consistent accent

  // Surface/Container Colors
  Color get glassColor => isDarkMode.value
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white; // Pure White Card

  Color get glassBorderColor => isDarkMode.value
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.black.withValues(alpha: 0.05); // Subtle Border

  Color get dialogBackgroundColor =>
      isDarkMode.value ? const Color(0xFF1E1E1E) : Colors.white;

  Color get dividerColor => isDarkMode.value ? Colors.white10 : Colors.black12;

  // Icon Colors
  Color get iconColor =>
      isDarkMode.value ? Colors.orangeAccent : Colors.deepOrange;
}
