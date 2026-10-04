import 'package:flutter/material.dart';

class NearbyPlaceTile extends StatelessWidget {
  const NearbyPlaceTile({
    required this.label,
    required this.asset,
    this.onTap,
    super.key,
  });

  final String label;
  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 88,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E1EC),
                borderRadius: BorderRadius.circular(19),
              ),
              alignment: Alignment.center,
              child: Image.asset(asset, height: 31, fit: BoxFit.contain),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
