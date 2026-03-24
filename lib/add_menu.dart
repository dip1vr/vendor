import 'dart:io' show File;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor_fixed/controllers/theme_controller.dart';
import 'menu_item.dart';
import 'providers.dart';
import 'services/image_upload_service.dart';

class AddMenu extends ConsumerStatefulWidget {
  const AddMenu({super.key});

  @override
  ConsumerState<AddMenu> createState() => _AddMenuState();
}

class _AddMenuState extends ConsumerState<AddMenu> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  XFile? _selectedImage;
  bool _isUploading = false;
  final ImageUploadService _imageUploadService = ImageUploadService();
  final ThemeController themeController = Get.put(ThemeController());

  static const double platformFeePercent = 0.15;
  static const double gstPercent = 0.05;

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _imageUploadService.pickImage();
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = ref.watch(priceProvider);
    final commission = price * platformFeePercent;
    final gstAmount = price * gstPercent;
    final earning = price - commission + gstAmount;

    Future<void> submitMenuItem() async {
      final name = nameController.text.trim();
      final category = categoryController.text.trim();
      final description = descriptionController.text.trim();
      final priceVal = double.tryParse(priceController.text.trim()) ?? 0;

      if (name.isEmpty ||
          category.isEmpty ||
          description.isEmpty ||
          priceVal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all fields correctly")),
        );
        return;
      }

      if (_selectedImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please select an image")));
        return;
      }

      setState(() {
        _isUploading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User not logged in")));
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final imageUrl = await _imageUploadService.uploadImage(_selectedImage!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image upload failed")));
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final newItem = MenuItem(
        id: '',
        name: name,
        category: category,
        description: description,
        price: priceVal,
        imageUrl: imageUrl,
      );

      try {
        await FirebaseFirestore.instance
            .collection("restaurants")
            .doc(user.uid)
            .collection("menuItems")
            .add({
              "name": name,
              "category": category,
              "description": description,
              "price": priceVal,
              "imageUrl": imageUrl,
              "commission": commission,
              "gst": gstAmount,
              "earning": earning,
              "createdAt": FieldValue.serverTimestamp(),
              "isActive": true,
            });

        ref.read(menuListProvider.notifier).state = [
          ...ref.read(menuListProvider),
          newItem,
        ];

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu item uploaded successfully")),
        );

        ref.read(priceProvider.notifier).state = 0.0;

        Get.back();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: themeController.primaryText,
          ), // Dynamic Icon Color
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create Menu Item",
          style: GoogleFonts.outfit(
            color: themeController.primaryText, // Dynamic Text Color
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(
        () => Stack(
          children: [
            _AnimatedGradientBackground(
              colors: themeController.backgroundGradient,
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: themeController.glassColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: themeController.glassBorderColor,
                            ),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: kIsWeb
                                        ? NetworkImage(_selectedImage!.path)
                                        : FileImage(File(_selectedImage!.path))
                                              as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 50,
                                      color: themeController.iconColor,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Upload Dish Image",
                                      style: GoogleFonts.outfit(
                                        color: themeController.secondaryText,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Column(
                      children: [
                        _buildGlassTextField(
                          nameController,
                          "Dish Name",
                          Icons.restaurant_menu,
                        ),
                        const SizedBox(height: 15),
                        _buildGlassTextField(
                          categoryController,
                          "Category",
                          Icons.category,
                        ),
                        const SizedBox(height: 15),
                        _buildGlassTextField(
                          descriptionController,
                          "Description",
                          Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 15),
                        _buildGlassTextField(
                          priceController,
                          "Price (₹)",
                          Icons.currency_rupee,
                          isNumber: true,
                          onChanged: (val) {
                            final parsed = double.tryParse(val) ?? 0.0;
                            ref.read(priceProvider.notifier).state = parsed;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _GlassContainer(
                      padding: const EdgeInsets.all(20),
                      color: themeController.glassColor,
                      borderColor: themeController.glassBorderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Earning Analysis",
                            style: GoogleFonts.outfit(
                              color: Colors.deepOrangeAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildBreakdownRow(
                            "Customer Pays",
                            "₹${price.toStringAsFixed(2)}",
                            themeController.primaryText,
                          ),
                          _buildBreakdownRow(
                            "Platform Fee (15%)",
                            "- ₹${commission.toStringAsFixed(2)}",
                            Colors.redAccent,
                          ),
                          _buildBreakdownRow(
                            "GST (5%)",
                            "+ ₹${gstAmount.toStringAsFixed(2)}",
                            Colors.green,
                          ),
                          Divider(
                            color: themeController.dividerColor,
                            height: 20,
                          ),
                          _buildBreakdownRow(
                            "Net Earning",
                            "₹${earning.toStringAsFixed(2)}",
                            Colors.cyan,
                            isBold: true,
                            fontSize: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : submitMenuItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: _isUploading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Publish Item",
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return _GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      color: themeController.glassColor,
      borderColor: themeController.glassBorderColor,
      child: TextField(
        controller: controller,
        style: TextStyle(color: themeController.primaryText),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: themeController.iconColor),
          labelText: label,
          labelStyle: TextStyle(color: themeController.secondaryText),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: themeController.secondaryText,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// --- SHARED UI --

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
