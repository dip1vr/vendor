import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Order Page')),
        body: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Menu Management",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Manage your restaurant menu item",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  minimumSize: Size(500, 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),

                child: Text("+ Add Menu"),
              ),
              SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search menu item',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),

                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.orangeAccent,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "  All Categories",
                        style: TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Margereted pizza",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Category: pizza"),
                            ],
                          ),
                          Icon(Icons.visibility, color: Colors.green),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text("Discraption ", style: TextStyle(fontSize: 14)),
                      Text(
                        "chizz pizza , salad, souce puch , onine, origeno",
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹ 120",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(isSwitched ? "On" : "Off"),
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: isSwitched,
                                  onChanged: (value) {
                                    setState(() {
                                      isSwitched = value;
                                    });
                                  },
                                  activeColor: Colors.white, // ON thumb
                                  activeTrackColor:
                                      Colors.orangeAccent, // ON background
                                  inactiveThumbColor: Colors.grey, // OFF thumb
                                  inactiveTrackColor:
                                      Colors.black26, // OFF background
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        
                        children: [
                          Container(
                            width: 180,
                            height: 30,
                            child: TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.edit),
                              label: Text(
                                "data",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                iconColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(width: 16),
                          TextButton.icon(
                            onPressed: () {
                              print('Delete pressed');
                            },
                            icon: Icon(Icons.delete, color: Colors.red),
                            label: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            style: TextButton.styleFrom(
                              side: BorderSide(
                  
                                  color: Colors.grey,
                                  width: 1.5,
                                ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
