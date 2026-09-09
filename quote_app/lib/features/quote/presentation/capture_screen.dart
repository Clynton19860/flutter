import 'package:flutter/material.dart';
import 'package:quote_app/core/theme/brand_theme.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({
    super.key,
    required this.brand,
    required this.onSwitchBrand,
  });

  final BrandTheme brand;
  final VoidCallback onSwitchBrand;

  void _showPremium(BuildContext context, QuoteRequest r) {
    final premium = calculatePremium(r);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Premium ${premium.rands}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          builder: (context, c) {
            final header =
                _BrandHeader(name: brand.name, logoAsset: brand.logoAsset);
            final body = Padding(
              padding: const EdgeInsets.all(16),
              child: CaptureForm(onSubmit: (r) => _showPremium(context, r)),
            );

            if (c.maxWidth >= 700) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 280, child: header),
                  Expanded(child: SingleChildScrollView(child: body)),
                ],
              );
            }
            return SingleChildScrollView(
              child: Column(children: [header, body]),
            );
          },
        ),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(Icons.shield, size: 64, color: Colors.white24),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(logoAsset,
                        height: 28, semanticLabel: '$name logo'),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: tt.titleLarge
                            ?.copyWith(color: cs.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Get a motor quote in under a minute',
                    style:
                        tt.bodyMedium?.copyWith(color: cs.onPrimaryContainer)),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: -16,
            child: Chip(
              label: const Text('Comprehensive'),
              backgroundColor: cs.surface,
            ),
          ),
        ],
      ),
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
