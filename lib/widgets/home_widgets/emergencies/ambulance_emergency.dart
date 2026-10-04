import 'package:flutter/material.dart';
import '../emergency_service_card.dart';

class AmbulanceEmergency extends StatelessWidget {
  const AmbulanceEmergency({super.key});

  @override
  Widget build(BuildContext context) => const EmergencyServiceCard(
        title: 'Ambulance',
        subtitle: 'Medical emergency',
        number: '108',
        icon: Icons.medical_services_rounded,
        accent: Color(0xFF367C78),
      );
}
