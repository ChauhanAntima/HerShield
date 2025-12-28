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
//               cursorColor: Colors.pink,
//               decoration: InputDecoration(
//                 hintText: 'type your message',
//                 filled: true,
//                 fillColor: Colors.grey[100],
//                 prefixIcon: IconButton(
//                   icon: const Icon(Icons.add_box_rounded, color: Colors.pink),
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
//             icon: const Icon(Icons.send, color: Colors.pink),
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
//             backgroundColor: Colors.pink,
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

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks.first;
    String locationMsg = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}\n${place.locality}, ${place.street}";

    await sendMessage(locationMsg, 'link');
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
                color: const Color(0xFFFDF0F3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFF06292).withOpacity(0.2)),
              ),
              child: TextField(
                controller: _controller,
                cursorColor: const Color(0xFFF06292),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFF06292)),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => bottomSheet(),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Custom Send Button
          GestureDetector(
            onTap: () {
              if (_controller.text.trim().isEmpty) return;
              sendMessage(_controller.text.trim(), 'text');
              _controller.clear();
            },
            child: const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFFF06292),
              child: Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 30),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              getCurrentLocation();
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFF06292),
                  child: const Icon(Icons.location_on, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 10),
                const Text("Send Location", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFF06292))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
