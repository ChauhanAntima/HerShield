import 'package:flutter/material.dart';
import '../emergency_service_card.dart';

class PoliceEmergency extends StatelessWidget {
  const PoliceEmergency({super.key});

  @override
  Widget build(BuildContext context) => const EmergencyServiceCard(
        title: 'National emergency',
        subtitle: 'Police · Fire · Medical',
        number: '112',
        icon: Icons.support_agent_rounded,
        accent: Color(0xFFB8404A),
      );
}
