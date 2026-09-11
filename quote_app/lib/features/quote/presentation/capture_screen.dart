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
          builder: (context, constraints) {
            final header = _BrandHeader(
              name: brand.name,
              logoAsset: brand.logoAsset,
            );

            final body = Padding(
              padding: const EdgeInsets.all(16),
              child: CaptureForm(
                onSubmit: (r) => _showPremium(context, r),
              ),
            );

            if (constraints.maxWidth >= 700) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: header),
                  Expanded(child: SingleChildScrollView(child: body)),
                ],
              );
            } else {
              return Column(
                children: [
                  header,
                  Expanded(child: SingleChildScrollView(child: body)),
                ],
              );
            }
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned(
          left: 32, top: 32, right: 32,
          child: Row(
            children: [
              Image.asset(
                logoAsset,
                height: 28,
                semanticLabel: '$name logo',
                errorBuilder: (_, __, ___) => const Icon(Icons.shield), // Failsafe if image is missing
              ),
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
      ],
    );
  }
}