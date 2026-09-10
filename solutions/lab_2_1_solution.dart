import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Get a quote')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            const header = _BrandHeader(name: 'Alpha Insure');
            const body = Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Capture form goes here in Lab 2.2'),
                ),
              ),
            );

            if (c.maxWidth >= 700) {
              return const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 280, child: header),
                  Expanded(child: SingleChildScrollView(child: body)),
                ],
              );
            }
            return const SingleChildScrollView(
              child: Column(children: [header, body]),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
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
                Text(name,
                    style: tt.titleLarge?.copyWith(color: cs.onPrimaryContainer)),
                const SizedBox(height: 4),
                Text('Get a motor quote in under a minute',
                    style: tt.bodyMedium?.copyWith(color: cs.onPrimaryContainer)),
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
