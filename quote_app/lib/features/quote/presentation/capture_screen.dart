import 'package:flutter/material.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Get a quote')),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 700) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  _BrandHeader(),
                  FormArea(),
                ],
              ),
            );
          }

          return Row(
            children: [
              SizedBox(
                width: 320,
                  child: _BrandHeader(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: FormArea(),
                ),
              ),
            ],
          );
        }
      ),
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
        margin: const EdgeInsets.all(10),
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),

      Positioned(
        right: 16,
        bottom: 20,
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

class FormArea extends StatelessWidget {
  const FormArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 370,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
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

extension on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}
