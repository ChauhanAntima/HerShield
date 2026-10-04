// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../child/child_login_screen.dart';
// import '../profile_mode/personal_info_page.dart';
// import '../utils/constants.dart';
//
// class ParentHomeScreen extends StatelessWidget {
//   const ParentHomeScreen({Key? key}) : super(key: key);
//
//   void _logout(BuildContext context) async {
//     await FirebaseAuth.instance.signOut();
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => LoginScreen()),
//           (_) => false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Parent Home"),
//         backgroundColor: kColorRed,
//       ),
//
//       /// 🔥 SIDEBAR
//       drawer: Drawer(
//         child: Column(
//           children: [
//             const UserAccountsDrawerHeader(
//               decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
//               accountName: Text("Parent"),
//               accountEmail: Text(""),
//             ),
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text("Edit Profile"),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const PersonalInfoPage(),
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text("Logout"),
//               onTap: () => _logout(context),
//             ),
//           ],
//         ),
//       ),
//
//       /// 🔥 BODY → CHILD LIST
//       body: user == null
//           ? const Center(child: Text("User not logged in"))
//           : StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('users')
//             .where('type', isEqualTo: 'child')
//             .where('guardianEmail', isEqualTo: user.email)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No children added yet 👶",
//                 style: TextStyle(fontSize: 16),
//               ),
//             );
//           }
//
//           final children = snapshot.data!.docs;
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: children.length,
//             itemBuilder: (context, index) {
//               final child =
//               children[index].data() as Map<String, dynamic>;
//
//               return Card(
//                 elevation: 3,
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: ListTile(
//                   leading: const CircleAvatar(
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     child: Icon(Icons.child_care, color: Colors.white),
//                   ),
//                   title: Text(child['name'] ?? 'No Name'),
//                   subtitle: Text(child['childEmail'] ?? ''),
//                   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                   onTap: () {
//                     // future: child detail / tracking page
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../child/child_login_screen.dart';
import '../chat_module/chat_screen.dart';
import '../profile_mode/personal_info_page.dart';


class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F1), // Soft pinkish background
      appBar: AppBar(
        title: const Text(
          "Guardian Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
        ),
        centerTitle: true,

        backgroundColor: const Color(0xFF573A63),
        iconTheme: const IconThemeData(color: Colors.white), // Drawer icon color
        elevation: 0,
      ),


      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF573A63)),
              accountName: Text(
                "Guardian Account",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text("Manage your children safety"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF573A63), size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF573A63)),
              title: const Text("Edit Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PersonalInfoPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),


      body: user == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('type', isEqualTo: 'child')
            .where('guardianEmail', isEqualTo: user.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF573A63)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.child_care, size: 80, color: const Color(0xFF573A63).withOpacity(0.2)),
                  const SizedBox(height: 10),
                  const Text(
                    "No children added yet 👶",
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          final children = snapshot.data!.docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
                child: Text(
                  "LINKED CHILDREN",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 1),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final doc = children[index];
                    final child = doc.data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF573A63).withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFF573A63),
                          child: const Icon(Icons.face, color: Colors.white, size: 30),
                        ),
                        title: Text(
                          (child['name'] ?? 'No Name').toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(child['childEmail'] ?? ''),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EBF2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble, color: Color(0xFF573A63)),
                        ),

                        /// ✅ OPEN CHAT SCREEN
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                currentUserId: user.uid, // parent uid
                                friendId: doc.id,        // child uid
                                friendName: child['name'] ?? 'Child',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}