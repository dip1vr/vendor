import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart'
    show FeatherIcons;
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_fixed/auth/signup.dart';
import 'package:vendor_fixed/desh.dart';

class LoginPage extends StatefulWidget {
  final _formKey = GlobalKey<FormState>();
  @override
  _LoginPageState createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  // 🟢 Add these missing variables
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  final List<List<Color>> gradientColors = [
    [Colors.deepOrange, Colors.pink],
    [Colors.purple, Colors.blue],
    [Colors.teal, Colors.green],
    [Colors.redAccent, Colors.amber],
  ];

  int index = 0;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                index = (index + 1) % gradientColors.length;
              });
              _startAnimation(); // loop again
            }
          });

    _startAnimation();
  }

  void _startAnimation() {
    final nextIndex = (index + 1) % gradientColors.length;

    _color1 = ColorTween(
      begin: gradientColors[index][0],
      end: gradientColors[nextIndex][0],
    ).animate(_controller);
    _color2 = ColorTween(
      begin: gradientColors[index][1],
      end: gradientColors[nextIndex][1],
    ).animate(_controller);

    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _color1.value ?? Colors.orange,
                  _color2.value ?? Colors.pink,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.orange.shade100.withOpacity(
                            0.5,
                          ),
                          child: Icon(
                            FeatherIcons.user,
                            color: Colors.deepOrange.withOpacity(0.6),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          "Welcome Back",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to your restaurant dashboard",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                
                                color: Colors.deepOrange,
                                width: 2,
                                
                              ),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            labelText: "Email Address",
                            prefixIcon: Icon(FeatherIcons.mail),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            );
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                
                                color: Colors.deepOrange,
                                width: 2,
                                
                              ),
                              borderRadius: BorderRadius.circular(12)
                            ),
                            labelText: "Password",
                            prefixIcon: Icon(FeatherIcons.lock),
                            suffixIcon: Icon(Icons.visibility_off),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.deepOrange,
                                  value: rememberMe,
                                  onChanged: (value) {
                                    setState(() => rememberMe = value!);
                                  },
                                ),
                                Text(
                                  "Remember me",
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                "Forgot password?",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  Desh(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.deepOrange,
                            ),
                            child: Text(
                              "Sign In",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigate to SignUpScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  Signup(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign up",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
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
            ),
          ),
        );
      },
    );
  }
}
