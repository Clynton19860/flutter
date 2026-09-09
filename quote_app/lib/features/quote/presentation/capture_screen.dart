import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Get a quote')),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final form = CaptureForm(onSubmit: (r) => _showPremium(context, r));

          if (constraints.maxWidth >= 700) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 280,
                  child: Padding(padding: EdgeInsets.all(16), child: _BrandHeader()),
                ),
                Expanded(
                  child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: form),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [const _BrandHeader(), const SizedBox(height: 16), form]),
          );
        },
      ),
    ),
  );

  void _showPremium(BuildContext context, QuoteRequest r) {
    final premium = calculatePremium(r);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Premium ${premium.rands}')));
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Container(
        height: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      Positioned(
        left: 16,
        top: 16,
        child: Text(
          'Quote App',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      Positioned(
        right: 16,
        bottom: -14,
        child: Chip(
          label: const Text('Comprehensive'),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    ],
  );
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text(amount.rands, style: Theme.of(context).textTheme.headlineMedium));
}
