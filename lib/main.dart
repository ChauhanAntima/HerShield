// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'auth_wrapper.dart';
// import 'package:permission_handler/permission_handler.dart'; // Permissions ke liye
// import 'child/bottom_screens/child_home_page.dart'; // Aapka Home Screen path
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await _askPermissions();
//   runApp(const MyApp());
// }
//
// // Permissions maangne ka function
// Future<void> _askPermissions() async {
//   await [
//     Permission.location,
//     Permission.sms,
//     Permission.notification, // SOS alerts ke liye zaroori ho sakta hai
//   ].request();
// }
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Women Safety App',
//       theme: ThemeData(
//         primaryColor: const Color(0xFFFFF5F8),
//         useMaterial3: true,
//       ),
//       home: const AuthWrapper(), // 🔥 ENTRY POINT
//     );
//   }
// }

//
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Agar Firebase use kar rahi hain
// import 'package:permission_handler/permission_handler.dart'; // Permissions ke liye
// import 'child/bottom_screens/child_home_page.dart'; // Aapka Home Screen path
//
// // Note: Agar aapne AuthWrapper use karna hai toh use bhi import karein
// // import 'auth_wrapper.dart';
//
// Future<void> main() async {
//   // 1. Flutter Engine ko initialize karna zaroori hai
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // 2. Firebase initialize karna (Agar aap Firebase use kar rahi hain)
//   // try {
//   //   await Firebase.initializeApp();
//   // } catch (e) {
//   //   print("Firebase initialization error: $e");
//   // }
//
//   // 3. App start hote hi permissions maangna (Best for Safety Apps)
//   await Firebase.initializeApp();
//   await _askPermissions();
//
//   runApp(const MyApp());
// }
//
// // Permissions maangne ka function
// Future<void> _askPermissions() async {
//   await [
//     Permission.location,
//     Permission.sms,
//     Permission.notification, // SOS alerts ke liye zaroori ho sakta hai
//   ].request();
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Women Safety',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
//         useMaterial3: true,
//       ),
//       // 🔥 Agar Login system hai toh AuthWrapper() rakhein,
//       // nahi toh direct HomeScreen()
//       home: const HomeScreen(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  await _askPermissions();
  runApp(const MyApp());
}
Future<void> _askPermissions() async {
  await [
    Permission.location,
    Permission.sms,
    Permission.phone,
    Permission.notification,
  ].request();
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Women Safety App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}