import 'package:flutter/material.dart';
import 'nearby_place_tile.dart';

class PoliceStationCard extends StatelessWidget {
  final Function? onMapFunction;
  const PoliceStationCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) => NearbyPlaceTile(
        label: 'Police stations',
        asset: 'assets/police-badge.png',
        onTap: () => onMapFunction?.call('Police stations near me'),
      );
}
