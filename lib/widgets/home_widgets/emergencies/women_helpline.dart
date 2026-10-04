import 'package:flutter/material.dart';
import '../emergency_service_card.dart';

class WomenHelpline extends StatelessWidget {
  const WomenHelpline({super.key});

  @override
  Widget build(BuildContext context) => const EmergencyServiceCard(
        title: 'Women helpline',
        subtitle: 'Women support service',
        number: '181',
        icon: Icons.shield_rounded,
        accent: Color(0xFF73547E),
      );
}
