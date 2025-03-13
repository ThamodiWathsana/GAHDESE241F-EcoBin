import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'getstarted.dart'; // Import the Get Started page
// Import the user type selection page

void main() {
  runApp(
    DevicePreview(
      enabled: true, // Enable device preview
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waste Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GetStartedPage(), // Open Get Started Page first
      builder: DevicePreview.appBuilder,
      locale: DevicePreview.locale(context),
    );
  }
}
