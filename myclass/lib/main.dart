import 'package:flutter/material.dart';
import 'splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // Segar Dir
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 150, 235, 153)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
