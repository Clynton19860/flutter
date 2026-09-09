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
            Text('Your monthly premium',
                style: tt.labelLarge?.copyWith(color: cs.onPrimaryContainer)),
            const SizedBox(height: 8),
            Text(quote.display,
                style: tt.displaySmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 4),
            Text('Quote ref ${quote.id}',
                style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}
