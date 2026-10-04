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
//           backgroundColor: const Color(0xFF573A63),
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
  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.friendId,
    required this.friendName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? _selectedMessageId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F1),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF573A63),
        leading: _selectedMessageId == null
            ? null
            : IconButton(
                tooltip: 'Cancel selection',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedMessageId = null),
              ),
        title: Text(
          _selectedMessageId == null ? widget.friendName : '1 selected',
        ),
        centerTitle: true,
        actions: [
          if (_selectedMessageId != null)
            IconButton(
              tooltip: 'Delete selected message',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(_selectedMessageId!),
            ),
        ],
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
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Could not load this chat. Check your connection.',
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF367C78)),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9E1EC),
                              borderRadius: BorderRadius.circular(26),
                            ),
                            child: const Icon(
                              Icons.forum_rounded,
                              color: Color(0xFF573A63),
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Start a conversation',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF302737),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Send a message or share your location with your trusted contact.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Color(0xFF817785),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
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
                      isSelected: _selectedMessageId == data.id,
                      onLongPress: () =>
                          setState(() => _selectedMessageId = data.id),
                      onTap: () => setState(() => _selectedMessageId = null),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: MessageTextField(
              currentId: widget.currentUserId,
              friendId: widget.friendId,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String messageId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this message?'),
        content: const Text('It will be removed from your chat only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB8404A),
            ),
            child: const Text('Delete for me'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .doc(messageId)
          .delete();
      if (!mounted) return;
      setState(() => _selectedMessageId = null);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Message deleted from your chat.')),
        );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not delete the message.')),
        );
    }
  }
}
