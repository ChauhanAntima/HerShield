// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class SingleMessage extends StatelessWidget {
//   final String? message;
//   final bool? isMe;
//   final String? type;
//   final String? friendName;
//   final String? myName;
//   final Timestamp? date;
//
//   const SingleMessage({
//     super.key,
//     this.message,
//     this.isMe,
//     this.type,
//     this.friendName,
//     this.myName,
//     this.date,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     DateTime d = date!.toDate();
//     String time = "${d.hour}:${d.minute}";
//
//     /// ================= IMAGE =================
//     if (type == 'img') {
//       return Align(
//         alignment: isMe! ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           margin: const EdgeInsets.all(8),
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: isMe! ? const Color(0xFFD9C9DE) : Colors.blueGrey,
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               CachedNetworkImage(
//                 imageUrl: message!,
//                 height: 200,
//                 width: 200,
//                 fit: BoxFit.cover,
//                 placeholder: (_, __) =>
//                 const CircularProgressIndicator(),
//                 errorWidget: (_, __, ___) =>
//                 const Icon(Icons.error, color: Colors.white),
//               ),
//               const SizedBox(height: 5),
//               Text(time, style: const TextStyle(color: Colors.white70)),
//             ],
//           ),
//         ),
//       );
//     }
//
//     /// ================= LINK =================
//     if (type == 'link') {
//       return InkWell(
//         onTap: () async => await launchUrl(Uri.parse(message!)),
//         child: bubble(message!, time),
//       );
//     }
//
//     /// ================= TEXT =================
//     return bubble(message!, time);
//   }
//
//   Widget bubble(String msg, String time) {
//     return Align(
//       alignment: isMe! ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         constraints: const BoxConstraints(maxWidth: 250),
//         margin: const EdgeInsets.all(8),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: isMe! ? const Color(0xFFD9C9DE) : Colors.blueGrey,
//           borderRadius: BorderRadius.circular(15),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(msg, style: const TextStyle(color: Colors.white)),
//             const SizedBox(height: 5),
//             Text(time, style: const TextStyle(color: Colors.white70)),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleMessage extends StatelessWidget {
  final String? message;
  final bool? isMe;
  final String? type;
  final Timestamp? date;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const SingleMessage({
    super.key,
    this.message,
    this.isMe,
    this.type,
    this.date,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    DateTime d = date!.toDate();
    String time =
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";

    // Link (Location) ke liye alag color
    final bubbleColor = isMe! ? const Color(0xFF573A63) : Colors.white;
    if (type == 'link') {
      return bubble(
        context,
        message!,
        time,
        isMe! ? const Color(0xFF73547E) : const Color(0xFFE9E1EC),
        true,
      );
    }

    return bubble(context, message!, time, bubbleColor, false);
  }

  Widget bubble(
    BuildContext context,
    String msg,
    String time,
    Color color,
    bool isLink,
  ) {
    return Align(
      alignment: isMe! ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: isSelected ? onTap : null,
                onLongPress: onLongPress,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    border: isSelected
                        ? Border.all(color: const Color(0xFF367C78), width: 2)
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe! ? 20 : 0),
                      bottomRight: Radius.circular(isMe! ? 0 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isMe!
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (isLink)
                        InkWell(
                          onTap: () =>
                              launchUrl(Uri.parse(msg.split('\n').first)),
                          child: Text(
                            msg,
                            style: TextStyle(
                              color: isMe! ? Colors.white : Colors.black87,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      else
                        Text(
                          msg,
                          style: TextStyle(
                            color: isMe! ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      const SizedBox(height: 5),
                      Text(
                        time,
                        style: TextStyle(
                          color: isMe! || isLink
                              ? Colors.white70
                              : Colors.black45,
                          fontSize: 10,
                        ),
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
