import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  
  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandProvider);
    final state = ref.watch(quoteProvider);

    ref.listen(quoteProvider, (previous, next) {
  if (next case Failed(:final message)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
});

    return Scaffold(
      appBar: AppBar(
        title: Text(brand.name),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(brandKeyProvider.notifier).toggle();
            },
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch brand',
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
                    const _BrandHeader(),
const SizedBox(height: 24),

switch (state) {
  Loaded(:final quote) => PremiumCard(
    quote: quote,
    onDismiss: () {
      ref.read(quoteProvider.notifier).reset();
    },
  ),

  Loading() => const Center(
    child: CircularProgressIndicator(),
  ),

  Failed(:final message) => Text(
    message,
    style: TextStyle(
      color: Theme.of(context).colorScheme.error,
    ),
  ),

  Idle() => const SizedBox.shrink(),
},

const SizedBox(height: 16),

Card(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: CaptureForm(
      enabled: state is! Loading,
      onSubmit: (r) =>
          ref.read(quoteProvider.notifier).submit(r),
    ),
  ),
),
                  ],
                ),
              );
            }

            return Row(
              children: [
                SizedBox(width: 300, child: const _BrandHeader()),
                Expanded(
  child: SingleChildScrollView(
    child: Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CaptureForm(
              enabled: state is! Loading,
              onSubmit: (r) =>
                  ref.read(quoteProvider.notifier).submit(r),
            ),
          ),
        ),

        const SizedBox(height: 16),

        switch (state) {
          Idle() => const Text('Fill in the form to get a quote'),

          Loading() => const Center(
              child: CircularProgressIndicator(),
            ),

          Loaded(:final quote) => PremiumCard(
  quote: quote,
  onDismiss: () {
    ref.read(quoteProvider.notifier).reset();
  },
),

          Failed(:final message) => Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
        },
      ],
    ),
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

class _BrandHeader extends ConsumerWidget {
  const _BrandHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 130,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        Positioned(
          left: 16,
          top: 16,
          child: Text(
            brand.name,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: Colors.white),
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

        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Image.asset(brand.logoAsset, width: 60, height: 60),
          ),
        ),
      ],
    );
  }
}
