import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vendor_fixed/auth/login.dart';
import 'package:vendor_fixed/main_layout.dart';

import 'package:vendor_fixed/controllers/theme_controller.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // navigation bar color
      statusBarColor: Colors.transparent, // status bar color
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDVLjv3V3LU6h_MbAgjyDiY_Y1yt5Ov-wk",
        appId: "1:1066214452856:android:61af7a7cfbafac3bd6478d",
        messagingSenderId: "1066214452856",
        projectId: "deliveryapp-b595e",
        storageBucket: "deliveryapp-b595e.firebasestorage.app",
      ),
    );
    print("✅ Firebase Initialized Successfully!");
  } catch (e) {
    print("❌ Firebase Initialization Failed: $e");
  }

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => ProviderScope(child: const MyApp()),
    ),
  );
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: InitialBinding(),
      theme: ThemeData(textTheme: GoogleFonts.latoTextTheme()),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the stream is waiting, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFFF5722)),
              ),
            );
          }

          // If we have a user, go to MainLayout (Persistent Bottom Nav)
          if (snapshot.hasData) {
            return const MainLayout();
          }

          // Otherwise, go to Login
          return const LoginPage();
        },
      ),
    );
  }
}
