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
    ref.listen<QuoteState>(quoteProvider, (prev, next) {
      switch (next) {
        case QuoteLoaded(:final quote):
          context.push('/quote/result/${quote.id}');
        case QuoteFailed(:final message):
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
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
            final twoColumn = constraints.maxWidth >= 700;
            const header = _BrandHeader();
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
                  QuoteLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  QuoteLoaded() => const Text('Opening your quote...'),
                  QuoteFailed(:final message) => Text(
                    message,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                },
              ],
            );

            if (twoColumn) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 280,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: header,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: form,
                    ),
                  ),
                ],
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [header, const SizedBox(height: 24), form],
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
    final tt = Theme.of(context).textTheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned(
          left: 16,
          top: 16,
          right: 16,
          child: Row(
            children: [
              Image.asset(
                brand.logoAsset,
                height: 28,
                semanticLabel: '${brand.name} logo',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  brand.name,
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
            child: Icon(Icons.shield, size: 48, color: Colors.white24),
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
  Widget build(BuildContext context) =>
      Text(amount.rands, style: Theme.of(context).textTheme.headlineMedium);
}
