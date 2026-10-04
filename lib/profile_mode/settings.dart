import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../child/child_login_screen.dart';
import '../utils/constants.dart';
import 'personal_info_page.dart';

class ProfileItem {
  final String key;
  final String title;
  final IconData icon;

  ProfileItem({required this.key, required this.title, required this.icon});
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? displayName;
  String? profilePhotoUrl;
  bool isLoading = true;
  bool isUploadingPhoto = false;

  final List<ProfileItem> items = [
    ProfileItem(key: 'profile', title: 'Update Profile', icon: Icons.person),
    ProfileItem(key: 'logout', title: 'Logout', icon: Icons.logout),
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
        final data = snap.data() ?? <String, dynamic>{};
        if (!mounted) return;
        setState(() {
          displayName = data['name'] as String?;
          profilePhotoUrl = data['profilePic'] as String?;
          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || isUploadingPhoto) return;

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
        maxWidth: 1400,
      );
      if (image == null || !mounted) return;

      setState(() => isUploadingPhoto = true);
      final fileName =
          '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final photoRef = FirebaseStorage.instance.ref('profile/$fileName');
      await photoRef.putFile(File(image.path));
      final photoUrl = await photoRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'profilePic': photoUrl,
      }, SetOptions(merge: true));

      if (!mounted) return;
      setState(() {
        profilePhotoUrl = photoUrl;
        isUploadingPhoto = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profile photo updated.')));
    } catch (error) {
      if (!mounted) return;
      setState(() => isUploadingPhoto = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Photo upload failed. Check your connection and try again.',
            ),
          ),
        );
      debugPrint('Profile photo upload failed: $error');
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
              backgroundColor: const Color(0xFF573A63),
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF573A63),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// PROFILE AVATAR
            InkWell(
              onTap: _pickAndUploadPhoto,
              customBorder: const CircleBorder(),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE9E1EC),
                    backgroundImage: profilePhotoUrl == null
                        ? null
                        : NetworkImage(profilePhotoUrl!),
                    child: isUploadingPhoto
                        ? const CircularProgressIndicator(color: Colors.white)
                        : profilePhotoUrl == null
                        ? Text(
                            displayName != null && displayName!.isNotEmpty
                                ? displayName![0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Color(0xFF573A63),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF367C78),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF7F4F1),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text(
              displayName ?? "User",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 7),
            const Text(
              'Tap your photo to change it',
              style: TextStyle(fontSize: 12, color: Color(0xFF817785)),
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
                  tileColor: const Color(0xFFE9E1EC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(item.icon, color: Color(0xFF573A63)),
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
