import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key, required this.quote});
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your quote',
                style: tt.titleMedium?.copyWith(color: cs.onPrimaryContainer)),
            const SizedBox(height: 8),
            Text(
              '${quote.currency} ${quote.premium.toStringAsFixed(2)}',
              style: tt.headlineMedium?.copyWith(color: cs.onPrimaryContainer),
            ),
            Text(quote.id,
                style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}
