import 'package:flutter/material.dart';
import 'package:quote_app/core/theme/brand_theme.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key, required this.brand, required this.onSwitchBrand});
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
          final header = _BrandHeader(name: brand.name, logoAsset: brand.logoAsset);
          final form = CaptureForm(onSubmit: (r) => _showPremium(context, r));

          if (constraints.maxWidth >= 700) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 280,
                  child: Padding(padding: const EdgeInsets.all(16), child: header),
                ),
                Expanded(
                  child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: form),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [header, const SizedBox(height: 16), form]),
          );
        },
      ),
    ),
  );

  void _showPremium(BuildContext context, QuoteRequest r) {
    final premium = calculatePremium(r);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Premium ${premium.rands}')));
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
          height: 120,
          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(16)),
        ),
        Positioned(
          left: 16,
          top: 16,
          right: 16,
          child: Row(
            children: [
              Image.asset(
                logoAsset,
                height: 28,
                width: 28,
                semanticLabel: '$name logo',
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.shield, size: 28, color: cs.onPrimary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: tt.headlineSmall?.copyWith(color: cs.onPrimary)),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: -14,
          child: Chip(label: const Text('Comprehensive'), backgroundColor: cs.surface),
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
      Center(child: Text(amount.rands, style: Theme.of(context).textTheme.headlineMedium));
}
