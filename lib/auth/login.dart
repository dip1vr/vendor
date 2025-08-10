import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vendor_fixed/auth/signup.dart';
import 'package:vendor_fixed/desh.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  late Animation<Color?> _color1;
  late Animation<Color?> _color2;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool _obscureText = true; // Added for password visibility toggle

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
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                index = (index + 1) % gradientColors.length;
              });
              _startAnimation();
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

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        Get.snackbar(
          "Login Successful",
          "Welcome back, ${credential.user?.email ?? 'User'}!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Desh()),
        );
      } on FirebaseAuthException catch (e) {
        String message;
        switch (e.code) {
          case 'user-not-found':
            message = 'User not registered. Please sign up first.';
            break;
          case 'wrong-password':
            message = 'Password is incorrect.';
            break;
          case 'invalid-email':
            message = 'Invalid email format.';
            break;
          case 'user-disabled':
            message = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            message = 'Too many failed attempts. Please try again later.';
            break;
          case 'operation-not-allowed':
            message = 'This sign-in method is not enabled.';
            break;
          case 'network-request-failed':
            message = 'Network error. Please check your internet connection.';
            break;
          default:
            message = e.message ?? 'Login failed. Please try again.';
        }

        Get.snackbar(
          "Login Failed",
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          borderRadius: 8,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.9,
                      maxHeight: screenHeight * 0.9,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
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
                            radius: screenWidth * 0.08,
                            backgroundColor: Colors.orange.shade100.withOpacity(0.5),
                            child: Icon(
                              FeatherIcons.user,
                              color: Colors.deepOrange.withOpacity(0.6),
                              size: screenWidth * 0.08,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          Text(
                            "Welcome Back",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            "Sign in to your restaurant dashboard",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.035,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: screenHeight * 0.03),

                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: "Email Address",
                              prefixIcon: const Icon(FeatherIcons.mail),
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

                          SizedBox(height: screenHeight * 0.02),

                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscureText, // Use state variable
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.deepOrange,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              labelText: "Password",
                              prefixIcon: const Icon(FeatherIcons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText ? Icons.visibility_off : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText; // Toggle visibility
                                  });
                                },
                              ),
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

                          SizedBox(height: screenHeight * 0.015),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.deepOrange,
                                      value: rememberMe,
                                      onChanged: (value) {
                                        setState(() => rememberMe = value!);
                                      },
                                    ),
                                    Flexible(
                                      child: Text(
                                        "Remember me",
                                        style: GoogleFonts.poppins(fontSize: screenWidth * 0.035),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: TextButton(
                                  onPressed: () async {
                                    if (emailController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Enter your email to reset password",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    try {
                                      await FirebaseAuth.instance
                                          .sendPasswordResetEmail(
                                            email: emailController.text.trim(),
                                          );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Password reset link sent to your email",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Error sending reset email",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Forgot password?",
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.025),

                          SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.06,
                            child: ElevatedButton(
                              onPressed: _loginUser,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.017),
                                backgroundColor: Colors.deepOrange,
                              ),
                              child: Text(
                                "Sign In",
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.045,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: GoogleFonts.poppins(fontSize: screenWidth * 0.035),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
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
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
          ),
        );
      },
    );
  }
}