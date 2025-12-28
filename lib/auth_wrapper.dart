import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'child/child_login_screen.dart';
import 'child/bottom_page.dart';
import 'parent/parent_home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // ⏳ loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ NOT LOGGED IN
        if (!snapshot.hasData || snapshot.data == null) {
          return  LoginScreen();
        }

        // ✅ LOGGED IN
        final uid = snapshot.data!.uid;

        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get(),
          builder: (context, userSnap) {

            if (!userSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnap.data!.exists) {
              // 🔴 MOST COMMON BUG
              // auth me user hai but firestore me data nahi
              FirebaseAuth.instance.signOut();
              return  LoginScreen();
            }

            final data = userSnap.data!.data() as Map<String, dynamic>;
            final type = data['type'];

            if (type == 'parent') {
              return const ParentHomeScreen();
            } else {
              return const BottomPage();
            }
          },
        );
      },
    );
  }
}
