import 'package:flutter/material.dart';
import 'package:womensafety/utils/quotes.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback? onTap;
  final int quoteIndex;

  const CustomAppBar({
    super.key,
    required this.onTap,
    required this.quoteIndex,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        sweetSayings[quoteIndex],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
