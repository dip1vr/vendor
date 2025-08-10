import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> with TickerProviderStateMixin {
  String _selectedLanguage = "English";
  late TabController _tabController;
  String get currentUserId => FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void showEditDialog(String field, String currentValue, String label, {TextInputType keyboardType = TextInputType.text}) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('restaurants')
                      .doc(currentUserId)
                      .set({field: newValue}, SetOptions(merge: true));
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7E5EC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Settings",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text("Manage your Restaurant Setting and Preference",
                  style: TextStyle(fontSize: 14)),
              const SizedBox(height: 20),

              /// Tabs
              TabBar(
                controller: _tabController,
                labelColor: Colors.orangeAccent,
                unselectedLabelColor: Colors.black,
                indicatorColor: Colors.orangeAccent,
                tabs: const [
                  Tab(icon: Icon(Icons.restaurant), text: "Restaurant"),
                  Tab(icon: Icon(Icons.person_outline), text: "Account"),
                  Tab(icon: Icon(Icons.settings), text: "Preference"),
                ],
              ),
              const SizedBox(height: 10),

              /// Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    /// ------------------ Restaurant Tab ------------------
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(currentUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                        return SingleChildScrollView(
                          child: buildSectionCard(
                            icon: Icons.restaurant_menu,
                            title: "Restaurant Information",
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                sectionItem(
                                  "Restaurant Name",
                                  Icons.edit,
                                  data['restaurantName'] ?? "Bella Chaio Restaurant",
                                  onEdit: () => showEditDialog('restaurantName', data['restaurantName'] ?? "Bella Chaio Restaurant", "Restaurant Name"),
                                ),
                                sectionItem(
                                  "Phone Number",
                                  Icons.call,
                                  data['phoneNumber'] ?? "+91 98******55",
                                  onEdit: () => showEditDialog('phoneNumber', data['phoneNumber'] ?? "+91 98******55", "Phone Number", keyboardType: TextInputType.phone),
                                ),
                                sectionItem(
                                  "Email Address",
                                  Icons.email,
                                  data['emailAddress'] ?? "diptype1@gmail.com",
                                  onEdit: () => showEditDialog('emailAddress', data['emailAddress'] ?? "diptype1@gmail.com", "Email Address", keyboardType: TextInputType.emailAddress),
                                ),
                                sectionItem(
                                  "Address",
                                  Icons.location_city,
                                  data['address'] ?? "Khatu Shyamji, Sikar, Rajasthan, PIN: 332602",
                                  onEdit: () => showEditDialog('address', data['address'] ?? "Khatu Shyamji, Sikar, Rajasthan, PIN: 332602", "Address", keyboardType: TextInputType.multiline),
                                ),
                                sectionItem(
                                  "Cuisine Type",
                                  Icons.fastfood,
                                  data['cuisineType'] ?? "Italian, Chinese",
                                  onEdit: () => showEditDialog('cuisineType', data['cuisineType'] ?? "Italian, Chinese", "Cuisine Type"),
                                ),
                                sectionItem(
                                  "GSTIN / Business ID",
                                  Icons.description,
                                  data['gstin'] ?? "29ABCDE1234F2Z5",
                                  onEdit: () => showEditDialog('gstin', data['gstin'] ?? "29ABCDE1234F2Z5", "GSTIN / Business ID"),
                                ),
                                sectionItem(
                                  "Working Hours",
                                  Icons.access_time,
                                  data['workingHours'] ?? "9:00 AM - 10:00 PM",
                                  onEdit: () => showEditDialog('workingHours', data['workingHours'] ?? "9:00 AM - 10:00 PM", "Working Hours"),
                                ),
                                sectionItem(
                                  "Delivery Radius",
                                  Icons.map,
                                  data['deliveryRadius'] ?? "5 km",
                                  onEdit: () => showEditDialog('deliveryRadius', data['deliveryRadius'] ?? "5 km", "Delivery Radius", keyboardType: TextInputType.number),
                                ),
                                sectionItem(
                                  "Active Offers",
                                  Icons.local_offer_outlined,
                                  data['activeOffers'] ?? "10% off on orders above ₹500",
                                  onEdit: () => showEditDialog('activeOffers', data['activeOffers'] ?? "10% off on orders above ₹500", "Active Offers"),
                                ),
                                const SizedBox(height: 10),
                                const Text("Photos", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.photo_camera),
                                  label: const Text("Upload Photos"),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Currently Open", style: TextStyle(fontWeight: FontWeight.bold)),
                                    Switch(
                                      value: data['isOpen'] ?? true,
                                      onChanged: (val) {
                                        FirebaseFirestore.instance
                                            .collection('restaurants')
                                            .doc(currentUserId)
                                            .set({'isOpen': val}, SetOptions(merge: true));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    /// ------------------ Account Tab ------------------
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(currentUserId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                        return SingleChildScrollView(
                          child: buildSectionCard(
                            icon: Icons.account_circle_outlined,
                            title: "Account Details",
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                        onPressed: () {},
                                        child: const Text("Change Photo")),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                sectionItem(
                                  "Username",
                                  Icons.person,
                                  data['username'] ?? "Dip Type",
                                  onEdit: () => showEditDialog('username', data['username'] ?? "Dip Type", "Username"),
                                ),
                                sectionItem(
                                  "Role",
                                  Icons.shield_outlined,
                                  data['role'] ?? "Owner",
                                  onEdit: () => showEditDialog('role', data['role'] ?? "Owner", "Role"),
                                ),
                                sectionItem(
                                  "Joined Date",
                                  Icons.calendar_today,
                                  data['joinedDate'] ?? "01 Jan 2024",
                                ),  // No edit for joined date
                                sectionItem(
                                  "Bank Account",
                                  Icons.account_balance,
                                  data['bankAccount'] ?? "XXXX-XXXX-1234",
                                  onEdit: () => showEditDialog('bankAccount', data['bankAccount'] ?? "XXXX-XXXX-1234", "Bank Account", keyboardType: TextInputType.number),
                                ),
                                sectionItem(
                                  "IFSC Code",
                                  Icons.pin,
                                  data['ifscCode'] ?? "SBIN0001234",
                                  onEdit: () => showEditDialog('ifscCode', data['ifscCode'] ?? "SBIN0001234", "IFSC Code"),
                                ),
                                const Divider(),
                                const Text("Business Verification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ListTile(
                                  leading: const Icon(Icons.verified_user_outlined),
                                  title: const Text("Upload FSSAI License"),
                                  trailing: const Icon(Icons.upload_file),
                                  onTap: () {},
                                ),
                                ListTile(
                                  leading: const Icon(Icons.picture_as_pdf),
                                  title: const Text("Upload PAN / GSTIN"),
                                  trailing: const Icon(Icons.upload_file),
                                  onTap: () {},
                                ),
                                const Divider(),
                                const Text("Security", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                TextButton(onPressed: () {}, child: const Text("Change Password")),
                                TextButton(onPressed: () {}, child: const Text("2-Factor Authentication")),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.group),
                                  title: const Text("Manage Team Members"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {},
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text("Request Account Deactivation", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    /// ------------------ Preference Tab ------------------
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          buildSectionCard(
                            icon: Icons.tune,
                            title: "App Preferences",
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Theme", style: TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    const ChoiceChip(label: Text("Light"), selected: true),
                                    const SizedBox(width: 10),
                                    const ChoiceChip(label: Text("Dark"), selected: false),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Receive Updates"),
                                    Switch(value: true, onChanged: (val) {}),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Promotional Offers"),
                                    Switch(value: false, onChanged: (val) {}),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          buildSectionCard(
                            icon: Icons.language,
                            title: "Language & Region",
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("App Language"),
                                const SizedBox(height: 5),
                                DropdownButton<String>(
                                  value: _selectedLanguage,
                                  items: <String>["English", "Hindi", "Dart"].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        _selectedLanguage = val;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.logout),
                                    label: const Text("Logout", style: TextStyle(color: Colors.black)),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text("App Version: 1.0.0", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ],
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

  Widget buildSectionCard({required IconData icon, required String title, required Widget content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Icon(icon, color: Colors.orangeAccent, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ]),
      ),
    );
  }

  Widget sectionItem(String label, IconData icon, String value, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, color: Colors.orangeAccent, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 16, color: Colors.orangeAccent),
                  onPressed: onEdit,
                ),
            ],
          ),
        ],
      ),
    );
  }
}