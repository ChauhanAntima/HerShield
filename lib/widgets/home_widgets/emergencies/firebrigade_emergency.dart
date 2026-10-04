import 'package:flutter/material.dart';
import '../emergency_service_card.dart';

class FirebrigadeEmergency extends StatelessWidget {
  const FirebrigadeEmergency({super.key});

  @override
  Widget build(BuildContext context) => const EmergencyServiceCard(
        title: 'Fire service',
        subtitle: 'Fire emergency',
        number: '101',
        icon: Icons.local_fire_department_rounded,
        accent: Color(0xFFB66A38),
      );
}
