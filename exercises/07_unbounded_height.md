# 07 · The list with no height

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
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
```

## What you should see

Compiles. On Run: `Vertical viewport was given unbounded height`

## Clue

A Column tells its children they may be as tall as they like. A ListView scrolls, so it needs to know how tall it is allowed to be. Those two statements are in direct conflict.

## Why it matters

This is the second most common layout error after overflow, and the message names the cause precisely once you know what a viewport is.

---

Solution: `solutions/exercise_07.dart`

ListView needs a bounded height to know how much to lay out/scroll, but Column gives children unbounded height — conflict throws the error. Fix: wrap the ListView in Expanded so it gets the remaining space instead of "unbounded."