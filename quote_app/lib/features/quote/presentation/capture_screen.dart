import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/core/theme/brand_theme.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';
// import 'package:quote_app/features/quote/presentation/premium_card.dart';
// import 'package:quote_app/features/quote/presentation/quote_providers.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key, required this.brand, required this.onSwitchBrand});

  final BrandTheme brand;
  final VoidCallback onSwitchBrand;

  static const _wideBreakpoint = 700.0;

  void _showPremium(BuildContext context, QuoteRequest r) {
    final premium = calculatePremium(r);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Premium ${premium.rands}')),
    );
  }

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
              final form = CaptureForm(
                onSubmit: (r) => _showPremium(context, r),
                enabled: true,
              );
              final header = _BrandHeader(name: brand.name, logoAsset: brand.logoAsset);
              if (constraints.maxWidth >= _wideBreakpoint) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 280, child: header),
                      const SizedBox(width: 24),
                      Expanded(
                        child: SingleChildScrollView(child: form),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    header,
                    const SizedBox(height: 32),
                    form,
                  ],
                ),
              );
            },
          ),
        ),
      );
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
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned(
          left: 16,
          top: 16,
          child: Row(
            children: [
              Image.asset(logoAsset, height: 28, semanticLabel: '$name logo'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: tt.titleLarge?.copyWith(color: cs.onPrimaryContainer),
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
            backgroundColor: cs.surface,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.shield,
              size: 48,
              color: Colors.white24,
            ),
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
  Widget build(BuildContext context) => Text(
        amount.rands,
        style: Theme.of(context).textTheme.headlineMedium,
      );
}