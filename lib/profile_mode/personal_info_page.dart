import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../child/child_login_screen.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();

  /// Controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController childEmailCtrl = TextEditingController();
  final TextEditingController guardianEmailCtrl = TextEditingController();

  String? profilePic;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchAndFillData(); // 🔥 MOST IMPORTANT
  }

  /// ================= FETCH DATA FROM FIRESTORE =================
  Future<void> _fetchAndFillData() async {
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

      if (!snap.exists) {
        Fluttertoast.showToast(msg: "User data not found");
        setState(() => isLoading = false);
        return;
      }

      final data = snap.data()!;

      /// 🔥 FILL CONTROLLERS BEFORE BUILD
      nameCtrl.text = data['name'] ?? '';
      phoneCtrl.text = data['phone'] ?? '';
      childEmailCtrl.text = data['childEmail'] ?? '';
      guardianEmailCtrl.text = data['guardiantEmail'] ?? '';
      profilePic = data['profilePic'];

      setState(() => isLoading = false);
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load profile");
      setState(() => isLoading = false);
    }
  }

  /// ================= SAVE UPDATED DATA =================
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': nameCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'childEmail': childEmailCtrl.text.trim(),
        'guardiantEmail': guardianEmailCtrl.text.trim(),
      });

      Fluttertoast.showToast(msg: "Profile updated successfully");
    } catch (e) {
      Fluttertoast.showToast(msg: "Profile update failed");
    }

    setState(() => isSaving = false);
  }

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    /// 🔴 IMPORTANT: jab tak data load na ho, form mat dikhao
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Profile"),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// PROFILE IMAGE
              GestureDetector(
                onTap: () async {
                  final img = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                  );
                  if (img != null) {
                    setState(() => profilePic = img.path);
                  }
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.pink,
                  backgroundImage: profilePic == null
                      ? const AssetImage('assets/add_pic.png')
                  as ImageProvider
                      : profilePic!.startsWith('http')
                      ? NetworkImage(profilePic!)
                      : FileImage(File(profilePic!)),
                ),
              ),

              const SizedBox(height: 25),

              _field(
                controller: nameCtrl,
                label: "Name",
                icon: Icons.person,
              ),
              _field(
                controller: phoneCtrl,
                label: "Phone",
                icon: Icons.phone,
                keyboard: TextInputType.phone,
              ),
              _field(
                controller: childEmailCtrl,
                label: "Child Email",
                icon: Icons.email,
              ),
              _field(
                controller: guardianEmailCtrl,
                label: "Guardian Email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: isSaving ? null : _saveProfile,
                  child: isSaving
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text(
                    "SAVE PROFILE",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= TEXT FIELD =================
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        validator: (v) =>
        v == null || v.trim().isEmpty ? "Required field" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
