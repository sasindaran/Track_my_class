import 'package:flutter/material.dart';
import 'dart:async';
import 'AttendanceTrackerPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Delay for 1.5 seconds and then navigate to the main screen
    Timer(
      Duration(seconds: 2),
      () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                AttendanceTrackerPage(), // Replace with your main screen widget
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color.fromARGB(255, 150, 235, 153), // Facebook blue color
      body: Center(
        child: Text(
          'Track My Class',
          style: TextStyle(
            fontSize: 24.0,
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
