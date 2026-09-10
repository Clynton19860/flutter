import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final _quoteservice = FakeQuoteService();
  Cover _cover = Cover.comprehensive;
  double? _premium;

  void _calculate() {
    final r = QuoteRequest(
      make: 'VW',
      model: 'Golf',
      year: 2020,
      driverAge: 30,
      cover: _cover,
    );
    setState(() => _premium = _quoteservice.calculatePremium(r));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Get a quote')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SegmentedButton<Cover>(
                segments: [
                  for (final c in Cover.values)
                    ButtonSegment(value: c, label: Text(c.name)),
                ],
                selected: {_cover},
                onSelectionChanged: (s) => setState(() => _cover = s.first),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _calculate,
                child: const Text('Calculate'),
              ),
              const SizedBox(height: 24),
              if (_premium != null) PremiumBadge(amount: _premium!),
            ],
          ),
        ),
      );
}

extension CaptureScreenState on double {
  double? calculatePremium(QuoteRequest r) {}
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, required this.amount});
  final double amount;
  String get rands => amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) => Text(
        rands,
        style: Theme.of(context).textTheme.headlineMedium,
      );
}