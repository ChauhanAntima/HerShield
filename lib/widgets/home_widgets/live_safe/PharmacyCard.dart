import 'package:flutter/material.dart';
import 'nearby_place_tile.dart';

class PharmacyCard extends StatelessWidget {
  final Function? onMapFunction;
  const PharmacyCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) => NearbyPlaceTile(
        label: 'Pharmacies',
        asset: 'assets/pharmacy.png',
        onTap: () => onMapFunction?.call('pharmacies near me'),
      );
}
