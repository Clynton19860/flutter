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

  void _showPremium(BuildContext context, QuoteRequest request) {
    final premium = premiumCalculation(request);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Premium ${premium.rands}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.all(16),
      child: CaptureForm(
        onSubmit: (r) => _showPremium(context, r),
      ),
    );

    final header = _BrandHeader(
      name: brand.name,
      logoAsset: brand.logoAsset,
    );

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
          builder: (context, constraints) {
            final wideLayout = constraints.maxWidth >= 700;

            if (!wideLayout) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 32),
                    body,
                  ],
                ),
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: 320,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: header,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: body,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({
    required this.name,
    required this.logoAsset,
  });

  final String name;
  final String logoAsset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          color: cs.primaryContainer,
          child: const SizedBox(
            height: 180,
            width: double.infinity,
          ),
        ),
        Positioned(
          left: 24,
          top: 24,
          right: 24,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    logoAsset,
                    height: 28,
                    semanticLabel: '$name logo',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: tt.titleLarge?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Vehicle Insurance Quotes',
                style: tt.headlineSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 24,
          bottom: -16,
          child: Chip(
            label: const Text('Fast • Secure'),
            backgroundColor: cs.secondaryContainer,
          ),
        ),
      ],
    );
  }
}