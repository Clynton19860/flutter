import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  static const _wideBreakpoint = 700.0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Get a quote')),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= _wideBreakpoint) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 280, child: _BrandHeader()),
                      const SizedBox(width: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _QuoteFormPlaceholder(),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: const Column(
                  children: [
                    _BrandHeader(),
                    SizedBox(height: 32),
                    _QuoteFormPlaceholder(),
                  ],
                ),
              );
            },
          ),
        ),
      );
}

class _QuoteFormPlaceholder extends StatelessWidget {
  const _QuoteFormPlaceholder();

  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Quote form goes here')),
        ),
      );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) => Stack(
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
            child: Text(
              'Alpha Insure',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
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
          const Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(Icons.shield, size: 48, color: Colors.white24),
            ),
          ),
        ],
      );
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