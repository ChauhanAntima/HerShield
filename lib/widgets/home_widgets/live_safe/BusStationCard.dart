import 'package:flutter/material.dart';
import 'nearby_place_tile.dart';

class BusStationCard extends StatelessWidget {
  final Function? onMapFunction;
  const BusStationCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) => NearbyPlaceTile(
        label: 'Bus stops',
        asset: 'assets/bus-stop.png',
        onTap: () => onMapFunction?.call('bus stops near me'),
      );
}
