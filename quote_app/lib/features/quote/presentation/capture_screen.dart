import 'package:flutter/material.dart';

import '../../../core/theme/brand_theme.dart';
import '../domain/quote_model.dart';
import 'capture_form.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({
    super.key,
    required this.brand,
    required this.onSwitchBrand,
  });

  final BrandTheme brand;
  final VoidCallback onSwitchBrand;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(brand.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: 'Switch brand',
          onPressed: onSwitchBrand,
        ),
      ],
    ),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final header = _BrandHeader(
            name: brand.name,
            logoAsset: brand.logoAsset,
          );

          if (constraints.maxWidth < 700) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(bottom: 24), child: header),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CaptureForm(
                      onSubmit: (request) => _showPremium(context, request),
                    ),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              SizedBox(width: 320, child: header),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CaptureForm(
                      onSubmit: (request) => _showPremium(context, request),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  void _showPremium(BuildContext context, QuoteRequest request) {
    final premium = calculatePremium(request);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Premium ${premium.rands}')));
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.name, required this.logoAsset});

  final String name;
  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        Positioned(
          left: 16,
          top: 16,
          right: 16,
          child: Row(
            children: [
              Image.asset(logoAsset, height: 40, semanticLabel: '$name logo'),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  name,
                  style: tt.titleLarge?.copyWith(color: cs.onPrimary),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          right: 16,
          bottom: -20,
          child: Chip(
            label: const Text('Comprehensive'),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        ),

        const Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.shield, size: 48, color: Colors.white24),
          ),
        ),
      ],
    );
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) =>
      Text(amount.rands, style: Theme.of(context).textTheme.headlineMedium);
}

extension on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}
