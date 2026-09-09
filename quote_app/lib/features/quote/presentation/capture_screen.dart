import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  void _showPremium(BuildContext context, QuoteRequest r) {
    final premium = calculatePremium(r);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Premium ${premium.rands}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Mobile layout
            if (constraints.maxWidth < 700) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandHeader(),

                    const SizedBox(height: 24),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: CaptureForm(
                          onSubmit: (r) => _showPremium(context, r),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Large screen layout
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 320,
                  child: _BrandHeader(),
                ),

                const SizedBox(width: 24),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: CaptureForm(
                          onSubmit: (r) => _showPremium(context, r),
                        ),
                      ),
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
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
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
          left: 16, top: 16,
          child: Text('Alpha Insure',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
        ),
        Positioned(
          right: 16, bottom: -20,
          child: Chip(label: const Text('Comprehensive'), backgroundColor: Colors.white),
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
}