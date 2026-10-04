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
                color: const Color(0xFFFFFDFC), // ✅ BOTTOM SHEET BG
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
                        color: const Color(0xFFD9C9DE),
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
      borderRadius: BorderRadius.circular(23),
      child: Container(
        height: 112,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE9E1EC), Color(0xFFE6F0ED)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: const Color(0xFFE2D9E5)),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF573A63),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.near_me_rounded, color: Colors.white, size: 27),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share my location',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF302737)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Send it to your trusted contacts',
                    maxLines: 2,
                    style: TextStyle(fontSize: 11, height: 1.2, color: Color(0xFF746B75)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF573A63)),
          ],
        ),
      ),
    );
  }
}
