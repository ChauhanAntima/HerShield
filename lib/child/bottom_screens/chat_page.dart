// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import '../../chat_module/chat_screen.dart';
// import '../../parent/parent_home_screen.dart';
// import '../../utils/constants.dart';
// import '../child_login_screen.dart';
//
// class CheckUserStatusBeforeChat extends StatelessWidget {
//   const CheckUserStatusBeforeChat({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         } else {
//           if (snapshot.hasData) {
//             print("===>${snapshot.data}");
//             return StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection("users")
//                   .where("id",
//                   isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//                   .snapshots(),
//               builder: (context, snap) {
//                 if (snap.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else if (snap.hasData) {
//                   if (snap.data!.docs.first.data()['type'] == "parent") {
//                     return ParentHomeScreen();
//                   } else {
//                     return ChatPage();
//                   }
//                 }
//                 return SizedBox();
//               },
//             );
//             //return ChatPage();
//           } else {
//             Fluttertoast.showToast(msg: 'please login first');
//             return LoginScreen();
//           }
//         }
//       },
//     );
//   }
// }
//
// class ChatPage extends StatefulWidget {
//   const ChatPage({super.key});
//
//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }
//
// class _ChatPageState extends State<ChatPage> {
//   // @override
//   // void initState() {
//   //   super.initState();
//
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     setState(() {
//   //       if (FirebaseAuth.instance.currentUser == null ||
//   //           FirebaseAuth.instance.currentUser!.uid.isEmpty) {
//   //         if (mounted) {
//   //           Navigator.push(
//   //               context, MaterialPageRoute(builder: (_) => LoginScreen()));
//   //         }
//   //       }
//   //     });
//   //   });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     // WidgetsBinding.instance.addObserver();
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.pink,
//         // backgroundColor: Color.fromARGB(255, 250, 163, 192),
//         title: Text("SELECT GUARDIAN"),
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .where('type', isEqualTo: 'parent')
//             .where('childEmail',
//             isEqualTo: FirebaseAuth.instance.currentUser!.email)
//             .snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: progressIndicator(context));
//           }
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (BuildContext context, int index) {
//               final d = snapshot.data!.docs[index];
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   color: Color.fromARGB(255, 250, 163, 192),
//                   child: ListTile(
//                     onTap: () {
//                       goTo(
//                           context,
//                           ChatScreen(
//                               currentUserId:
//                               FirebaseAuth.instance.currentUser!.uid,
//                               friendId: d.id,
//                               friendName: d['name']));
//                       // Navigator.push(context, MaterialPa)
//                     },
//                     title: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(d['name']),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
//
// import '../../chat_module/chat_screen.dart';
// import '../../parent/parent_home_screen.dart';
// import '../../utils/constants.dart';
// import '../child_login_screen.dart';
//
// /// =======================================================
// /// CHECK USER TYPE (PARENT / CHILD)
// /// =======================================================
// class CheckUserStatusBeforeChat extends StatelessWidget {
//   const CheckUserStatusBeforeChat({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, authSnap) {
//         if (authSnap.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         if (!authSnap.hasData) {
//           Fluttertoast.showToast(msg: 'Please login first');
//           return LoginScreen();
//         }
//
//         final uid = FirebaseAuth.instance.currentUser!.uid;
//
//         return StreamBuilder<DocumentSnapshot>(
//           stream:
//           FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
//           builder: (context, userSnap) {
//             if (userSnap.connectionState == ConnectionState.waiting) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }
//
//             if (!userSnap.hasData || !userSnap.data!.exists) {
//               return const Scaffold(
//                 body: Center(child: Text('User record not found')),
//               );
//             }
//
//             final userData =
//             userSnap.data!.data() as Map<String, dynamic>;
//             final type = userData['type'];
//
//             if (type == 'parent') {
//               return ParentHomeScreen();
//             } else {
//               return const ChatPage();
//             }
//           },
//         );
//       },
//     );
//   }
// }
//
// /// =======================================================
// /// CHAT PAGE (CHILD → SELECT GUARDIAN)
// /// =======================================================
// class ChatPage extends StatelessWidget {
//   const ChatPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = FirebaseAuth.instance.currentUser!;
//
//     /// STEP 1: FETCH CHILD DOCUMENT
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUser.uid)
//           .snapshots(),
//       builder: (context, childSnap) {
//         if (childSnap.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }
//
//         if (!childSnap.hasData || !childSnap.data!.exists) {
//           return const Scaffold(
//             body: Center(child: Text("Child data not found")),
//           );
//         }
//
//         final childData =
//         childSnap.data!.data() as Map<String, dynamic>;
//         final guardianEmail = childData['guardianEmail'];
//
//         /// STEP 2: FETCH PARENT USING guardianEmail
//         return Scaffold(
//           appBar: AppBar(
//             backgroundColor: Color(0xFFF06292),
//             title: const Text("SELECT GUARDIAN"),
//           ),
//           body: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('users')
//                 .where('type', isEqualTo: 'parent')
//                 .where('guardianEmail', isEqualTo: guardianEmail)
//                 .snapshots(),
//             builder: (context, parentSnap) {
//               if (parentSnap.connectionState == ConnectionState.waiting) {
//                 return Center(child: progressIndicator(context));
//               }
//
//               if (!parentSnap.hasData ||
//                   parentSnap.data!.docs.isEmpty) {
//                 return const Center(
//                   child: Text("No guardian linked to this child"),
//                 );
//               }
//
//               return ListView.builder(
//                 itemCount: parentSnap.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   final d = parentSnap.data!.docs[index];
//
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       color:
//                       const Color.fromARGB(255, 250, 163, 192),
//                       child: ListTile(
//                         title: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(d['name']),
//                         ),
//                         onTap: () {
//                           goTo(
//                             context,
//                             ChatScreen(
//                               currentUserId: currentUser.uid,
//                               friendId: d.id,
//                               friendName: d['name'],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../chat_module/chat_screen.dart';
import '../../parent/parent_home_screen.dart';
import '../../utils/constants.dart';
import '../child_login_screen.dart';

class CheckUserStatusBeforeChat extends StatelessWidget {
  const CheckUserStatusBeforeChat({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFF06292))),
          );
        }

        if (!authSnap.hasData) {
          Fluttertoast.showToast(msg: 'Please login first');
          return LoginScreen();
        }

        final uid = FirebaseAuth.instance.currentUser!.uid;

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator(color: Color(0xFFF06292))),
              );
            }

            if (!userSnap.hasData || !userSnap.data!.exists) {
              return const Scaffold(body: Center(child: Text('User record not found')));
            }

            final userData = userSnap.data!.data() as Map<String, dynamic>;
            final type = userData['type'];

            if (type == 'parent') {
              return ParentHomeScreen();
            } else {
              return const ChatPage();
            }
          },
        );
      },
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
      builder: (context, childSnap) {
        if (childSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFF06292))),
          );
        }

        final childData = childSnap.data!.data() as Map<String, dynamic>;
        final guardianEmail = childData['guardianEmail'];

        return Scaffold(
          backgroundColor: const Color(0xFFFDF0F3), // Soft pink background
          appBar: AppBar(
            backgroundColor: const Color(0xFFF06292), // ✅ APKA COLOR
            title: const Text(
              "Chat With Guardian",
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('type', isEqualTo: 'parent')
                .where('guardianEmail', isEqualTo: guardianEmail)
                .snapshots(),
            builder: (context, parentSnap) {
              if (parentSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFF06292)));
              }

              if (!parentSnap.hasData || parentSnap.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 80, color: Colors.pink.shade200),
                      const SizedBox(height: 10),
                      const Text("No guardian linked to this child",
                          style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: parentSnap.data!.docs.length,
                itemBuilder: (context, index) {
                  final d = parentSnap.data!.docs[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFF06292),
                        radius: 25,
                        child: Text(
                          d['name'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      title: Text(
                        d['name'].toString().toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      subtitle: const Text("Click to start chat"),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat_bubble, color: Color(0xFFF06292)),
                      ),
                      onTap: () {
                        goTo(
                          context,
                          ChatScreen(
                            currentUserId: currentUser.uid,
                            friendId: d.id,
                            friendName: d['name'],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
