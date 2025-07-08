import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// Entry point of the app - this runs first
void main() {
  runApp(const Jobsy());
}

// Main app widget - sets up the app theme and home page
class Jobsy extends StatelessWidget {
  const Jobsy({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ), // Orange theme for construction
      home: HomeScreen(), // First screen users see
    );
  }
}
