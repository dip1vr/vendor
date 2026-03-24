import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vendor_fixed/controllers/offer_controller.dart' as oc; // Alias
import 'package:vendor_fixed/controllers/theme_controller.dart';
import 'package:vendor_fixed/widgets/shimmer_loading.dart';

class OfferManagement extends StatelessWidget {
  const OfferManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final oc.OfferController controller = Get.put(oc.OfferController());
    final ThemeController themeController = controller.themeController;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        extendBody: true,
        body: Obx(
          () => Stack(
            children: [
              // Background
              _AnimatedGradientBackground(
                colors: themeController.backgroundGradient,
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: _GlassContainer(
                              padding: const EdgeInsets.all(10),
                              color: themeController.glassColor,
                              borderColor: themeController.glassBorderColor,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: themeController.iconColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Offers & Coupons",
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: themeController.primaryText,
                                ),
                              ),
                              Text(
                                "Manage your restaurant offers",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: themeController.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add New Offer Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => _showAddEditOfferDialog(
                          context,
                          controller,
                          themeController,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepOrangeAccent,
                                Colors.orangeAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepOrangeAccent.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "+ Create New Offer",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tab Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _GlassContainer(
                        padding: const EdgeInsets.all(4),
                        borderRadius: 12,
                        color: themeController.glassColor,
                        borderColor: themeController.glassBorderColor,
                        child: TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            color: Colors.deepOrangeAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: themeController.secondaryText,
                          labelStyle: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: "Active"),
                            Tab(text: "Scheduled"),
                            Tab(text: "Inactive"),
                          ],
                          dividerColor: Colors.transparent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Offers List
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('restaurants')
                            .doc(controller.currentUserId.value)
                            .collection('offers')
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: 5,
                              itemBuilder: (context, index) =>
                                  ShimmerWidgets.offerCardSkeleton(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                "No offers found.",
                                style: GoogleFonts.outfit(
                                  color: themeController.secondaryText,
                                ),
                              ),
                            );
                          }

                          final allOffers = snapshot.data!.docs;
                          final now = DateTime.now();

                          final activeOffers = <DocumentSnapshot>[];
                          final scheduledOffers = <DocumentSnapshot>[];
                          final inactiveOffers = <DocumentSnapshot>[];

                          for (var doc in allOffers) {
                            final data = doc.data() as Map<String, dynamic>;
                            final bool isActive = data['isActive'] ?? false;
                            final Timestamp? startTs =
                                data['startDate'] as Timestamp?;
                            final Timestamp? endTs =
                                data['endDate'] as Timestamp?;

                            final DateTime start = startTs?.toDate() ?? now;
                            final DateTime end =
                                endTs?.toDate() ??
                                now.add(const Duration(days: 365));

                            if (!isActive) {
                              inactiveOffers.add(doc);
                            } else if (end.isBefore(now)) {
                              inactiveOffers.add(doc);
                            } else if (start.isAfter(now)) {
                              scheduledOffers.add(doc);
                            } else {
                              activeOffers.add(doc);
                            }
                          }

                          return TabBarView(
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildOfferList(
                                activeOffers,
                                "No active offers",
                                controller,
                                themeController,
                              ),
                              _buildOfferList(
                                scheduledOffers,
                                "No scheduled offers",
                                controller,
                                themeController,
                                isScheduled: true,
                              ),
                              _buildOfferList(
                                inactiveOffers,
                                "No inactive offers",
                                controller,
                                themeController,
                              ),
                            ],
                          );
                        },
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

