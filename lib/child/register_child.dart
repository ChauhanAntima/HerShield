// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// import '../components/PrimaryButton.dart';
// import '../components/SecondaryButton.dart';
// import '../components/custom_textfield.dart';
// import '../model/user_model.dart';
// import '../utils/constants.dart';
// import 'child_login_screen.dart';
//
// class RegisterChildScreen extends StatefulWidget {
//   const RegisterChildScreen({Key? key}) : super(key: key);
//
//   @override
//   State<RegisterChildScreen> createState() => _RegisterChildScreenState();
// }
//
// class _RegisterChildScreenState extends State<RegisterChildScreen> {
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
//       dialogueBox(context, 'Password and Confirm Password must match');
//       return;
//     }
//
//     try {
//       setState(() => isLoading = true);
//
//       final userCredential =
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: _formData['cemail']!,
//         password: _formData['password']!,
//       );
//
//       final uid = userCredential.user!.uid;
//
//       final user = UserModel(
//         id: uid,
//         name: _formData['name']!,
//         phone: _formData['phone']!,
//         childEmail: _formData['cemail']!,
//         guardianEmail: _formData['gemail']!,
//         type: 'child',
//       );
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(uid)
//           .set(user.toJson());
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => LoginScreen()),
//       );
//     } on FirebaseAuthException catch (e) {
//       dialogueBox(
//         context,
//         e.code == 'email-already-in-use'
//             ? 'This email is already registered'
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
//       /// 🔙 BACK BUTTON
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
//                 /// TITLE
//                 Text(
//                   'Register as Child',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: kColorRed,
//                   ),
//                 ),
//
//                 const SizedBox(height: 16),
//
//                 /// IMAGE
//                 Image.asset(
//                   'assets/logo.png',
//                   height: 110,
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 /// FORM FIELDS
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
//                   hintText: 'Child Email',
//                   keyboardtype: TextInputType.emailAddress,
//                   onsave: (v) => _formData['cemail'] = v ?? '',
//                   validate: (v) =>
//                   !v!.contains('@') ? 'Enter valid email' : null,
//                 ),
//
//                 const SizedBox(height: 14),
//
//                 CustomTextField(
//                   hintText: 'Guardian Email',
//                   keyboardtype: TextInputType.emailAddress,
//                   onsave: (v) => _formData['gemail'] = v ?? '',
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

import '../components/PrimaryButton.dart';
import '../components/SecondaryButton.dart';
import '../components/custom_textfield.dart';
import '../model/user_model.dart';
import '../utils/constants.dart';
import 'child_login_screen.dart';

class RegisterChildScreen extends StatefulWidget {
  const RegisterChildScreen({Key? key}) : super(key: key);

  @override
  State<RegisterChildScreen> createState() => _RegisterChildScreenState();
}

class _RegisterChildScreenState extends State<RegisterChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  bool isPasswordShown = true;
  bool isRetypePasswordShown = true;
  bool isLoading = false;

  Future<void> _onSubmit() async {
    _formKey.currentState!.save();

    if (_formData['password'] != _formData['rpassword']) {
      dialogueBox(context, 'Password and Confirm Password must match');
      return;
    }

    try {
      setState(() => isLoading = true);

      /// 🔍 CHECK IF GUARDIAN EXISTS
      final guardianQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('type', isEqualTo: 'parent')
          .where(
        'guardianEmail',
        isEqualTo: _formData['gemail'],
      )
          .get();

      if (guardianQuery.docs.isEmpty) {
        dialogueBox(context, 'Guardian not registered. Please ask guardian to register first.');
        setState(() => isLoading = false);
        return;
      }

      /// 🔐 CREATE CHILD AUTH
      final userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _formData['cemail']!,
        password: _formData['password']!,
      );

      final uid = userCredential.user!.uid;

      final user = UserModel(
        id: uid,
        name: _formData['name']!,
        phone: _formData['phone']!,
        childEmail: _formData['cemail']!,
        guardianEmail: _formData['gemail']!,
        type: 'child',
        profilePic: null,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(user.toJson());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      dialogueBox(
        context,
        e.code == 'email-already-in-use'
            ? 'This email is already registered'
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
                Text(
                  'Register as Child',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kColorRed,
                  ),
                ),
                const SizedBox(height: 16),
                Image.asset('assets/logo.png', height: 110),
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
                  hintText: 'Child Email',
                  keyboardtype: TextInputType.emailAddress,
                  onsave: (v) => _formData['cemail'] = v ?? '',
                  validate: (v) =>
                  !v!.contains('@') ? 'Enter valid email' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hintText: 'Guardian Email',
                  keyboardtype: TextInputType.emailAddress,
                  onsave: (v) => _formData['gemail'] = v ?? '',
                  validate: (v) =>
                  !v!.contains('@') ? 'Enter valid email' : null,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hintText: 'Password',
                  isPassword: isPasswordShown,
                  onsave: (v) => _formData['password'] = v ?? '',
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  hintText: 'Confirm Password',
                  isPassword: isRetypePasswordShown,
                  onsave: (v) => _formData['rpassword'] = v ?? '',
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
