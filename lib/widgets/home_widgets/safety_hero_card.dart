import 'package:flutter/material.dart';

class SafetyHeroCard extends StatelessWidget {
  const SafetyHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 206,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF493452), Color(0xFF6B5276), Color(0xFF367C78)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF493452).withOpacity(0.2),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -75,
            child: Container(
              width: 205,
              height: 205,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 24),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 8,
            child: Icon(
              Icons.shield_moon_rounded,
              size: 112,
              color: Colors.white.withOpacity(0.11),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 19, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.waves_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'YOUR SAFETY, ALWAYS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                const Text(
                  'A little safer,\nevery step.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 23,
                    height: 1.12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'SOS shortcut  ·  4 volume presses in 5 sec',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
