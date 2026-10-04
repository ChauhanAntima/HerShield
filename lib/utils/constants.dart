import 'package:flutter/material.dart';

const Color kColorDarkRed = Color(0xFF573A63);
const Color kColorLightRed = Color(0xFF367C78);
const Color kColorRed = Color(0xFF573A63);
const Color kColorLightRed1 = Color(0xFF8A6D91);
const Color kLightBackground = Color(0xFFF7F4F1);
const Color kColorLightBlue = Color(0xFFA9D2CC);
const Color kColorBlue = Color(0xFF367C78);
const Color darkGrey = Color(0xFF746B75);
const Color darkGreen = Color(0xFF367C78);
const Color lightGrey = Color(0xFF367C78);

void goTo(BuildContext context, Widget nextScreen) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => nextScreen,
      ));
}

dialogueBox(BuildContext context, String text) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(text),
    ),
  );
}

Widget progressIndicator(BuildContext context) {
  return Center(
      child: CircularProgressIndicator(
    backgroundColor: kColorRed,
    color: Colors.red,
    strokeWidth: 7,
  ));
}
