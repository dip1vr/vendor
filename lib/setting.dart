import 'package:flutter/material.dart';

class Setting extends StatefulWidget {
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> with TickerProviderStateMixin {
  String _selectedLanguage = "English";
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF7E5EC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Settings",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Manage your Restaurant Setting and Preference",
                    style: TextStyle(fontSize: 14)),
                SizedBox(height: 20),

                /// Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.orangeAccent,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.orangeAccent,
                  tabs: [
                    Tab(icon: Icon(Icons.restaurant), text: "Restaurant"),
                    Tab(icon: Icon(Icons.person_outline), text: "Account"),
                    Tab(icon: Icon(Icons.settings), text: "Preference"),
                  ],
                ),
                SizedBox(height: 10),

                /// Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      /// ------------------ Restaurant Tab ------------------
                      SingleChildScrollView(
                        child: buildSectionCard(
                          icon: Icons.restaurant_menu,
                          title: "Restaurant Information",
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionItem("Restaurant Name", Icons.edit, "Bella Chaio Restaurant"),
                              sectionItem("Phone Number", Icons.call, "+91 98******55"),
                              sectionItem("Email Address", Icons.email, "diptype1@gmail.com"),
                              sectionItem("Address", Icons.location_city, "Khatu Shyamji, Sikar, Rajasthan, PIN: 332602"),
                              sectionItem("Cuisine Type", Icons.fastfood, "Italian, Chinese"),
                              sectionItem("GSTIN / Business ID", Icons.description, "29ABCDE1234F2Z5"),
                              sectionItem("Working Hours", Icons.access_time, "9:00 AM - 10:00 PM"),
                              sectionItem("Delivery Radius", Icons.map, "5 km"),
                              sectionItem("Active Offers", Icons.local_offer_outlined, "10% off on orders above ₹500"),
                              SizedBox(height: 10),
                              Text("Photos", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.photo_camera),
                                label: Text("Upload Photos"),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Currently Open", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Switch(value: true, onChanged: (val) {}),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// ------------------ Account Tab ------------------
                      SingleChildScrollView(
                        child: buildSectionCard(
                          icon: Icons.account_circle_outlined,
                          title: "Account Details",
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                      onPressed: () {},
                                      child: Text("Change Photo")),
                                ],
                              ),
                              SizedBox(height: 10),
                              sectionItem("Username", Icons.person, "Dip Type"),
                              sectionItem("Role", Icons.shield_outlined, "Owner"),
                              sectionItem("Joined Date", Icons.calendar_today, "01 Jan 2024"),
                              sectionItem("Bank Account", Icons.account_balance, "XXXX-XXXX-1234"),
                              sectionItem("IFSC Code", Icons.pin, "SBIN0001234"),
                              Divider(),
                              Text("Business Verification", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ListTile(
                                leading: Icon(Icons.verified_user_outlined),
                                title: Text("Upload FSSAI License"),
                                trailing: Icon(Icons.upload_file),
                                onTap: () {},
                              ),
                              ListTile(
                                leading: Icon(Icons.picture_as_pdf),
                                title: Text("Upload PAN / GSTIN"),
                                trailing: Icon(Icons.upload_file),
                                onTap: () {},
                              ),
                              Divider(),
                              Text("Security", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              TextButton(onPressed: () {}, child: Text("Change Password")),
                              TextButton(onPressed: () {}, child: Text("2-Factor Authentication")),
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.group),
                                title: Text("Manage Team Members"),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {},
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text("Request Account Deactivation", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ),
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
                                  Text("Theme", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      ChoiceChip(label: Text("Light"), selected: true),
                                      SizedBox(width: 10),
                                      ChoiceChip(label: Text("Dark"), selected: false),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Receive Updates"),
                                      Switch(value: true, onChanged: (val) {}),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Promotional Offers"),
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
                                  Text("App Language"),
                                  SizedBox(height: 5),
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
                                      icon: Icon(Icons.logout),
                                      label: Text("Logout", style: TextStyle(color: Colors.black)),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                    ),
                                    SizedBox(height: 10),
                                    Text("App Version: 1.0.0", style: TextStyle(color: Colors.grey)),
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
              SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          content,
        ]),
      ),
    );
  }

  Widget sectionItem(String label, IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(icon, color: Colors.orangeAccent, size: 16),
              SizedBox(width: 8),
              Expanded(child: Text(value, style: TextStyle(fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }
}
