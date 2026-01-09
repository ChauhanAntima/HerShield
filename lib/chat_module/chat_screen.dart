// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../utils/constants.dart';
// import 'message_text_field.dart';
// import 'singleMessage.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String currentUserId;
//   final String friendId;
//   final String friendName;
//
//   const ChatScreen({
//     super.key,
//     required this.currentUserId,
//     required this.friendId,
//     required this.friendName,
//   });
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   String? type;
//   String? myname;
//
//   @override
//   void initState() {
//     super.initState();
//     getStatus();
//   }
//
//   Future<void> getStatus() async {
//     final snap = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.currentUserId)
//         .get();
//
//     setState(() {
//       type = snap.data()?['type'];
//       myname = snap.data()?['name'];
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true, // 🔥 IMPORTANT
//       appBar: AppBar(
//           backgroundColor: const Color(0xFFF06292),
//         title: Text(widget.friendName),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             /// 🔹 CHAT LIST
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(widget.currentUserId)
//                     .collection('messages')
//                     .doc(widget.friendId)
//                     .collection('chats')
//                     .orderBy('date')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return progressIndicator(context);
//                   }
//
//                   if (snapshot.data!.docs.isEmpty) {
//                     return Center(
//                       child: Text(
//                         type == 'parent'
//                             ? 'TALK WITH CHILD'
//                             : 'TALK WITH GUARDIAN',
//                         style: const TextStyle(fontSize: 22),
//                       ),
//                     );
//                   }
//
//                   return ListView.builder(
//                     reverse: false,
//                     padding: const EdgeInsets.only(bottom: 10),
//                     itemCount: snapshot.data!.docs.length,
//                     itemBuilder: (context, index) {
//                       final data = snapshot.data!.docs[index];
//                       final isMe =
//                           data['senderId'] == widget.currentUserId;
//
//                       return Dismissible(
//                         key: ValueKey(data.id),
//                         onDismissed: (_) async {
//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(widget.currentUserId)
//                               .collection('messages')
//                               .doc(widget.friendId)
//                               .collection('chats')
//                               .doc(data.id)
//                               .delete();
//
//                           await FirebaseFirestore.instance
//                               .collection('users')
//                               .doc(widget.friendId)
//                               .collection('messages')
//                               .doc(widget.currentUserId)
//                               .collection('chats')
//                               .doc(data.id)
//                               .delete();
//
//                           Fluttertoast.showToast(
//                               msg: 'Message deleted');
//                         },
//                         child: SingleMessage(
//                           message: data['message'],
//                           date: data['date'],
//                           isMe: isMe,
//                           friendName: widget.friendName,
//                           myName: myname,
//                           type: data['type'],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//
//
//             MessageTextField(
//               currentId: widget.currentUserId,
//               friendId: widget.friendId,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'message_text_field.dart';
import 'singleMessage.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId, friendId, friendName;
  const ChatScreen({super.key, required this.currentUserId, required this.friendId, required this.friendName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0F3),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF06292),
        title: Text(widget.friendName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentUserId)
                  .collection('messages')
                  .doc(widget.friendId)
                  .collection('chats')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final data = snapshot.data!.docs[index];
                    return SingleMessage(
                      message: data['message'],
                      date: data['date'],
                      isMe: data['senderId'] == widget.currentUserId,
                      type: data['type'],
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: MessageTextField(
                currentId: widget.currentUserId,
                friendId: widget.friendId
            ),
          ),
        ],
      ),
    );
  }
}
