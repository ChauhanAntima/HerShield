import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../child/child_login_screen.dart';
import '../utils/constants.dart';
import 'personal_info_page.dart';

class ProfileItem {
  final String key;
  final String title;
  final IconData icon;

  ProfileItem({
    required this.key,
    required this.title,
    required this.icon,
  });
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? displayName;
  bool isLoading = true;

  final List<ProfileItem> items = [
    ProfileItem(
      key: 'profile',
      title: 'Update Profile',
      icon: Icons.person,
    ),
    ProfileItem(
      key: 'logout',
      title: 'Logout',
      icon: Icons.logout,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _redirectToLogin();
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (snap.exists) {
        setState(() {
          displayName = snap['name'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (_) => false,
    );
  }

  void _onItemTap(ProfileItem item) {
    switch (item.key) {
      case 'profile':
        if (FirebaseAuth.instance.currentUser == null) {
          Fluttertoast.showToast(msg: "Please login first");
          _redirectToLogin();
          return;
        }
        goTo(context, const PersonalInfoPage());
        break;

      case 'logout':
        _logout();
        break;
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:  const Color(0xFFF06292),
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Fluttertoast.showToast(msg: "Logged out");

              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                    (_) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor:  const Color(0xFFF06292),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// PROFILE AVATAR
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFF06292),
              child: Text(
                displayName != null && displayName!.isNotEmpty
                    ? displayName![0].toUpperCase()
                    : "?",
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              displayName ?? "User",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            /// SETTINGS OPTIONS
            ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  tileColor: Colors.pink.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(item.icon, color: Color(0xFFF06292)),
                  title: Text(item.title),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _onItemTap(item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
