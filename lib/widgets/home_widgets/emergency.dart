import 'package:flutter/material.dart';
import 'package:womensafety/widgets/home_widgets/emergencies/ambulance_emergency.dart';
import 'package:womensafety/widgets/home_widgets/emergencies/firebrigade_emergency.dart';
import 'package:womensafety/widgets/home_widgets/emergencies/police_emergency.dart';
import 'package:womensafety/widgets/home_widgets/emergencies/women_helpline.dart';



class Emergency extends StatelessWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceEmergency(),
          AmbulanceEmergency(),
          WomenHelpline(),
          FirebrigadeEmergency()
        ],
      ),
    );
  }
}
