import 'package:flutter/material.dart';
import 'package:quote_app/core/extensions/money_extension.dart';
import 'capture_form.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';


class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key,});


  @override
  Widget build(BuildContext context) =>
      Scaffold(
          appBar: AppBar(title: const Text('Get a quote')),
          body: SafeArea(
              child: LayoutBuilder(builder: (context, constraints) {
                final size = MediaQuery.sizeOf(context);
                final isWide = size.width >= 700;

                if (!isWide) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BrandHeader(),
                        const SizedBox(height: 32),

                    CaptureForm(
                      onSubmit: (request) {
                        final premium = calculatePremium(request);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Premium: R${premium.toStringAsFixed(2)}',
                            ),
                          ),
                        );
                      },
                    ),
                      ],
                    ),
                  );
                }

                return Row(
                  children: [
                    const SizedBox(
                      width: 320,
                      child: _BrandHeader(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: CaptureForm(
                          onSubmit: (_) {},
                        ),
                      ),
                    ),
                  ],
                );
              },
              )
          )
      );
}


class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) =>
      Stack (
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
              left:16, top:16,
              child: Text("Alpha Insure",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
            ),
            Positioned(
              right: 16, bottom: -20,
              child: Chip(label: Text('Comprehensive'), backgroundColor: Colors.white),
            ),
            const Positioned.fill(
              child: Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.shield, size: 48, color: Colors.white24,)
              ),
            ),
          ]
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