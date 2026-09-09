import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Get a quote')),
    body: SafeArea(child: Column(children: [_brandHeader(context), _formy(context)])),
  );

  Stack _brandHeader(BuildContext context) => Stack(
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
        child: Text('Alpha Insure', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
      ),
      Positioned(
        right: 16,
        bottom: -20,
        child: Chip(label: const Text('Comprehensive'), backgroundColor: Colors.white),
      ),
      Positioned.fill(
        child: Align(
          alignment: Alignment.center,
          child: Icon(Icons.shield, size: 48, color: Colors.white24),
        ),
      ),
    ],
  );

  LayoutBuilder _formy(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn = constraints.maxWidth >= 700;
        return twoColumn
            ? Row(
                children: [
                  Expanded(child: form()),
                  Expanded(child: summary()),
                ],
              )
            : Column(children: [form(), summary()]);
      },
    );
  }

  Widget form() => Card(
    child: const Form(
      child: Padding(padding: EdgeInsets.all(16), child: Text('Form goes here')),
    ),
  );
  Widget summary() => Card(
    child: const Padding(padding: EdgeInsets.all(16), child: Text('Summary goes here')),
  );
}

/// TODO not sure if this is going to be used in the future
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) => Text(amount.rands, style: Theme.of(context).textTheme.headlineMedium);
}
