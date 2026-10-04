import 'package:flutter/material.dart';

/// A compact, theme-aware illustration used by both registration screens.
class RegistrationIllustration extends StatelessWidget {
  const RegistrationIllustration({required this.isGuardian, super.key});

  final bool isGuardian;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      label: isGuardian ? 'Guardian and family safety' : 'Child personal safety',
      image: true,
      child: Container(
        width: 132,
        height: 132,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.primaryContainer, const Color(0xFFF3E9E8)],
          ),
          border: Border.all(color: colors.primary.withOpacity(0.12), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withOpacity(0.10),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: colors.surface.withOpacity(0.72),
                shape: BoxShape.circle,
              ),
            ),
            Icon(
              isGuardian ? Icons.family_restroom_rounded : Icons.person_rounded,
              size: 66,
              color: colors.primary,
            ),
            Positioned(
              right: 17,
              bottom: 17,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 3),
                ),
                child: Icon(
                  isGuardian ? Icons.shield_rounded : Icons.favorite_rounded,
                  size: 19,
                  color: colors.onSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
