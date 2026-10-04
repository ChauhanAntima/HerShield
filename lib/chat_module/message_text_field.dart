// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
//
// class MessageTextField extends StatefulWidget {
//   final String currentId;
//   final String friendId;
//
//   const MessageTextField({
//     super.key,
//     required this.currentId,
//     required this.friendId,
//   });
//
//   @override
//   State<MessageTextField> createState() => _MessageTextFieldState();
// }
//
// class _MessageTextFieldState extends State<MessageTextField> {
//   final TextEditingController _controller = TextEditingController();
//
//   File? imageFile;
//   Position? _currentPosition;
//   String? _currentAddress;
//
//   /// ================= IMAGE PICK =================
//   Future<void> getImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final XFile? picked = await picker.pickImage(source: source);
//
//     if (picked != null) {
//       imageFile = File(picked.path);
//       await uploadImage();
//     }
//   }
//
//   /// ================= IMAGE UPLOAD (FIXED) =================
//   Future<void> uploadImage() async {
//     try {
//       String fileName = const Uuid().v1();
//
//       final ref = FirebaseStorage.instance
//           .ref()
//           .child('chat_images')
//           .child('$fileName.jpg');
//
//       UploadTask uploadTask = ref.putFile(imageFile!);
//       TaskSnapshot snapshot = await uploadTask;
//
//       String imageUrl = await snapshot.ref.getDownloadURL();
//
//       await sendMessage(imageUrl, 'img');
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Image upload failed");
//     }
//   }
//
//   /// ================= LOCATION =================
//   Future<void> getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     if (permission == LocationPermission.deniedForever) return;
//
//     Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     _currentPosition = position;
//
//     List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude, position.longitude);
//
//     Placemark place = placemarks.first;
//
//     _currentAddress =
//     "${place.locality}, ${place.postalCode}, ${place.street}";
//
//     String locationMsg =
//         "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}\n$_currentAddress";
//
//     await sendMessage(locationMsg, 'link');
//   }
//
//   /// ================= SEND MESSAGE =================
//   Future<void> sendMessage(String message, String type) async {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.currentId)
//         .collection('messages')
//         .doc(widget.friendId)
//         .collection('chats')
//         .add({
//       'senderId': widget.currentId,
//       'receiverId': widget.friendId,
//       'message': message,
//       'type': type,
//       'date': DateTime.now(),
//     });
//
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.friendId)
//         .collection('messages')
//         .doc(widget.currentId)
//         .collection('chats')
//         .add({
//       'senderId': widget.currentId,
//       'receiverId': widget.friendId,
//       'message': message,
//       'type': type,
//       'date': DateTime.now(),
//     });
//   }
//
//   /// ================= UI =================
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               cursorColor: Theme.of(context).colorScheme.primary,
//               decoration: InputDecoration(
//                 hintText: 'type your message',
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 prefixIcon: IconButton(
//                   icon: const Icon(Icons.add_box_rounded, color: Theme.of(context).colorScheme.primary),
//                   onPressed: () {
//                     showModalBottomSheet(
//                       context: context,
//                       builder: (_) => bottomSheet(),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
//             onPressed: () {
//               if (_controller.text.trim().isEmpty) return;
//               sendMessage(_controller.text.trim(), 'text');
//               _controller.clear();
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// ================= BOTTOM SHEET =================
//   Widget bottomSheet() {
//     return SizedBox(
//       height: 120,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           iconTile(Icons.location_pin, "Location", getCurrentLocation),
//           iconTile(Icons.camera_alt, "Camera",
//                   () => getImage(ImageSource.camera)),
//           iconTile(Icons.photo, "Gallery",
//                   () => getImage(ImageSource.gallery)),
//         ],
//       ),
//     );
//   }
//
//   Widget iconTile(IconData icon, String title, VoidCallback onTap) {
//     return InkWell(
//       onTap: () {
//         Navigator.pop(context);
//         onTap();
//       },
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           CircleAvatar(
//             radius: 26,
//             backgroundColor: Theme.of(context).colorScheme.primary,
//             child: Icon(icon, color: Colors.white),
//           ),
//           const SizedBox(height: 5),
//           Text(title),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MessageTextField extends StatefulWidget {
  final String currentId, friendId;
  const MessageTextField({super.key, required this.currentId, required this.friendId});

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showStatus('Turn on location services to share your location.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showStatus('Location permission is needed to share your location.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 15));
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.isEmpty ? null : placemarks.first;
      final address = [place?.locality, place?.street]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(', ');
      final locationMsg =
          'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}'
          '${address.isEmpty ? '' : '\n$address'}';

      await sendMessage(locationMsg, 'link');
      _showStatus('Your location was shared in the chat.');
    } catch (error) {
      _showStatus('Could not share location. Check your connection and try again.');
      debugPrint('Chat location share failed: $error');
    }
  }

  void _showStatus(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> sendMessage(String message, String type) async {
    var data = {
      'senderId': widget.currentId,
      'receiverId': widget.friendId,
      'message': message,
      'type': type,
      'date': DateTime.now(),
    };
    await FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).collection('chats').add(data);
    await FirebaseFirestore.instance.collection('users').doc(widget.friendId).collection('messages').doc(widget.currentId).collection('chats').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🔥 Niche thodi extra padding di hai taki Navigation bar se upar rahe
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2), // Upar ki taraf shadow
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4F1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF573A63).withOpacity(0.2)),
              ),
              child: TextField(
                controller: _controller,
                cursorColor: const Color(0xFF573A63),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFF573A63)),
                    onPressed: _openAttachmentSheet,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isEmpty) return;
              sendMessage(_controller.text.trim(), 'text');
              _controller.clear();
            },
            child: const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF573A63),
              child: Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  void _openAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => bottomSheet(sheetContext),
    );
  }

  Widget bottomSheet(BuildContext sheetContext) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFDFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8D0DA),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Share with your circle',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF302737),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Choose what you want to send in this chat.',
              style: TextStyle(fontSize: 13, color: Color(0xFF817785)),
            ),
            const SizedBox(height: 16),
            Material(
              color: const Color(0xFFE9E1EC),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  getCurrentLocation();
                },
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF573A63),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 13),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Send my location',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF302737),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Share a map link in this chat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF746B75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Color(0xFF573A63),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
