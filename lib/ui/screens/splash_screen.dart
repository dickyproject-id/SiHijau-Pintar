import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Transparent status bar with dark icons
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: Stack(
          children: [
            // Top Decoration
            Positioned(
              top: -50,
              right: -30,
              child: Image.asset(
                'assets/vector/Vector splashscreen.png',
                width: MediaQuery.of(context).size.width * 0.65,
                fit: BoxFit.cover,
              ),
            ),

            // Left Leaf (Daun kiri)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: -40,
              child: Transform.rotate(
                angle: 0.1, // Adjusting rotation to match reference
                child: Image.asset('assets/daun.png', width: 100, height: 100),
              ),
            ),

            // Right Leaf (Daun kanan, mirrored)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.45,
              right: -40,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi)
                  ..rotateZ(0.1), // Mirror horizontal + rotate
                child: Image.asset('assets/daun.png', width: 100, height: 100),
              ),
            ),

            // Footer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/footer spashscreen.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),

            // Center Content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Image.asset(
                      'assets/logo.png',
                      width: 287, // Restored original size
                      height: 287,
                      fit: BoxFit.contain,
                    ),
                    Transform.translate(
                      offset: const Offset(
                        0,
                        -30,
                      ), // Pull text up to reduce gap
                      child: Column(
                        children: [
                          Text(
                            'SiHijau Pintar',
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B5E20),
                              letterSpacing: 0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cek Kesehatan Tanamanmu\ndengan AI',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w500, // Medium
                              color: const Color(0xFF388E3C), // Lighter green
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // Logo Dana di kanan bawah
            Positioned(
              bottom: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, bottom: 16.0),
                  child: Image.asset(
                    'assets/dana.png',
                    width: MediaQuery.of(context).size.width * 0.18, // Increased size slightly
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
