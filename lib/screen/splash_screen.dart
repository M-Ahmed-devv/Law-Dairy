import 'package:flutter/material.dart';
import 'dart:async';

import 'homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 Second ka timer lagaya hai, uske baad khud Home Screen par chala jayega
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A2E2B), // Brown Leather color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Lawyer Icon (Hathora)
            Icon(
              Icons.gavel,
              size: 100,
              color: Color(0xFFFDF6E3), // Cream Color
            ),
            SizedBox(height: 20),

            // App Name
            Text(
              "LAWYER'S DIARY",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFDF6E3),
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 10),

            // Subtitle
            Text(
              "Arain law chamber case dairy ",
              style: TextStyle(
                
                fontSize: 16,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),

            SizedBox(height: 50),

            // Loading Spinner
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDF6E3)),
            ),
          ],
        ),
      ),
    );
  }
}