  Widget _buildOfferList(
    List<DocumentSnapshot> offers,
    String emptyMsg,
    oc.OfferController controller,
    ThemeController themeController, {
    bool isScheduled = false,
  }) {
    if (offers.isEmpty) {
      return Center(
        child: Text(
          emptyMsg,
          style: GoogleFonts.outfit(color: themeController.secondaryText),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final doc = offers[index];
        final data = doc.data() as Map<String, dynamic>;
        return _buildOfferCard(
          context,
          doc,
          data,
          controller,
          themeController,
          isScheduled: isScheduled,
        );
      },
    );
  }

  Widget _buildOfferCard(
    BuildContext context,
    DocumentSnapshot doc,
    Map<String, dynamic> data,
    oc.OfferController controller,
    ThemeController themeController, {
    bool isScheduled = false,
  }) {
    final bool isActive = data['isActive'] ?? false;
    final DateTime? end = (data['endDate'] as Timestamp?)?.toDate();
    final DateTime? start = (data['startDate'] as Timestamp?)?.toDate();
    final bool isExpired = end != null && end.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                        data['title'] ?? 'No Title',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeController.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.deepOrangeAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          data['code'] ?? 'NOCODE',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isActive,
                  onChanged: (val) {
                    controller.toggleOfferStatus(doc.reference, val);
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.red.withOpacity(0.5),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              data['description'] ?? '',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: themeController.secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.discount, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  data['discountType'] == 'percentage'
                      ? "${data['discountValue']}% OFF"
                      : "₹${data['discountValue']} OFF",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 16,
                  color: themeController.secondaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  "Min Order: ₹${data['minOrderValue']}",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: themeController.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isScheduled && start != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Starts on: ${DateFormat('dd MMM yyyy, hh:mm a').format(start)}",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (end != null)
              Text(
                "Expires on: ${DateFormat('dd MMM yyyy').format(end)}",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isExpired ? Colors.red : themeController.secondaryText,
                  fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            Divider(color: themeController.dividerColor, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isScheduled)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton.icon(
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Force Activate",
                          middleText:
                              "This will set the start date to NOW, making the offer active immediately. Continue?",
                          textConfirm: "Yes, Activate",
                          textCancel: "Cancel",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.deepOrangeAccent,
                          onConfirm: () {
                            controller.forceActivate(doc.reference);
                            Get.back();
                          },
                        );
                      },
                      icon: Icon(
                        Icons.flash_on,
                        size: 16,
                        color: Colors.orange,
                      ),
                      label: Text(
                        "Activate Now",
                        style: GoogleFonts.outfit(color: Colors.orange),
                      ),
                    ),
                  ),

                TextButton.icon(
                  onPressed: () => _showAddEditOfferDialog(
                    context,
                    controller,
                    themeController,
                    doc: doc,
                    data: data,
                  ),
                  icon: Icon(Icons.edit, size: 16, color: Colors.blueAccent),
                  label: Text(
                    "Edit",
                    style: GoogleFonts.outfit(color: Colors.blueAccent),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Delete Offer",
                      middleText: "Are you sure you want to delete this offer?",
                      textConfirm: "Delete",
                      textCancel: "Cancel",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.red,
                      onConfirm: () {
                        controller.deleteOffer(doc.reference);
                        Get.back();
                      },
                    );
                  },
                  icon: Icon(Icons.delete, size: 16, color: Colors.redAccent),
                  label: Text(
                    "Delete",
                    style: GoogleFonts.outfit(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditOfferDialog(
    BuildContext context,
    oc.OfferController controller,
    ThemeController themeController, {
    DocumentSnapshot? doc,
    Map<String, dynamic>? data,
  }) {
    showDialog(
      context: context,
      builder: (context) => _AddEditOfferDialog(
        doc: doc,
        initialData: data,
        offerController: controller,
        themeController: themeController,
      ),
    );
  }
}

class _AddEditOfferDialog extends StatefulWidget {
  final DocumentSnapshot? doc;
  final Map<String, dynamic>? initialData;
  final oc.OfferController offerController;
  final ThemeController themeController;

  const _AddEditOfferDialog({
    this.doc,
    this.initialData,
    required this.offerController,
    required this.themeController,
  });

  @override
  State<_AddEditOfferDialog> createState() => _AddEditOfferDialogState();
}

class _AddEditOfferDialogState extends State<_AddEditOfferDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _codeCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _discountValCtrl;
  late TextEditingController _minOrderCtrl;

  String _discountType = 'percentage'; // percentage or flat
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
      text: widget.initialData?['title'] ?? '',
    );
    _codeCtrl = TextEditingController(text: widget.initialData?['code'] ?? '');
    _descCtrl = TextEditingController(
      text: widget.initialData?['description'] ?? '',
    );
    _discountValCtrl = TextEditingController(
      text: widget.initialData?['discountValue']?.toString() ?? '',
    );
    _minOrderCtrl = TextEditingController(
      text: widget.initialData?['minOrderValue']?.toString() ?? '',
    );

    if (widget.initialData != null) {
      _discountType = widget.initialData?['discountType'] ?? 'percentage';
      if (widget.initialData?['startDate'] != null) {
        _startDate = (widget.initialData!['startDate'] as Timestamp).toDate();
      }
      if (widget.initialData?['endDate'] != null) {
        _endDate = (widget.initialData!['endDate'] as Timestamp).toDate();
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime initial = isStart ? _startDate : _endDate;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: widget.themeController.isDarkMode.value
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: Colors.deepOrangeAccent,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Colors.deepOrangeAccent,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
        builder: (context, child) {
          return Theme(
            data: widget.themeController.isDarkMode.value
                ? ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: Colors.deepOrangeAccent,
                      onPrimary: Colors.white,
                      surface: const Color(0xFF1E1E1E),
                      onSurface: Colors.white,
                    ),
                  )
                : ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.deepOrangeAccent,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
            child: child!,
          );
        },
      );

      final int hour = pickedTime?.hour ?? DateTime.now().hour;
      final int minute = pickedTime?.minute ?? DateTime.now().minute;

