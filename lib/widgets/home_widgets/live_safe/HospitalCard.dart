import 'package:flutter/material.dart';
import 'nearby_place_tile.dart';

class HospitalCard extends StatelessWidget {
  final Function? onMapFunction;
  const HospitalCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) => NearbyPlaceTile(
        label: 'Hospitals',
        asset: 'assets/hospital.png',
        onTap: () => onMapFunction?.call('Hospitals near me'),
      );
}
