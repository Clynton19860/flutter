import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';

class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Get a quote')),
    body: SafeArea(
      child: Column(
        children: [
          _brandHeader(context),
          SizedBox(height: 16),
          Expanded(
            child: ListView(scrollDirection: Axis.vertical, children: [_formy(context)]),
          ),
        ],
      ),
    ),
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
    /// TODO: Are they doing anything below?
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 700;

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumn = constraints.maxWidth >= 700;
        return twoColumn
            ? Row(
                children: [
                  // SizedBox(
                    // width: 700,
                    CaptureForm(onSubmit: (request) => _calculatePremium(request, context)),
                  // ),
                  summary(),
                ],
              )
            : Column(
                children: [
                  CaptureForm(onSubmit: (request) => _calculatePremium(request, context)),
                  summary(),
                ],
              );
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

  _calculatePremium(QuoteRequest request, context) async {
    var premium = calculatePremium(request);

    await Future.delayed(const Duration(seconds: 1));
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium calculated'),
        content: Text('Your premium is ${premium.rands}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}

/// TODO not sure if this is going to be used in the future
class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) => Text(amount.rands, style: Theme.of(context).textTheme.headlineMedium);
}
