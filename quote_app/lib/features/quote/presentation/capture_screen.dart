import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/quote_model.dart';
import './capture_form.dart';
import 'package:quote_app/core/theme/brand_provider.dart';

const largeScreenMinWidth = 700;

class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(brand.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              ref.read(brandKeyProvider.notifier).toggle();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen =
                constraints.maxWidth >= largeScreenMinWidth;

            if (isLargeScreen) {
              return Row(
                children: [
                  SizedBox(
                    width: 280,
                    child: _BrandHeader(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: CaptureForm(
                            onSubmit: (request) {
                              final premium = calculatePremium(request);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Premium: R ${premium.toStringAsFixed(2)}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,

                  children: [
                    _BrandHeader(),
                    const SizedBox(height: 24),
            Card(
            child: Padding(
            padding: const EdgeInsets.all(24),
            child: CaptureForm(
            onSubmit: (request) {
            final premium = calculatePremium(request);

            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(
            'Premium: R ${premium.toStringAsFixed(2)}',
            ),
            ),
            );
            },
            ),
            ),
            ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}




class _BrandHeader extends ConsumerWidget {
const _BrandHeader();
@override


Widget build(BuildContext context, WidgetRef ref) {
  final brand = ref.read(brandProvider);

  return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            left: 16, top: 16,
            child: Text(brand.name,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color:Theme.of(context).colorScheme.onPrimary)),
          ),
          Positioned(
            right: 16, bottom: -20,
            child: Chip(label: const Text('Comprehensive'),
                backgroundColor: Colors.white),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                brand.logoAsset,
                width: 48,
                height: 48,
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

extension on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}