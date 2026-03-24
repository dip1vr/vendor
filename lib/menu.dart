import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_fixed/controllers/menu_controller.dart'
    as mc; // Alias to avoid conflict if any
import 'package:vendor_fixed/controllers/theme_controller.dart';
import 'package:vendor_fixed/widgets/shimmer_loading.dart';
import 'add_menu.dart';
import 'services/image_upload_service.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final mc.MenuController controller = Get.put(mc.MenuController());
    final ThemeController themeController = controller.themeController;

    return Obx(
      () => Stack(
        children: [
          // 1. Background
          _AnimatedGradientBackground(
            colors: themeController.backgroundGradient,
          ),

          // 2. Content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Menu Management",
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: themeController.primaryText,
                        ),
                      ),
                      Text(
                        "Manage your restaurant menu items",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: themeController.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Search & Add Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: 14,
                          color: themeController.glassColor,
                          borderColor: themeController.glassBorderColor,
                          child: TextField(
                            onChanged: (val) =>
                                controller.searchQuery.value = val,
                            style: TextStyle(
                              color: themeController.primaryText,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search menu items...",
                              hintStyle: TextStyle(
                                color: themeController.secondaryText,
                              ),
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search,
                                color: themeController.secondaryText,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          // Navigate to AddMenu page
                          Get.to(() => const AddMenu());
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Menu Items List
                Expanded(
                  child: controller.currentUserId.value.isEmpty
                      ? Center(
                          child: Text(
                            "Please login first",
                            style: TextStyle(
                              color: themeController.primaryText,
                            ),
                          ),
                        )
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('restaurants')
                              .doc(controller.currentUserId.value)
                              .collection('menuItems')
                              .orderBy('category')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error loading menu",
                                  style: TextStyle(
                                    color: themeController.primaryText,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                itemCount: 5,
                                itemBuilder: (context, index) =>
                                    ShimmerWidgets.menuItemSkeleton(),
                              );
                            }

                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.restaurant_menu,
                                      size: 50,
                                      color: themeController.secondaryText,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "No menu items found",
                                      style: TextStyle(
                                        color: themeController.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Filter client-side
                            final filteredDocs = docs.where((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final name = data['name']
                                  .toString()
                                  .toLowerCase();
                              final query = controller.searchQuery.value
                                  .toLowerCase();
                              return name.contains(query);
                            }).toList();

                            return ListView.builder(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 100, // Space for nav bar
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                final doc = filteredDocs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: _GlassContainer(
                                    padding: const EdgeInsets.all(12),
                                    color: themeController.glassColor,
                                    borderColor:
                                        themeController.glassBorderColor,
                                    borderRadius: 16,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              (data['imageUrl'] != null &&
                                                  data['imageUrl']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? Image.network(
                                                  data['imageUrl'],
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        width: 80,
                                                        height: 80,
                                                        color: themeController
                                                            .glassColor,
                                                        child: Icon(
                                                          Icons.fastfood,
                                                          color: themeController
                                                              .secondaryText,
                                                        ),
                                                      ),
                                                )
                                              : Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: themeController
                                                      .glassColor,
                                                  child: Icon(
                                                    Icons.fastfood,
                                                    color: themeController
                                                        .secondaryText,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          data['name'] ?? '',
                                                          style: GoogleFonts.outfit(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                themeController
                                                                    .primaryText,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          data['category'] ??
                                                              '',
                                                          style: GoogleFonts.outfit(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .deepOrangeAccent,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // Actions
                                                  Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons
                                                              .local_offer_outlined,
                                                          color: Colors.orange,
                                                          size: 20,
                                                        ),
                                                        tooltip: "Manage Offer",
                                                        onPressed: () {
                                                          _showItemOfferDialog(
                                                            context,
                                                            doc,
                                                            controller,
                                                            themeController,
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: Icon(
                                                          Icons.edit_outlined,
                                                          color: themeController
                                                              .iconColor,
                                                          size: 20,
                                                        ),
                                                        tooltip: "Edit Item",
                                                        onPressed: () {
                                                          _showEditDialog(
                                                            context,
                                                            doc,
                                                            data,
                                                            controller
                                                                .currentUserId
                                                                .value,
                                                            themeController,
                                                          );
                                                        },
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(
                                                          Icons.delete_outline,
                                                          color:
                                                              Colors.redAccent,
                                                          size: 20,
                                                        ),
                                                        tooltip: "Delete Item",
                                                        onPressed: () {
                                                          controller.deleteItem(
                                                            doc.id,
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                data['description'] ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 12,
                                                  color: themeController
                                                      .secondaryText
                                                      .withOpacity(0.8),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "₹${data['price']?.toString() ?? '0'}",
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    DocumentSnapshot doc,
    Map<String, dynamic> data,
    String userId,
    ThemeController themeController,
  ) {
    showDialog(
      context: context,
      builder: (context) => _EditMenuItemDialog(
        doc: doc,
        data: data,
        userId: userId,
        themeController: themeController,
      ),
    );
  }

  void _showItemOfferDialog(
    BuildContext context,
    DocumentSnapshot doc,
    mc.MenuController controller,
    ThemeController themeController,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final existingOffer = data['offer'] as Map<String, dynamic>? ?? {};

    final discountValueController = TextEditingController(
      text: existingOffer['discountValue']?.toString() ?? '',
    );
    final codeController = TextEditingController(
      text: existingOffer['code']?.toString() ?? '',
    );
    final titleController = TextEditingController(
      text: existingOffer['title']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: existingOffer['description']?.toString() ?? '',
    );
    final minOrderController = TextEditingController(
      text: existingOffer['minOrderValue']?.toString() ?? '0',
    );
    RxString selectedType =
        (existingOffer['discountType']?.toString() ?? 'PERCENT').obs;
    RxBool isActive = (existingOffer['isActive'] as bool? ?? true).obs;

    Get.generalDialog(
      barrierDismissible: true,
      barrierLabel: "Item Offer",
      pageBuilder: (context, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: _GlassContainer(
              padding: const EdgeInsets.all(20),
              color: themeController.glassColor,
              borderColor: themeController.glassBorderColor,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Manage Item Offer",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: themeController.primaryText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildGlassTextField(
                      titleController,
                      "Offer Title",
                      Icons.title,
                      themeController: themeController,
                    ),
                    const SizedBox(height: 15),
                    _buildGlassTextField(
                      descController,
                      "Short Description",
                      Icons.description,
                      themeController: themeController,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => GestureDetector(
                              onTap: () => selectedType.value = 'PERCENT',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedType.value == 'PERCENT'
                                      ? Colors.deepOrangeAccent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedType.value == 'PERCENT'
                                        ? Colors.transparent
                                        : themeController.dividerColor,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Percentage (%)",
                                  style: GoogleFonts.outfit(
                                    color: selectedType.value == 'PERCENT'
                                        ? Colors.white
                                        : themeController.secondaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Obx(
                            () => GestureDetector(
                              onTap: () => selectedType.value = 'FLAT',
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedType.value == 'FLAT'
                                      ? Colors.deepOrangeAccent
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: selectedType.value == 'FLAT'
                                        ? Colors.transparent
                                        : themeController.dividerColor,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  "Flat Amount (₹)",
                                  style: GoogleFonts.outfit(
                                    color: selectedType.value == 'FLAT'
                                        ? Colors.white
                                        : themeController.secondaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassTextField(
                            discountValueController,
                            "Discount Value",
                            Icons.discount,
                            isNumber: true,
                            themeController: themeController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildGlassTextField(
                            minOrderController,
                            "Min Order",
                            Icons.shopping_bag,
                            isNumber: true,
                            themeController: themeController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildGlassTextField(
                      codeController,
                      "Coupon Code",
                      Icons.qr_code,
                      themeController: themeController,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Offer Active",
                          style: GoogleFonts.outfit(
                            color: themeController.primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(
                          () => Switch(
                            value: isActive.value,
                            onChanged: (val) => isActive.value = val,
                            activeColor: Colors.white,
                            activeTrackColor: Colors.deepOrangeAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (existingOffer.isNotEmpty) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                controller.deleteItemOffer(doc.id);
                                Get.back();
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Remove",
                                style: GoogleFonts.outfit(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              final val =
                                  double.tryParse(
                                    discountValueController.text.trim(),
                                  ) ??
                                  0;
                              if (val <= 0) {
                                Get.snackbar(
                                  "Error",
                                  "Invalid discount value",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              String couponCode = codeController.text
                                  .trim()
                                  .toUpperCase();
                              if (couponCode.isEmpty) {
                                Get.snackbar(
                                  "Error",
                                  "Coupon code is required",
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              final minOrder =
                                  double.tryParse(
                                    minOrderController.text.trim(),
                                  ) ??
                                  0;

                              final offerData = {
                                'code': codeController.text
                                    .trim()
                                    .toUpperCase(),
                                'createdAt':
                                    existingOffer['createdAt'] ??
                                    Timestamp.now(),
                                'description': descController.text.trim(),
                                'discountType': selectedType.value
                                    .toLowerCase(),
                                'discountValue': val,
                                'endDate':
                                    existingOffer['endDate'] ??
                                    Timestamp.fromDate(
                                      DateTime.now().add(
                                        const Duration(days: 30),
                                      ),
                                    ),
                                'isActive': isActive.value,
                                'minOrderValue': minOrder,
                                'startDate':
                                    existingOffer['startDate'] ??
                                    Timestamp.now(),
                                'title': titleController.text.trim(),
                                'usageCount': existingOffer['usageCount'] ?? 0,
                              };
                              controller.saveItemOffer(doc.id, offerData);
                              Get.back();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Save Offer",
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
    Function(String)? onChanged,
    required ThemeController themeController,
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
}

class _EditMenuItemDialog extends StatefulWidget {
  final DocumentSnapshot doc;
  final Map<String, dynamic> data;
  final String userId;
  final ThemeController themeController;

  const _EditMenuItemDialog({
    required this.doc,
    required this.data,
    required this.userId,
    required this.themeController,
  });

  @override
  State<_EditMenuItemDialog> createState() => _EditMenuItemDialogState();
}

class _EditMenuItemDialogState extends State<_EditMenuItemDialog> {
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController descController;
  late TextEditingController priceController;
  XFile? _selectedImage;
  bool _isUploading = false;
  final ImageUploadService _imageUploadService = ImageUploadService();

  static const double platformFeePercent = 0.15;
  static const double gstPercent = 0.05;

  double _currentPrice = 0;
  double _commission = 0;
  double _gstAmount = 0;
  double _earning = 0;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data['name']);
    categoryController = TextEditingController(text: widget.data['category']);
    descController = TextEditingController(text: widget.data['description']);
    _currentPrice = (widget.data['price'] ?? 0).toDouble();
    priceController = TextEditingController(text: _currentPrice.toString());

    _calculateBreakdown(_currentPrice);
  }

  void _calculateBreakdown(double price) {
    setState(() {
      _currentPrice = price;
      _commission = price * platformFeePercent;
      _gstAmount = price * gstPercent;
      _earning = price - _commission + _gstAmount;
    });
  }

  Future<void> _pickImage() async {
    final file = await _imageUploadService.pickImage();
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  Future<void> _updateItem() async {
    final newPrice = double.tryParse(priceController.text) ?? 0;
    if (newPrice <= 0) return;

    setState(() {
      _isUploading = true;
    });

    String? imageUrl = widget.data['imageUrl'];

    if (_selectedImage != null) {
      final uploadedUrl = await _imageUploadService.uploadImage(
        _selectedImage!,
      );
      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image")),
          );
          setState(() => _isUploading = false);
          return;
        }
      }
    }

    final gst = newPrice * 0.05;
    final platformFee = newPrice * 0.15;
    final earning = newPrice - platformFee + gst;

    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(widget.userId)
        .collection('menuItems')
        .doc(widget.doc.id)
        .update({
          'name': nameController.text,
          'category': categoryController.text,
          'description': descController.text,
          'price': newPrice,
          'imageUrl': imageUrl,
          'gst': gst,
          'platformFee': platformFee,
          'earning': earning,
        });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AlertDialog(
        backgroundColor: widget.themeController.dialogBackgroundColor,
        title: Text(
          "Edit Item",
          style: GoogleFonts.outfit(color: widget.themeController.primaryText),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: _selectedImage != null
                        ? (kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ))
                        : (widget.data['imageUrl'] != null &&
                              widget.data['imageUrl'].toString().isNotEmpty)
                        ? Image.network(
                            widget.data['imageUrl'],
                            fit: BoxFit.cover,
                          )
                        : Icon(
                            Icons.add_a_photo,
                            color: widget.themeController.iconColor,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  "Tap image to change",
                  style: GoogleFonts.outfit(
                    color: widget.themeController.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildDialogField("Name", nameController),
              _buildDialogField("Category", categoryController),
              _buildDialogField("Description", descController, maxLines: 3),

              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: widget.themeController.primaryText),
                  onChanged: (val) {
                    final p = double.tryParse(val) ?? 0;
                    _calculateBreakdown(p);
                  },
                  decoration: InputDecoration(
                    labelText: "Price",
                    labelStyle: TextStyle(
                      color: widget.themeController.secondaryText,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: widget.themeController.dividerColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.deepOrangeAccent,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  border: Border.all(
                    color: widget.themeController.dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Breakdown",
                      style: GoogleFonts.outfit(
                        color: Colors.deepOrangeAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _breakdownRow(
                      "Price",
                      "₹${_currentPrice.toStringAsFixed(2)}",
                      widget.themeController.primaryText,
                    ),
                    _breakdownRow(
                      "Fee (15%)",
                      "- ₹${_commission.toStringAsFixed(2)}",
                      Colors.redAccent,
                    ),
                    _breakdownRow(
                      "GST (5%)",
                      "+ ₹${_gstAmount.toStringAsFixed(2)}",
                      Colors.green,
                    ),
                    Divider(color: widget.themeController.dividerColor),
                    _breakdownRow(
                      "You Earn",
                      "₹${_earning.toStringAsFixed(2)}",
                      Colors.cyan,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: GoogleFonts.outfit(
                color: widget.themeController.secondaryText,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
            ),
            onPressed: _isUploading ? null : _updateItem,
            child: _isUploading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text("Save", style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: widget.themeController.primaryText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: widget.themeController.secondaryText),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.themeController.dividerColor),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.deepOrangeAccent),
          ),
        ),
      ),
    );
  }

  Widget _breakdownRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              color: widget.themeController.secondaryText,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

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
    final colors =
        widget.colors ?? [const Color(0xFF1F1F1F), const Color(0xFF2C2C2C)];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: _topAlignmentAnimation.value,
              end: _bottomAlignmentAnimation.value,
            ),
          ),
        );
      },
    );
  }
}
