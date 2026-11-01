import 'package:flutter/material.dart';
import 'package:lawyer_diary/screen/coverscreen.dart';
import 'services/notificationservice.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Lawyer's Diary",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4A2E2B),
        scaffoldBackgroundColor: const Color(0xFFF5E9D4),
      ),
      home: const CoverScreen(),
    );
  }
}