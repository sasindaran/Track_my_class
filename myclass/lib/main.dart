import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestStoragePermission();
  runApp(const MyApp());
}

Future<void> requestStoragePermission() async {
  final status = await Permission.manageExternalStorage.request();
  if (status.isGranted) {
    print('Storage permission granted');
  } else if (status.isDenied) {
    print('Storage permission denied');
  } else if (status.isPermanentlyDenied) {
    print('Storage permission permanently denied');
    // You can navigate the user to app settings here to enable the permission manually.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // Segar Dir
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 150, 235, 153)),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'splash.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // Segar Dir
//         colorScheme:
//             ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 150, 235, 153)),
//         useMaterial3: true,
//       ),
//       home: SplashScreen(),
//     );
//   }
// }
