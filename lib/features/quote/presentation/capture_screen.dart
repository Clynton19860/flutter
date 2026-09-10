import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';
import 'package:quote_app/core/theme/brand_theme.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

// final BrandTheme brand;
// final VoidCallback onSwitchBrand;

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final brand = ref.watch(brandProvider);
    final quoteState = ref.watch(quoteProvider);

    ref.listen<QuoteState>(quoteProvider, (previous, next) {
      if (next is Failed) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next.message)));
      }
    });
    const header = _BrandHeader();
    return Scaffold(
      appBar: AppBar(
        title: Text(brand.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch brand',
            onPressed: () {
              ref.read(brandKeyProvider.notifier).toggle();
            },
          ),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 700) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 24),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: CaptureForm(
                          enabled: quoteState is! Loading,
                          onSubmit: (r) {
                            ref.read(quoteProvider.notifier).submit(r);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    switch (quoteState) {
                      Idle() => const Text('Fill in the form'),

                      Loading() => const Center(
                        child: CircularProgressIndicator(),
                      ),

                      Loaded(:final quote) => PremiumCard(quote: quote),

                      Failed(:final message) => Text(message),
                    },
                  ],
                ),
              );
            }
            return Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CaptureForm(
                      enabled: quoteState is! Loading,
                      onSubmit: (r) {
                        ref.read(quoteProvider.notifier).submit(r);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                switch (quoteState) {
                  Idle() => const Text('Fill in the form'),

                  Loading() => const Center(child: CircularProgressIndicator()),

                  Loaded(:final quote) => PremiumCard(quote: quote),

                  Failed(:final message) => Text(message),
                },
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends ConsumerWidget {
  const _BrandHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                brand.logoAsset,
                height: 28,
                semanticLabel: '${brand.name} logo',
              ),
              const SizedBox(width: 8),
              Text(
                'Insurance made Simple',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: -20,
          child: Chip(
            label: const Text('Comprehensive'),
            backgroundColor: Colors.white,
          ),
        ),
        const Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Icon(
              Icons.verified_outlined,
              size: 56,
              color: Colors.white24,
            ),
          ),
        ),
      ],
    );
  }
}
