import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:womensafety/child/register_child.dart';
import '../components/PrimaryButton.dart';
import '../components/SecondaryButton.dart';
import '../components/custom_textfield.dart';
import '../db/share_pref.dart';
import '../parent/parent_home_screen.dart';
import '../parent/parent_register_screen.dart';
import '../utils/constants.dart';
import 'bottom_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordShown = true;
  final _formKey = GlobalKey<FormState>();
  final _formData = Map<String, Object>();
  bool isLoading = false;

  _onSubmit() async {
    _formKey.currentState!.save();
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _formData['email'].toString(),
        password: _formData['password'].toString(),
      );

      if (userCredential.user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get()
            .then((value) {
          if (mounted) {
            if (value['type'] == 'parent') {
              MySharedPrefference.saveUserType('parent');
              goTo(context, ParentHomeScreen());
            } else {
              MySharedPrefference.saveUserType('child');
              goTo(context, BottomPage());
            }
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      if (e.code == 'user-not-found') {
        dialogueBox(context, 'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        dialogueBox(context, 'Wrong password provided.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center( // Poori UI ko vertically aur horizontally center karne ke liye
            child: isLoading
                ? progressIndicator(context)
                : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Sirf utni jagah lega jitni zaroorat hai
                children: [
                  // Login Heading
                  Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: kColorRed),
                  ),

                  SizedBox(height: 30), // Text aur Fields ke beech ka gap yahan se kam karein

                  // Form Section
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          hintText: 'Enter email',
                          textInputAction: TextInputAction.next,
                          keyboardtype: TextInputType.emailAddress,
                          prefix: Icon(Icons.person),
                          onsave: (email) {
                            _formData['email'] = email ?? "";
                          },
                          validate: (email) {
                            if (email!.isEmpty ||
                                !email.contains("@")) {
                              return 'enter correct email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 15), // Inputs ke beech ka gap
                        CustomTextField(
                          hintText: 'Enter password',
                          isPassword: isPasswordShown,
                          prefix: Icon(Icons.vpn_key_rounded),
                          validate: (password) {
                            if (password!.isEmpty || password.length < 7) {
                              return 'enter correct password';
                            }
                            return null;
                          },
                          onsave: (password) {
                            _formData['password'] = password ?? "";
                          },
                          suffix: IconButton(
                              onPressed: () {
                                setState(() {
                                  isPasswordShown = !isPasswordShown;
                                });
                              },
                              icon: isPasswordShown
                                  ? Icon(Icons.visibility_off)
                                  : Icon(Icons.visibility)),
                        ),
                        SizedBox(height: 25),
                        PrimaryButton(
                            title: 'LOGIN',
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _onSubmit();
                              }
                            }),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Bottom Links Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(fontSize: 16),
                      ),
                      SecondaryButton(
                          title: 'click here', onPressed: () {}),
                    ],
                  ),
                  SecondaryButton(
                      title: 'Register as child',
                      onPressed: () {
                        goTo(context, RegisterChildScreen());
                      }),
                  SecondaryButton(
                      title: 'Register as Parent',
                      onPressed: () {
                        goTo(context, RegisterParentScreen());
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}