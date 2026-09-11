import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/core/theme/brand_theme.dart';
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

    final baseTheme = Theme.of(context);
    // iOS system-font look, scoped to this screen only via a local Theme
    // override - `.SF Pro Text` resolves to the real system font on iOS/
    // macOS (Apple's own font-matching convention) and falls back to the
    // platform default everywhere else. Doesn't touch BrandTheme, so
    // Settings/Saved/Onboarding are unaffected.
    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: '.SF Pro Text'),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(brand.name),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Frosted, translucent nav bar - the iOS convention - rather than
          // an opaque Material app bar.
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.transparent),
            ),
          ),
          actions: [
            // Quick brand toggle is a debug convenience; release builds only
            // switch brand through the Settings screen's picker.
            if (kDebugMode)
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
              final header = _GlassHero(brand: brand);
              final form = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CaptureForm(
                    enabled: state is! QuoteLoading,
                    onSubmit: (r) => ref.read(quoteProvider.notifier).submit(r),
                  ),
                  const SizedBox(height: 16),
                  switch (state) {
                    QuoteIdle() => const Text(
                      'Fill in the form to get a quote',
                    ),
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
                    QuoteExpired() => Text(
                      'Your quote has expired - get a new one',
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
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [header, const SizedBox(height: 24), form],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism hero: gradient card, soft translucent "blobs" for depth,
/// and a frosted pill for the selected cover - all colour driven by the
/// active BrandTheme, none of it hardcoded.
class _GlassHero extends StatelessWidget {
  const _GlassHero({required this.brand});
  final BrandTheme brand;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 180,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primary, cs.primaryContainer],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -30,
                right: -30,
                child: _GlassBlob(size: 140, color: cs.onPrimary),
              ),
              const Positioned(
                bottom: -50,
                left: -30,
                child: _GlassBlob(size: 170, color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      brand.logoAsset,
                      height: 32,
                      semanticLabel: '${brand.name} logo',
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        brand.name,
                        style: tt.titleLarge?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Positioned(left: 20, bottom: 20, child: _GlassPill()),
            ],
          ),
        ),
      ),
    );
  }
}

// A soft translucent circle behind the glass - decorative texture only, so
// like the old watermark icon, white is the sanctioned exception here
// rather than a brand colour.
class _GlassBlob extends StatelessWidget {
  const _GlassBlob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.12),
    ),
  );
}

class _GlassPill extends StatelessWidget {
  const _GlassPill();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Text(
            'Comprehensive',
            style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600),
          ),
        ),
      ),
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
