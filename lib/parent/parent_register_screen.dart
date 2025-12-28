// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../child/child_login_screen.dart';
// import '../components/PrimaryButton.dart';
// import '../components/SecondaryButton.dart';
// import '../components/custom_textfield.dart';
// import '../utils/constants.dart';
//
// class RegisterParentScreen extends StatefulWidget {
//   const RegisterParentScreen({Key? key}) : super(key: key);
//
//   @override
//   State<RegisterParentScreen> createState() => _RegisterParentScreenState();
// }
//
// class _RegisterParentScreenState extends State<RegisterParentScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final Map<String, String> _formData = {};
//
//   bool isPasswordShown = true;
//   bool isRetypePasswordShown = true;
//   bool isLoading = false;
//
//   Future<void> _onSubmit() async {
//     _formKey.currentState!.save();
//
//     if (_formData['password'] != _formData['rpassword']) {
//       dialogueBox(context, 'Passwords do not match');
//       return;
//     }
//
//     try {
//       setState(() => isLoading = true);
//
//       final userCredential =
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _formData['email']!,
//         password: _formData['password']!,
//       );
//
//       final uid = userCredential.user!.uid;
//
//       await FirebaseFirestore.instance.collection('users').doc(uid).set({
//         'id': uid,
//         'name': _formData['name'],
//         'phone': _formData['phone'],
//         'guardianEmail': _formData['email'],
//         'type': 'parent',
//       });
//
//       // redirect to login
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => LoginScreen()),
//       );
//     } on FirebaseAuthException catch (e) {
//       dialogueBox(
//         context,
//         e.code == 'email-already-in-use'
//             ? 'This email is already registered. Please login.'
//             : e.message ?? 'Something went wrong',
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       /// ✅ BACK BUTTON (100% WORKING)
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_new,
//             color: Colors.black,
//           ),
//           onPressed: () {
//             Navigator.of(context).maybePop();
//           },
//         ),
//       ),
//
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 /// IMAGE
//                 Image.asset(
//                   'assets/parent.png',
//                   height: 120,
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 Text(
//                   'Register as Guardian',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: kColorRed,
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 CustomTextField(
//                   hintText: 'Name',
//                   onsave: (v) => _formData['name'] = v ?? '',
//                   validate: (v) =>
//                   v!.length < 3 ? 'Enter valid name' : null,
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 CustomTextField(
//                   hintText: 'Phone',
//                   keyboardtype: TextInputType.phone,
//                   onsave: (v) => _formData['phone'] = v ?? '',
//                   validate: (v) =>
//                   v!.length < 10 ? 'Enter valid phone' : null,
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 CustomTextField(
//                   hintText: 'Email',
//                   keyboardtype: TextInputType.emailAddress,
//                   onsave: (v) => _formData['email'] = v ?? '',
//                   validate: (v) =>
//                   !v!.contains('@') ? 'Enter valid email' : null,
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 CustomTextField(
//                   hintText: 'Password',
//                   isPassword: isPasswordShown,
//                   onsave: (v) => _formData['password'] = v ?? '',
//                   suffix: IconButton(
//                     icon: Icon(
//                       isPasswordShown
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         isPasswordShown = !isPasswordShown;
//                       });
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 CustomTextField(
//                   hintText: 'Confirm Password',
//                   isPassword: isRetypePasswordShown,
//                   onsave: (v) => _formData['rpassword'] = v ?? '',
//                   suffix: IconButton(
//                     icon: Icon(
//                       isRetypePasswordShown
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         isRetypePasswordShown =
//                         !isRetypePasswordShown;
//                       });
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 PrimaryButton(
//                   title: 'REGISTER',
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       _onSubmit();
//                     }
//                   },
//                 ),
//
//                 const SizedBox(height: 20),
//
//                 /// LOGIN LINK
//                 SecondaryButton(
//                   title: 'Already have an account? Login',
//                   onPressed: () {
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => LoginScreen()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../child/child_login_screen.dart';
import '../components/PrimaryButton.dart';
import '../components/SecondaryButton.dart';
import '../components/custom_textfield.dart';
import '../utils/constants.dart';

class RegisterParentScreen extends StatefulWidget {
  const RegisterParentScreen({Key? key}) : super(key: key);

  @override
  State<RegisterParentScreen> createState() => _RegisterParentScreenState();
}

class _RegisterParentScreenState extends State<RegisterParentScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  bool isPasswordShown = true;
  bool isRetypePasswordShown = true;
  bool isLoading = false;

  Future<void> _onSubmit() async {
    _formKey.currentState!.save();

    if (_formData['password'] != _formData['rpassword']) {
      dialogueBox(context, 'Passwords do not match');
      return;
    }

    try {
      setState(() => isLoading = true);

      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _formData['email']!,
        password: _formData['password']!,
      );

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'id': uid,
        'name': _formData['name'],
        'phone': _formData['phone'],
        'guardianEmail': _formData['email'],
        'type': 'parent',
        'profilePic': null, // ✅ added (structure consistency)
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      dialogueBox(
        context,
        e.code == 'email-already-in-use'
            ? 'This email is already registered. Please login.'
            : e.message ?? 'Something went wrong',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/parent.png', height: 120),
                const SizedBox(height: 20),
                Text(
                  'Register as Guardian',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kColorRed,
                  ),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  hintText: 'Name',
                  onsave: (v) => _formData['name'] = v ?? '',
                  validate: (v) =>
                  v!.length < 3 ? 'Enter valid name' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hintText: 'Phone',
                  keyboardtype: TextInputType.phone,
                  onsave: (v) => _formData['phone'] = v ?? '',
                  validate: (v) =>
                  v!.length < 10 ? 'Enter valid phone' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hintText: 'Email',
                  keyboardtype: TextInputType.emailAddress,
                  onsave: (v) => _formData['email'] = v ?? '',
                  validate: (v) =>
                  !v!.contains('@') ? 'Enter valid email' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hintText: 'Password',
                  isPassword: isPasswordShown,
                  onsave: (v) => _formData['password'] = v ?? '',
                  suffix: IconButton(
                    icon: Icon(isPasswordShown
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => isPasswordShown = !isPasswordShown),
                  ),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hintText: 'Confirm Password',
                  isPassword: isRetypePasswordShown,
                  onsave: (v) => _formData['rpassword'] = v ?? '',
                  suffix: IconButton(
                    icon: Icon(isRetypePasswordShown
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () => setState(() =>
                    isRetypePasswordShown = !isRetypePasswordShown),
                  ),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  title: 'REGISTER',
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _onSubmit();
                    }
                  },
                ),
                const SizedBox(height: 20),
                SecondaryButton(
                  title: 'Already have an account? Login',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
