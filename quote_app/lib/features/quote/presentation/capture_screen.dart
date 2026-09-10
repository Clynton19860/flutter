import 'package:flutter/material.dart';
import 'package:quote_app/core/extensions/money_extension.dart';
import 'capture_form.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/core/theme/brand_theme.dart';


class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key, required this.brand, required this.onSwitchBrand});
  final BrandTheme brand;
  final VoidCallback onSwitchBrand;


  void _showPremium(BuildContext context, QuoteRequest r) {
    final premium = calculatePremium(r);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Premium: R${premium.toStringAsFixed(2)}',
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) =>
      Scaffold(
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
                final size = MediaQuery.sizeOf(context);
                final isWide = size.width >= 700;
                final header = _BrandHeader(name: brand.name, logoAsset: brand.logoAsset);
                final body = Padding(
                  padding: const EdgeInsets.all(16),
                  child: CaptureForm(onSubmit: (r) => _showPremium(context, r)),
                );

                if (!isWide) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        header,
                        const SizedBox(height: 32),
                        CaptureForm(
                          onSubmit: (r) => _showPremium(context, r),
                        ),
                      ],
                    ),
                  );
                }

                return Row(
                  children: [
                    SizedBox(
                      width: 320,
                      child: header,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: body,
                      ),
                    ),
                  ],
                );
              },
              )
          )
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          Positioned(
            left: 16,
            top: 16,
            child: Row(
              children: [
                Image.asset(
                  logoAsset,
                  height: 28,
                  semanticLabel: '$name logo',
                ),
                const SizedBox(width: 8),
                Text(
                  name,
                  style: tt.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16, bottom: -20,
            child: Chip(
                label: Text('Comprehensive'), backgroundColor: Colors.white),
          ),
          const Positioned.fill(
            child: Align(
                alignment: Alignment.center,
                child: Icon(Icons.shield, size: 48, color: Colors.white24,)
            ),
          ),
        ]
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