      final DateTime finalDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        hour,
        minute,
      );

      setState(() {
        if (isStart) {
          _startDate = finalDateTime;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = finalDateTime;
        }
      });
    }
  }

  Future<void> _saveOffer({bool isSchedule = false}) async {
    if (_formKey.currentState!.validate()) {
      // Validation
      if (isSchedule && _startDate.isBefore(DateTime.now())) {
        Get.snackbar(
          "Error",
          "Scheduled start time must be in the future.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setState(() => _isSaving = true);

      final discountVal = double.tryParse(_discountValCtrl.text) ?? 0;
      final minOrder = double.tryParse(_minOrderCtrl.text) ?? 0;

      DateTime finalStartDate = _startDate;
      if (!isSchedule) {
        finalStartDate = DateTime.now();
      }

      final data = {
        'title': _titleCtrl.text.trim(),
        'code': _codeCtrl.text.trim().toUpperCase(),
        'description': _descCtrl.text.trim(),
        'discountType': _discountType,
        'discountValue': discountVal,
        'minOrderValue': minOrder,
        'startDate': Timestamp.fromDate(finalStartDate),
        'endDate': Timestamp.fromDate(_endDate),
        'isActive': true,
        'usageCount': widget.initialData?['usageCount'] ?? 0,
        'createdAt':
            widget.initialData?['createdAt'] ?? FieldValue.serverTimestamp(),
      };

      try {
        await widget.offerController.saveOffer(
          docId: widget.doc?.id,
          data: data,
        );

        Navigator.pop(context);
        Get.snackbar(
          "Success",
          widget.doc != null
              ? "Offer updated successfully"
              : isSchedule
              ? "Offer scheduled successfully"
              : "Offer posted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "$e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Obx(
        () => _GlassContainer(
          padding: const EdgeInsets.all(0),
          borderRadius: 24,
          color: widget.themeController.glassColor.withOpacity(0.95),
          borderColor: widget.themeController.glassBorderColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(
                    bottom: BorderSide(
                      color: widget.themeController.dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.doc != null ? "Edit Offer" : "Create Offer",
                      style: GoogleFonts.outfit(
                        color: widget.themeController.primaryText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: widget.themeController.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTextField(
                          "Offer Title",
                          _titleCtrl,
                          isRequired: true,
                          icon: Icons.local_offer,
                        ),
                        _buildTextField(
                          "Coupon Code",
                          _codeCtrl,
                          isRequired: true,
                          allCaps: true,
                          icon: Icons.code,
                        ),
                        _buildTextField(
                          "Description",
                          _descCtrl,
                          maxLines: 2,
                          icon: Icons.description,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: DropdownButtonFormField<String>(
                                  value: _discountType,
                                  dropdownColor: const Color(0xFF2C2C2C),
                                  style: TextStyle(
                                    color: widget.themeController.primaryText,
                                    fontFamily: GoogleFonts.outfit().fontFamily,
                                  ),
                                  decoration: _inputDeco(
                                    "Type",
                                    icon: Icons.percent,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'percentage',
                                      child: Text('Percentage (%)'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'flat',
                                      child: Text('Flat Amount (₹)'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    setState(() => _discountType = val!);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                "Value",
                                _discountValCtrl,
                                isNumber: true,
                                isRequired: true,
                                icon: Icons.numbers,
                              ),
                            ),
                          ],
                        ),
                        _buildTextField(
                          "Min Order Value",
                          _minOrderCtrl,
                          isNumber: true,
                          icon: Icons.currency_rupee,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateTimePicker(
                                "Start Date",
                                _startDate,
                                () => _selectDateTime(context, true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDateTimePicker(
                                "End Date",
                                _endDate,
                                () => _selectDateTime(context, false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(
                    top: BorderSide(color: widget.themeController.dividerColor),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (widget.doc == null) ...[
                          Expanded(
                            child: _buildActionButton(
                              text: "Schedule",
                              onTap: () => _saveOffer(isSchedule: true),
                              color: Colors.orangeAccent,
                              isOutlined: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: _buildActionButton(
                            text: widget.doc != null ? "Update" : "Post Now",
                            onTap: () => _saveOffer(isSchedule: false),
                            color: Colors.deepOrangeAccent,
                            isLoading: _isSaving,
                          ),
                        ),
                      ],
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

  Widget _buildActionButton({
    required String text,
    required VoidCallback onTap,
    required Color color,
    bool isOutlined = false,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : color,
          borderRadius: BorderRadius.circular(12),
          border: isOutlined ? Border.all(color: color, width: 2) : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isOutlined ? color : Colors.white,
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.outfit(
                    color: isOutlined ? color : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    bool isRequired = false,
    bool isNumber = false,
    bool allCaps = false,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        textCapitalization: allCaps
            ? TextCapitalization.characters
            : TextCapitalization.none,
        style: TextStyle(
          color: widget.themeController.primaryText,
          fontSize: 15,
        ),
        validator: (val) {
          if (isRequired && (val == null || val.trim().isEmpty)) {
            return "$label is required";
          }
          return null;
        },
        decoration: _inputDeco(label, icon: icon),
      ),
    );
  }

  InputDecoration _inputDeco(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: widget.themeController.secondaryText,
        fontSize: 14,
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: widget.themeController.secondaryText, size: 20)
          : null,
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: widget.themeController.dividerColor.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.deepOrangeAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.redAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildDateTimePicker(String label, DateTime date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          border: Border.all(
            color: widget.themeController.dividerColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: widget.themeController.secondaryText,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: widget.themeController.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMM\nhh:mm a').format(date),
              style: TextStyle(
                color: widget.themeController.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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
