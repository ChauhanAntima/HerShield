// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import 'package:womensafety/widgets/home_widgets/CustomCarousel.dart';
// import '../../db/db_services.dart';
// import '../../model/contactsm.dart';
// import '../../widgets/home_widgets/custom_appBar.dart';
// import '../../widgets/home_widgets/emergency.dart';
// import '../../widgets/home_widgets/livesafe.dart';
// import '../../widgets/home_widgets/safehome/SafeHome.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int qIndex = 0;
//
//   Position? _curentPosition;
//   String? _curentAddress;
//   String _currentCity = "";
//
//   bool _locationPermissionGranted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     getRandomQuote();
//     _getPermission();
//   }
//
//   // ================= PERMISSIONS =================
//   _getPermission() async => await [Permission.sms].request();
//   _isPermissionGranted() async => await Permission.sms.status.isGranted;
//
//   // ================= LOCATION =================
//   Future<bool> _requestLocationPermission() async {
//     var status = await Permission.location.request();
//     return status == PermissionStatus.granted;
//   }
//
//   checkLocationPermission() async {
//     bool permissionGranted = await _requestLocationPermission();
//     setState(() {
//       _locationPermissionGranted = permissionGranted;
//     });
//
//     if (_locationPermissionGranted) {
//       _getCurrentCity();
//     }
//   }
//
//   void _getCurrentCity() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(position.latitude, position.longitude);
//
//       if (placemarks.isNotEmpty) {
//         setState(() {
//           _currentCity = placemarks.first.locality ?? 'Unknown';
//         });
//       }
//     } catch (e) {
//       debugPrint('Error getting city: $e');
//     }
//   }
//
//   // ================= QUOTE =================
//   getRandomQuote() {
//     Random random = Random();
//     setState(() {
//       qIndex = random.nextInt(6);
//     });
//   }
//
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         // 🌸 SOFT BLUSH GRADIENT BACKGROUND
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFFFF0F5), // very light pink (top)
//               Color(0xFFFFE4EC), // blush pink (bottom)
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 5),
//
//                 // 🔹 CUSTOM APP BAR
//                 CustomAppBar(
//                   quoteIndex: qIndex,
//                   onTap: getRandomQuote,
//                 ),
//
//                 const SizedBox(height: 5),
//
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       const SizedBox(height: 10),
//
//                       // 🔹 LOCATION CARD
//                       Container(
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFFFF5F8), // card bg
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.all(12),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CircleAvatar(
//                               backgroundColor: Colors.pink.shade100,
//                               child: const Icon(
//                                 Icons.location_on,
//                                 color: Colors.pink,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     _locationPermissionGranted
//                                         ? "Location enabled"
//                                         : "Turn on location services",
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     _currentCity.isEmpty
//                                         ? "Enable location for better experience"
//                                         : "Current City: $_currentCity",
//                                   ),
//                                   const SizedBox(height: 6),
//                                   if (!_locationPermissionGranted)
//                                     TextButton(
//                                       onPressed: checkLocationPermission,
//                                       child: const Text("Enable location"),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 12),
//
//                       // 🔹 EMERGENCY SECTION
//                       const Center(
//                         child: Text(
//                           "In case of emergency dial",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 8),
//                       Emergency(),
//
//                       const SizedBox(height: 16),
//
//                       // 🔹 QUOTES / POWER
//                       const Center(
//                         child: Text(
//                           "Explore your power",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 10),
//                       CustomCarousel(),
//
//                       const SizedBox(height: 16),
//
//                       // 🔹 LIVE SAFE
//                       const Center(
//                         child: Text(
//                           "Explore LiveSafe",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 10),
//                       LiveSafe(),
//
//                       const SizedBox(height: 10),
//                       SafeHome(),
//
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

//
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import 'package:womensafety/widgets/home_widgets/CustomCarousel.dart';
// import '../../widgets/home_widgets/custom_appBar.dart';
// import '../../widgets/home_widgets/emergency.dart';
// import '../../widgets/home_widgets/livesafe.dart';
// import '../../widgets/home_widgets/safehome/SafeHome.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int qIndex = 0;
//   String _currentCity = "";
//   bool _locationPermissionGranted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     getRandomQuote();
//     _requestLocationPermission();
//   }
//
//   // ================= QUOTES =================
//   void getRandomQuote() {
//     setState(() {
//       qIndex = Random().nextInt(6);
//     });
//   }
//
//   // ================= LOCATION =================
//   Future<void> _requestLocationPermission() async {
//     var status = await Permission.location.request();
//     if (status == PermissionStatus.granted) {
//       _locationPermissionGranted = true;
//       _getCurrentCity();
//     }
//     setState(() {});
//   }
//
//   void _getCurrentCity() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(position.latitude, position.longitude);
//
//       if (placemarks.isNotEmpty) {
//         setState(() {
//           _currentCity = placemarks.first.locality ?? '';
//         });
//       }
//     } catch (_) {}
//   }
//
//   // ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // ✅ WHITE BACKGROUND
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             children: [
//               // 🔹 QUOTE / APP BAR
//               CustomAppBar(
//                 quoteIndex: qIndex,
//                 onTap: getRandomQuote,
//               ),
//
//               const SizedBox(height: 10),
//
//               Expanded(
//                 child: ListView(
//                   children: [
//                     // 🔹 LOCATION CARD
//                     Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF5F8), // soft pastel card
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             backgroundColor: Colors.pink.shade100,
//                             child: const Icon(
//                               Icons.location_on,
//                               color: Colors.pink,
//                             ),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   _locationPermissionGranted
//                                       ? "Location enabled"
//                                       : "Turn on location services",
//                                   style: const TextStyle(
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   _currentCity.isEmpty
//                                       ? "Enable location for better experience"
//                                       : "Current City: $_currentCity",
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // 🔹 CAROUSEL
//                     CustomCarousel(),
//
//                     const SizedBox(height: 20),
//
//                     // 🔹 EMERGENCY
//                     const Text(
//                       "Emergency",
//                       style:
//                       TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Emergency(),
//
//                     const SizedBox(height: 20),
//
//                     // 🔹 LIVE SAFE
//                     const Text(
//                       "Live Safe",
//                       style:
//                       TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     LiveSafe(),
//
//                     const SizedBox(height: 20),
//
//                     // 🔹 SEND LOCATION
//                     SafeHome(),
//
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//
// import 'dart:math';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_volume_controller/flutter_volume_controller.dart';
// import 'package:sms_sender_background/sms_sender.dart'; // ✅ Telephony ki jagah naya import
//
// import 'package:womensafety/widgets/home_widgets/CustomCarousel.dart';
// import '../../widgets/home_widgets/custom_appBar.dart';
// import '../../widgets/home_widgets/emergency.dart';
// import '../../widgets/home_widgets/livesafe.dart';
// import '../../widgets/home_widgets/safehome/SafeHome.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int qIndex = 0;
//   String _currentCity = "";
//   bool _locationPermissionGranted = false;
//
//   // 🔥 SOS Variables
//   int _pressCount = 0;
//   Timer? _timer;
//   final smsSender = SmsSender(); // ✅ SmsSender ka instance
//
//   @override
//   void initState() {
//     super.initState();
//     getRandomQuote();
//     _requestPermissions();
//
//     // 🔥 Volume Button Listener Setup
//     FlutterVolumeController.addListener((volume) {
//       _handleVolumePress();
//     });
//   }
//
//   @override
//   void dispose() {
//     FlutterVolumeController.removeListener();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   // 🔥 SOS Logic: 4 Baar Press Detect Karna
//   void _handleVolumePress() {
//     setState(() {
//       _pressCount++;
//     });
//
//     print("Volume Pressed: $_pressCount");
//
//     if (_pressCount == 1) {
//       _timer = Timer(Duration(seconds: 5), () {
//         setState(() {
//           _pressCount = 0;
//         });
//         print("SOS Counter Reset");
//       });
//     }
//
//     if (_pressCount >= 4) {
//       _timer?.cancel();
//       _pressCount = 0;
//       _sendSOS(); // SOS Function Call
//     }
//   }
//
//   // 🔥 SOS Action: Location nikalna aur SMS bhejna
//   Future<void> _sendSOS() async {
//     try {
//       // 1. Current Location nikalna
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       String mapUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
//       String message = "EMERGENCY! Meri location: $mapUrl";
//
//       // 2. Permission Check (Naye package ke mutabik)
//       bool hasPermission = await smsSender.checkSmsPermission();
//       if (!hasPermission) {
//         hasPermission = await smsSender.requestSmsPermission();
//       }
//
//       if (hasPermission) {
//         // 3. SMS Bhejna (Yahan target number badal dein)
//         await smsSender.sendSms(
//           phoneNumber: "+919343866460",
//           message: message,
//         );
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("SOS Sent Successfully!"),
//               backgroundColor: Colors.red,
//               duration: Duration(seconds: 3),
//             ),
//           );
//         }
//       } else {
//         print("SMS Permission Denied");
//       }
//     } catch (e) {
//       print("SOS Error: $e");
//     }
//   }
//
//   // ================= QUOTES =================
//   void getRandomQuote() {
//     setState(() {
//       qIndex = Random().nextInt(6);
//     });
//   }
//
//   // ================= PERMISSIONS =================
//   Future<void> _requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.location,
//       Permission.sms,
//     ].request();
//
//     if (statuses[Permission.location] == PermissionStatus.granted) {
//       _locationPermissionGranted = true;
//       _getCurrentCity();
//     }
//     setState(() {});
//   }
//
//   void _getCurrentCity() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(position.latitude, position.longitude);
//
//       if (placemarks.isNotEmpty) {
//         setState(() {
//           _currentCity = placemarks.first.locality ?? '';
//         });
//       }
//     } catch (_) {}
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             children: [
//               CustomAppBar(
//                 quoteIndex: qIndex,
//                 onTap: getRandomQuote,
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: ListView(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF5F8),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             backgroundColor: Colors.pink.shade100,
//                             child: const Icon(Icons.location_on, color: Colors.pink),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   _locationPermissionGranted
//                                       ? "Location enabled"
//                                       : "Turn on location services",
//                                   style: const TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   _currentCity.isEmpty
//                                       ? "Fetching location..."
//                                       : "Current City: $_currentCity",
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     CustomCarousel(),
//                     const SizedBox(height: 20),
//                     const Text("Emergency", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Emergency(),
//                     const SizedBox(height: 20),
//                     const Text("Live Safe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     LiveSafe(),
//                     const SizedBox(height: 20),
//                     SafeHome(),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


//
//
// import 'dart:math';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_volume_controller/flutter_volume_controller.dart';
// import 'package:sms_sender_background/sms_sender.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// // 🔥 In paths ko apne project ke hisaab se check kar lein
// import '../../db/db_services.dart';
// import '../../model/contactsm.dart';
//
// import 'package:womensafety/widgets/home_widgets/CustomCarousel.dart';
// import '../../widgets/home_widgets/custom_appBar.dart';
// import '../../widgets/home_widgets/emergency.dart';
// import '../../widgets/home_widgets/livesafe.dart';
// import '../../widgets/home_widgets/safehome/SafeHome.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int qIndex = 0;
//   String _currentCity = "";
//   bool _locationPermissionGranted = false;
//
//   // 🔥 SOS Variables
//   int _pressCount = 0;
//   Timer? _timer;
//   final smsSender = SmsSender();
//   final DatabaseHelper _databaseHelper = DatabaseHelper(); // ✅ Database helper ka instance
//
//   @override
//   void initState() {
//     super.initState();
//     getRandomQuote();
//     _requestPermissions();
//
//     // 🔥 Volume Button Listener Setup
//     FlutterVolumeController.addListener((volume) {
//       _handleVolumePress();
//     });
//   }
//
//   @override
//   void dispose() {
//     FlutterVolumeController.removeListener();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   // 🔥 Volume Logic
//   void _handleVolumePress() {
//     setState(() {
//       _pressCount++;
//     });
//
//     print("Volume Pressed: $_pressCount");
//
//     if (_pressCount == 1) {
//       _timer = Timer(Duration(seconds: 5), () {
//         if (mounted) {
//           setState(() {
//             _pressCount = 0;
//           });
//         }
//         print("SOS Counter Reset");
//       });
//     }
//
//     if (_pressCount >= 4) {
//       _timer?.cancel();
//       _pressCount = 0;
//       _sendSOS();
//     }
//   }
//
//   // 🔥 SOS Action: Saare Saved Contacts ko SMS bhejna
//   Future<void> _sendSOS() async {
//     try {
//       // 1. Database se contacts ki list nikalna
//       List<TContact> contactList = await _databaseHelper.getContactList();
//
//       if (contactList.isEmpty) {
//         Fluttertoast.showToast(
//           msg: "No trusted contacts! Please add some first.",
//           backgroundColor: Colors.red,
//         );
//         return;
//       }
//
//       // 2. Current Location nikalna
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       String mapUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
//       String message = "EMERGENCY ALERT! Meri location: $mapUrl";
//
//       // 3. Permission Check
//       bool hasPermission = await smsSender.checkSmsPermission();
//       if (!hasPermission) {
//         hasPermission = await smsSender.requestSmsPermission();
//       }
//
//       if (hasPermission) {
//         int successCount = 0;
//
//         // 4. Loop: Saare contacts ko ek-ek karke SMS bhejna (Slot 0/SIM 1 default)
//         for (TContact contact in contactList) {
//           try {
//             await smsSender.sendSms(
//               phoneNumber: contact.number,
//               message: message,
//             );
//             successCount++;
//           } catch (e) {
//             print("Error sending to ${contact.number}: $e");
//           }
//         }
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Alert sent to $successCount contacts!"),
//               backgroundColor: Colors.red,
//               duration: const Duration(seconds: 4),
//             ),
//           );
//         }
//       } else {
//         Fluttertoast.showToast(msg: "SMS Permission Denied");
//       }
//     } catch (e) {
//       print("SOS Error: $e");
//       Fluttertoast.showToast(msg: "Failed to trigger SOS");
//     }
//   }
//
//   // ================= Baki Functions =================
//   void getRandomQuote() {
//     setState(() {
//       qIndex = Random().nextInt(6);
//     });
//   }
//
//   Future<void> _requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.location,
//       Permission.sms,
//     ].request();
//
//     if (statuses[Permission.location] == PermissionStatus.granted) {
//       _locationPermissionGranted = true;
//       _getCurrentCity();
//     }
//     setState(() {});
//   }
//
//   void _getCurrentCity() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(position.latitude, position.longitude);
//
//       if (placemarks.isNotEmpty) {
//         setState(() {
//           _currentCity = placemarks.first.locality ?? '';
//         });
//       }
//     } catch (_) {}
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             children: [
//               CustomAppBar(quoteIndex: qIndex, onTap: getRandomQuote),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: ListView(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF5F8),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             backgroundColor: Colors.pink.shade100,
//                             child: const Icon(Icons.location_on, color: Colors.pink),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   _locationPermissionGranted ? "Location enabled" : "Turn on location services",
//                                   style: const TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(_currentCity.isEmpty ? "Fetching location..." : "City: $_currentCity"),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     CustomCarousel(),
//                     const SizedBox(height: 20),
//                     const Text("Emergency", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Emergency(),
//                     const SizedBox(height: 20),
//                     const Text("Live Safe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     LiveSafe(),
//                     const SizedBox(height: 20),
//                     SafeHome(),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


//
//
// import 'dart:math';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:flutter_volume_controller/flutter_volume_controller.dart';
// import 'package:sms_sender_background/sms_sender.dart'; // ✅ SMS package
// import 'package:fluttertoast/fluttertoast.dart';
//
// // 🔥 Aapke Database aur Model ke sahi paths
// import '../../db/db_services.dart';
// import '../../model/contactsm.dart';
//
// // UI Widgets
// import 'package:womensafety/widgets/home_widgets/CustomCarousel.dart';
// import '../../widgets/home_widgets/custom_appBar.dart';
// import '../../widgets/home_widgets/emergency.dart';
// import '../../widgets/home_widgets/livesafe.dart';
// import '../../widgets/home_widgets/safehome/SafeHome.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int qIndex = 0;
//   String _currentCity = "";
//   bool _locationPermissionGranted = false;
//
//   // 🔥 SOS Variables
//   int _pressCount = 0;
//   Timer? _timer;
//   final smsSender = SmsSender();
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//
//   @override
//   void initState() {
//     super.initState();
//     getRandomQuote();
//     _requestPermissions();
//
//     // 🔥 Volume Button Listener: Hardware buttons ko detect karta hai
//     FlutterVolumeController.addListener((volume) {
//       _handleVolumePress();
//     });
//
//     // Volume bar ko screen par hide karne ke liye
//     FlutterVolumeController.showSystemUI = false;
//   }
//
//   @override
//   void dispose() {
//     FlutterVolumeController.removeListener();
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   // 🔥 Logic: 4 bar press hone par SOS trigger hoga
//   void _handleVolumePress() {
//     setState(() {
//       _pressCount++;
//     });
//
//     print("Volume Key Pressed. Counter: $_pressCount");
//
//     if (_pressCount == 1) {
//       _timer = Timer(Duration(seconds: 5), () {
//         if (mounted) {
//           setState(() {
//             _pressCount = 0;
//           });
//         }
//         print("SOS Counter Reset due to timeout");
//       });
//     }
//
//     if (_pressCount >= 4) {
//       _timer?.cancel();
//       _pressCount = 0;
//       _sendSOS(); // 🔥 SOS SMS bhejne ka function call
//     }
//   }
//
//   // 🔥 Main SOS Function: Location nikalna aur Saare Contacts ko SMS bhejna
//   Future<void> _sendSOS() async {
//     try {
//       // 1. Database se saare saved contacts lena
//       List<TContact> contactList = await _databaseHelper.getContactList();
//
//       if (contactList.isEmpty) {
//         Fluttertoast.showToast(
//           msg: "Emergency! No contacts added. Please add trusted contacts first.",
//           backgroundColor: Colors.red,
//         );
//         return;
//       }
//
//       // 2. User ki Current Location lena
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       String mapUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
//       String message = "EMERGENCY! I need help. My current location is: $mapUrl";
//
//       // 3. SMS Permission Check
//       bool hasPermission = await smsSender.checkSmsPermission();
//       if (!hasPermission) {
//         hasPermission = await smsSender.requestSmsPermission();
//       }
//
//       if (hasPermission) {
//         int successCount = 0;
//
//         // 4. Loop: Saare contacts ko SMS bhejna
//         for (TContact contact in contactList) {
//           try {
//             // 🔥 CRITICAL: Number se spaces aur dash hatana (Taaki SMS fail na ho)
//             String cleanNumber = contact.number.replaceAll(RegExp(r'\s+'), "").replaceAll("-", "");
//
//             print("Sending SOS to: $cleanNumber");
//
//             await smsSender.sendSms(
//               phoneNumber: cleanNumber,
//               message: message,
//             );
//             successCount++;
//           } catch (e) {
//             print("Failed to send to ${contact.number}: $e");
//           }
//         }
//
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Alert sent to $successCount contacts!"),
//               backgroundColor: Colors.red,
//               duration: const Duration(seconds: 4),
//             ),
//           );
//         }
//       } else {
//         Fluttertoast.showToast(msg: "SMS Permission Denied!");
//       }
//     } catch (e) {
//       print("SOS ERROR: $e");
//       Fluttertoast.showToast(msg: "SOS Failed: $e");
//     }
//   }
//
//   // ================= Standard Functions =================
//
//   void getRandomQuote() {
//     setState(() {
//       qIndex = Random().nextInt(6);
//     });
//   }
//
//   Future<void> _requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.location,
//       Permission.sms,
//       Permission.phone,
//     ].request();
//
//     if (statuses[Permission.location] == PermissionStatus.granted) {
//       _locationPermissionGranted = true;
//       _getCurrentCity();
//     }
//     setState(() {});
//   }
//
//   void _getCurrentCity() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(position.latitude, position.longitude);
//
//       if (placemarks.isNotEmpty) {
//         setState(() {
//           _currentCity = placemarks.first.locality ?? '';
//         });
//       }
//     } catch (_) {}
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             children: [
//               CustomAppBar(quoteIndex: qIndex, onTap: getRandomQuote),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: ListView(
//                   children: [
//                     // Location Info Card
//                     Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFFF5F8),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       padding: const EdgeInsets.all(12),
//                       child: Row(
//                         children: [
//                           CircleAvatar(
//                             backgroundColor: Colors.pink.shade100,
//                             child: const Icon(Icons.location_on, color: Colors.pink),
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   _locationPermissionGranted ? "Location enabled" : "Location disabled",
//                                   style: const TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(_currentCity.isEmpty ? "Updating location..." : "City: $_currentCity"),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     CustomCarousel(),
//                     const SizedBox(height: 20),
//                     const Text("Emergency", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 8),
//                     Emergency(),
//                     const SizedBox(height: 20),
//                     const Text("Live Safe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     LiveSafe(),
//                     const SizedBox(height: 20),
//                     SafeHome(),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ MethodChannel ke liye zaroori
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';

// 🔥 Aapke Database aur Model ke paths (Inhe check kar lein)
import '../../db/db_services.dart';
import '../../model/contactsm.dart';

// UI Widgets
import 'package:womensafety/widgets/home_widgets/CustomCarousel.dart';
import '../../widgets/home_widgets/custom_appBar.dart';
import '../../widgets/home_widgets/emergency.dart';
import '../../widgets/home_widgets/livesafe.dart';
import '../../widgets/home_widgets/safehome/SafeHome.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 0;
  String _currentCity = "";
  bool _locationPermissionGranted = false;

  // 🔥 SOS Variables
  int _pressCount = 0;
  Timer? _timer;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // ✅ MethodChannel: Ye MainActivity.kt se baat karne ke liye hai
  static const platform = MethodChannel('com.example.womensafety/sms');

  @override
  void initState() {
    super.initState();
    getRandomQuote();
    _requestPermissions();

    // 🔥 Volume Button Listener: Hardware button detect karne ke liye
    FlutterVolumeController.addListener((volume) {
      _handleVolumePress();
    });

    // Volume bar ko screen par hide rakhta hai
    FlutterVolumeController.showSystemUI = false;
  }

  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    _timer?.cancel();
    super.dispose();
  }

  // 🔥 Volume Logic: 5 second ke andar 4 baar dabana hai
  void _handleVolumePress() {
    setState(() {
      _pressCount++;
    });

    print("Volume Key Pressed. Total Presses: $_pressCount");

    if (_pressCount == 1) {
      _timer = Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _pressCount = 0;
          });
        }
        print("SOS Counter Reset");
      });
    }

    if (_pressCount >= 4) {
      _timer?.cancel();
      _pressCount = 0;
      _sendSOS(); // 🔥 SOS Alert bhejna shuru karega
    }
  }

  // 🔥 Main SOS Function: Native Android code ka use karke SMS bhejna
  Future<void> _sendSOS() async {
    try {
      // 1. Database se saare saved contacts lena
      List<TContact> contactList = await _databaseHelper.getContactList();

      if (contactList.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please add trusted contacts first!",
          backgroundColor: Colors.red,
        );
        return;
      }

      // 2. Current Location nikalna
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String mapUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
      String message = "EMERGENCY! I need help. My location: $mapUrl";

      // 3. Loop: Saare contacts ko SMS bhejna
      int successCount = 0;
      for (TContact contact in contactList) {
        // Number se spaces aur dash hatana
        String cleanNumber = contact.number.replaceAll(RegExp(r'\s+'), "").replaceAll("-", "");

        try {
          // ✅ MainActivity.kt ke 'sendDirectSms' method ko call karna
          final String result = await platform.invokeMethod('sendDirectSms', {
            "phone": cleanNumber,
            "msg": message,
          });

          if (result == "SMS Sent Successfully") {
            successCount++;
          }
        } on PlatformException catch (e) {
          print("Native SMS Error: ${e.message}");
        }
      }

      // 4. Confirmation UI par dikhana
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Alert sent to $successCount contacts!"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print("SOS ERROR: $e");
      Fluttertoast.showToast(msg: "Failed to trigger SOS: $e");
    }
  }

  // ================= Baki App Functions =================
  void getRandomQuote() {
    setState(() {
      qIndex = Random().nextInt(6);
    });
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.sms,
      Permission.phone, // Native SMS ke liye ye zaroori hai
    ].request();

    if (statuses[Permission.location] == PermissionStatus.granted) {
      _locationPermissionGranted = true;
      _getCurrentCity();
    }
    setState(() {});
  }

  void _getCurrentCity() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        setState(() {
          _currentCity = placemarks.first.locality ?? '';
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              CustomAppBar(quoteIndex: qIndex, onTap: getRandomQuote),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    // Location Card
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.pink.shade100,
                            child: const Icon(Icons.location_on, color: Colors.pink),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _locationPermissionGranted ? "Location enabled" : "Location disabled",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(_currentCity.isEmpty ? "Updating location..." : "City: $_currentCity"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomCarousel(),
                    const SizedBox(height: 20),
                    const Text("Emergency", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Emergency(),
                    const SizedBox(height: 20),
                    const Text("Live Safe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    LiveSafe(),
                    const SizedBox(height: 20),
                    SafeHome(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}