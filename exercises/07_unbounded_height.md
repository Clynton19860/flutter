# 07 · The list with no height

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<QuoteData>(
      create: (context) => QuoteData(),
      builder: (context, child) => const MaterialApp(
        home: SavedQuotes(),
      ),
    ),
  );
}

class QuoteData extends ChangeNotifier {
  final List<String> _quotes = ['VW Polo', 'BMW 320i', 'Toyota Corolla'];
  List<String> get quotes => List.unmodifiable(_quotes);

  void addQuote(String quote) {
    _quotes.add(quote);
    notifyListeners();
  }
}

class SavedQuotes extends StatelessWidget {
  const SavedQuotes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved quotes'),
      ),
      body: Consumer<QuoteData>(
        builder: (context, data, child) {
          return ListView.builder(
            itemCount: data.quotes.length,
            itemBuilder: (context, i) => ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text(data.quotes[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<QuoteData>().addQuote('New Vehicle ${DateTime.now().second}'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## What you should see

Compiles. On Run: `Vertical viewport was given unbounded height`

## Clue

A Column tells its children they may be as tall as they like. A ListView scrolls, so it needs to know how tall it is allowed to be. Those two statements are in direct conflict.

## Why it matters

This is the second most common layout error after overflow, and the message names the cause precisely once you know what a viewport is.

---

Solution: `solutions/exercise_07.dart`
