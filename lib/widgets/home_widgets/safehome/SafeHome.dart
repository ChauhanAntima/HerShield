import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/PrimaryButton.dart';
import '../../../db/db_services.dart';
import '../../../model/contactsm.dart';

class SafeHome extends StatefulWidget {
  const SafeHome({Key? key}) : super(key: key);

  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  Position? _currentPosition;
  String? _currentAddress;
  bool _isFetching = false;

  // ================= LOCATION PERMISSION =================
  Future<bool> _handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      Fluttertoast.showToast(msg: "Enable location services");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permission denied");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Location permission permanently denied");
      return false;
    }

    return true;
  }

  // ================= FAST LOCATION =================
  Future<void> _fetchLocationFast() async {
    if (_isFetching) return;
    _isFetching = true;

    final allowed = await _handleLocationPermission();
    if (!allowed) {
      _isFetching = false;
      return;
    }

    try {
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _currentPosition = lastPos;
        _getAddressFromLatLng();
      }

      final freshPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = freshPos;
      await _getAddressFromLatLng();
    } catch (_) {
      Fluttertoast.showToast(msg: "Failed to fetch location");
    }

    _isFetching = false;
  }

  // ================= ADDRESS =================
  Future<void> _getAddressFromLatLng() async {
    if (_currentPosition == null) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final p = placemarks.first;
      setState(() {
        _currentAddress =
        "${p.street}, ${p.locality}, ${p.postalCode}";
      });
    } catch (_) {}
  }

  // ================= OPEN SMS =================
  Future<void> _openSmsWithMessage(
      String phones, String message) async {
    final Uri uri = Uri.parse(
      "sms:$phones?body=${Uri.encodeComponent(message)}",
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      Fluttertoast.showToast(msg: "Could not open SMS app");
    }
  }

  // ================= BOTTOM SHEET =================
  void showModelSafeHome(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        _fetchLocationFast();

        return FractionallySizedBox(
          heightFactor: 0.6,
          child: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F8), // ✅ BOTTOM SHEET BG
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // drag handle
                    Container(
                      height: 5,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.pink.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "SEND YOUR CURRENT LOCATION TO EMERGENCY CONTACTS",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      _currentAddress ?? "Fetching location...",
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    PrimaryButton(
                      title: "SEND ALERT",
                      onPressed: () async {
                        if (_currentPosition == null) {
                          Fluttertoast.showToast(
                              msg: "Location not ready yet");
                          return;
                        }

                        final contacts =
                        await DatabaseHelper().getContactList();
                        if (contacts.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "No emergency contacts");
                          return;
                        }

                        final phones = contacts
                            .map((e) => e.number)
                            .where((e) =>
                        e != null && e!.trim().isNotEmpty)
                            .join(',');

                        final message =
                            "🚨 EMERGENCY ALERT 🚨\n\n"
                            "I am in danger. Please help!\n\n"
                            "My current location:\n"
                            "https://www.google.com/maps/search/?api=1&query="
                            "${_currentPosition!.latitude},"
                            "${_currentPosition!.longitude}\n\n"
                            "${_currentAddress ?? ''}";

                        await _openSmsWithMessage(phones, message);
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= HOME CARD =================
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModelSafeHome(context),
      child: Card(
        color: const Color(0xFFFFF5F8),
        elevation: 6,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: Row(
            children: [
              const Expanded(
                child: ListTile(
                  title: Text(
                    "Send Location",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Send Your Current Location to Emergency Contacts"),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/route.png',
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
