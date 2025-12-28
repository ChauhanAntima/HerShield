// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_volume_controller/flutter_volume_controller.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:sms_sender_background/sms_sender.dart'; // ✅ Telephony ki jagah naya import
//
// class VolumeSosScreen extends StatefulWidget {
//   @override
//   _VolumeSosScreenState createState() => _VolumeSosScreenState();
// }
//
// class _VolumeSosScreenState extends State<VolumeSosScreen> {
//   int _counter = 0;
//   Timer? _timer;
//   final smsSender = SmsSender(); // ✅ Naya SMS sender instance
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Volume listen karna
//     FlutterVolumeController.addListener((volume) {
//       _handleVolumePress();
//     });
//
//     // Volume bar hide karna
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
//   void _handleVolumePress() {
//     setState(() {
//       _counter++;
//     });
//
//     print("Button Pressed: $_counter");
//
//     if (_counter == 1) {
//       _timer = Timer(Duration(seconds: 5), () {
//         if (mounted) {
//           setState(() {
//             _counter = 0;
//           });
//         }
//         print("Timer Reset");
//       });
//     }
//
//     if (_counter >= 4) {
//       _sendSosLocation();
//       setState(() {
//         _counter = 0;
//       });
//       _timer?.cancel();
//     }
//   }
//
//   Future<void> _sendSosLocation() async {
//     try {
//       // Location Permission check
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
//         Position position = await Geolocator.getCurrentPosition(
//             desiredAccuracy: LocationAccuracy.high);
//
//         String message = "EMERGENCY! Meri location: "
//             "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
//
//         // ✅ Naya SMS bhejne ka tareeka
//         bool hasSmsPermission = await smsSender.checkSmsPermission();
//         if (!hasSmsPermission) {
//           hasSmsPermission = await smsSender.requestSmsPermission();
//         }
//
//         if (hasSmsPermission) {
//           await smsSender.sendSms(
//             phoneNumber: "9876543210", // 🔥 Target number badlein
//             message: message,
//           );
//
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text("SOS Message Sent!"), backgroundColor: Colors.red),
//             );
//           }
//         }
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Volume SOS App"), backgroundColor: Colors.pink),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.warning_amber_rounded, size: 80, color: Colors.red),
//             SizedBox(height: 20),
//             Text("Volume Button ko 4 baar jaldi dabayein",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             Text("Current Presses: $_counter", style: TextStyle(fontSize: 24, color: Colors.pink)),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

// 🔥 Database aur Model ke paths check kar lein
import '../../db/db_services.dart';
import '../../model/contactsm.dart';

class VolumeSosScreen extends StatefulWidget {
  @override
  _VolumeSosScreenState createState() => _VolumeSosScreenState();
}

class _VolumeSosScreenState extends State<VolumeSosScreen> {
  int _counter = 0;
  Timer? _timer;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // ✅ Wahi Channel jo MainActivity.kt aur HomeScreen mein use kiya hai
  static const platform = MethodChannel('com.example.womensafety/sms');

  @override
  void initState() {
    super.initState();

    // Volume button ko listen karna
    FlutterVolumeController.addListener((volume) {
      _handleVolumePress();
    });

    // Volume bar hide karna
    FlutterVolumeController.showSystemUI = false;
  }

  @override
  void dispose() {
    FlutterVolumeController.removeListener();
    _timer?.cancel();
    super.dispose();
  }

  void _handleVolumePress() {
    setState(() {
      _counter++;
    });

    print("Button Pressed: $_counter");

    if (_counter == 1) {
      _timer = Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _counter = 0;
          });
        }
        print("Timer Reset");
      });
    }

    if (_counter >= 4) {
      _sendSosLocation(); // ✅ Saare contacts ko alert bhejega
      setState(() {
        _counter = 0;
      });
      _timer?.cancel();
    }
  }

  Future<void> _sendSosLocation() async {
    try {
      // 1. Database se saare saved contacts nikalna
      List<TContact> contactList = await _databaseHelper.getContactList();

      if (contactList.isEmpty) {
        Fluttertoast.showToast(
          msg: "No trusted contacts! Add them in the app first.",
          backgroundColor: Colors.red,
        );
        return;
      }

      // 2. Location Permission check
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        String mapUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
        String message = "EMERGENCY! I need help. My location: $mapUrl";

        int successCount = 0;

        // 3. Loop: Saare contacts ko Native Android code se SMS bhejna
        for (TContact contact in contactList) {
          try {
            // Number se spaces aur dash hatana
            String cleanNumber = contact.number.replaceAll(RegExp(r'\s+'), "").replaceAll("-", "");

            // ✅ Native Call (MainActivity.kt ko command dena)
            final String result = await platform.invokeMethod('sendDirectSms', {
              "phone": cleanNumber,
              "msg": message,
            });

            if (result == "SMS Sent Successfully") {
              successCount++;
            }
          } on PlatformException catch (e) {
            print("Failed to send to ${contact.number}: ${e.message}");
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("SOS sent to $successCount contacts!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(msg: "Failed to trigger SOS");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Volume SOS App"), backgroundColor: Colors.pink),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.red),
            SizedBox(height: 20),
            Text("Volume Button ko 4 baar jaldi dabayein",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Current Presses: $_counter",
                style: TextStyle(fontSize: 24, color: Colors.pink, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}