import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';
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

    // Side effects: navigation and snackbars. Never in the returned tree.
    ref.listen(quoteProvider, (prev, next) {
      switch (next) {
        case QuoteLoaded(:final quote):
          context.push('/quote/result/${quote.id}');
        case QuoteFailed(:final message):
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(brand.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch brand',
            onPressed: () => ref.read(brandKeyProvider.notifier).toggle(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            const header = _BrandHeader();
            final body = Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CaptureForm(
                    enabled: state is! QuoteLoading,
                    onSubmit: (r) =>
                        ref.read(quoteProvider.notifier).submit(r),
                  ),
                  const SizedBox(height: 16),
                  switch (state) {
                    QuoteIdle() =>
                      const Text('Fill in the form to get a quote'),
                    QuoteLoading() => const CircularProgressIndicator(),
                    QuoteLoaded() => const Text('Opening your quote...'),
                    QuoteFailed(:final message) => Text(
                        message,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    QuoteExpired(:final message) => Text(
                        message,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                  },
                ],
              ),
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

class _BrandHeader extends ConsumerWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    final name = brand.name;
    final logoAsset = brand.logoAsset;
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
