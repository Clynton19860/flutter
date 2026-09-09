import 'package:flutter/material.dart';
import '../domain/quote_model.dart';
import './capture_form.dart';

const largeScreenMinWidth = 700;

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get a quote'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen =
                constraints.maxWidth >= largeScreenMinWidth;

            if (isLargeScreen) {
              return Row(
                children: [
                  const SizedBox(
                    width: 280,
                    child: _BrandHeader(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: const Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child:Text("data"),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Padding(
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
                          onSubmit: (request) {
                            final premium = calculatePremium(request);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Premium: R ${premium.toStringAsFixed(2)}'),
                              ),
                            );
                          },
                        )
                      ),
                    ),
                  ],
                ),
              ),
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
  Widget build(BuildContext context) =>
      Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Positioned(
            left: 16, top: 16,
            child: Text('Alpha Insure',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white)),
          ),
          Positioned(
            right: 16, bottom: -20,
            child: Chip(label: const Text('Comprehensive'),
                backgroundColor: Colors.white),
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

extension on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}