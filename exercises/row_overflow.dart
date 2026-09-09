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