import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

/// Presentation-only detail for [Cover]. Kept out of the domain layer, which
/// has no Flutter imports.
extension _CoverPresentation on Cover {
  IconData get icon => switch (this) {
    Cover.thirdParty => Icons.local_offer_outlined,
    Cover.thirdPartyFireTheft => Icons.local_fire_department_outlined,
    Cover.comprehensive => Icons.verified_outlined,
  };

  bool get isMostPopular => this == Cover.comprehensive;
}

// Comprehensive (most popular) leads, independent of Cover's declaration
// order in the domain enum.
const _displayOrder = [
  Cover.comprehensive,
  Cover.thirdPartyFireTheft,
  Cover.thirdParty,
];

class CoverPicker extends StatelessWidget {
  const CoverPicker({super.key, required this.value, required this.onChanged});
  final Cover value;
  final ValueChanged<Cover> onChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select your preferred cover type', style: tt.headlineSmall),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final cover in _displayOrder)
              Flexible(
                child: _CoverCard(
                  cover: cover,
                  selected: cover == value,
                  onTap: () => onChanged(cover),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _CoverCard extends StatelessWidget {
  const _CoverCard({
    required this.cover,
    required this.selected,
    required this.onTap,
  });
  final Cover cover;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? cs.primary : cs.outlineVariant,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cover.icon, color: cs.primary, size: 28),
                  const SizedBox(height: 12),
                  Text(
                    cover.label,
                    textAlign: TextAlign.center,
                    style: tt.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (cover.isMostPopular)
          Positioned(
            top: -10,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: cs.primary),
              ),
              child: Text(
                'Most popular',
                style: tt.labelSmall?.copyWith(
                  color: cs.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
