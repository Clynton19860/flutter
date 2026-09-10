// Exercise 06: The row that runs off the screen
//
// `Expanded` bounds the Text to whatever the fixed siblings leave. `overflow: TextOverflow.ellipsis` then decides what happens to text that still does not fit.

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: QuoteRow()));

class QuoteRow extends StatelessWidget {
  const QuoteRow({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Quote summary')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.directions_car),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'VW Polo 2020 1.4 TSI Comfortline 5-door',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Text('R 1 450'),
            ],
          ),
        ),
      );
}
