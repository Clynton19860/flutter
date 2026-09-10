// Exercise 07: The list with no height
//
// `Expanded` gives the ListView the leftover height, which is a bound. `SizedBox(height: 200, child: ...)` works too. `shrinkWrap: true` also silences it but builds every item, so do not use it for long lists.

import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: SavedQuotes()));

class SavedQuotes extends StatelessWidget {
  const SavedQuotes({super.key});
  static const quotes = ['VW Polo', 'BMW 320i', 'Toyota Corolla'];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            const Text('Saved quotes'),
            Expanded(
              child: ListView.builder(
                itemCount: quotes.length,
                itemBuilder: (context, i) => ListTile(title: Text(quotes[i])),
              ),
            ),
          ],
        ),
      );
}
