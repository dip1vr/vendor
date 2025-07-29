import 'package:flutter/material.dart';

class desh extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Dashboard',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(10.0),
          child: Column(
            children: [
              Text(
                
                "Welcome back to kfd restaurant",
                style: TextStyle(fontSize: 12.0, color: Colors.black),
              ),
              SizedBox(height: 20.0),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 4.0,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Icon(Icons.restaurant_menu, size: 50.0, color: Colors.blue),
                                SizedBox(height: 10.0),
                                Text(
                                  'Menu',
                                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                       ),
                       SizedBox(width: 10.0),
                      Expanded(
                        child: Card(
                          elevation: 4.0,
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Icon(Icons.receipt, size: 50.0, color: Colors.green),
                                SizedBox(height: 10.0),
                                Text(
                                  'Orders',
                                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(

                  ),

                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
