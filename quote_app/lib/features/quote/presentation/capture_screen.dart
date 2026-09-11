import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  static const _wideBreakpoint = 700.0;

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandProvider);
    final state = ref.watch(quoteProvider);

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
          builder: (context, constraints) {
            final form = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CaptureForm(
                  enabled: state is! QuoteLoading,
                  onSubmit: (r) => ref.read(quoteProvider.notifier).submit(r),
                ),
                const SizedBox(height: 16),
                switch (state) {
                  QuoteIdle() => const Text('Fill in the form to get a quote'),
                  QuoteLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  QuoteLoaded() => const Text('Opening your quote...'),
                  QuoteFailed(:final message) => Text(
                      message,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                },
              ],
            );
            final header = const _BrandHeader();
            if (constraints.maxWidth >= CaptureScreen._wideBreakpoint) {
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
}

class _BrandHeader extends ConsumerWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    final cs = Theme.of(context).colorScheme;
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
            child: Image.asset(
              brand.logoAsset,
              width: 120,
              height: 96,
              fit: BoxFit.contain,
              semanticLabel: '${brand.name} logo',
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