# 06 · The row that runs off the screen

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: QuoteRow()));

class QuoteRow extends StatelessWidget {
  const QuoteRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const Text(
              'R 1 450',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
```

## What you should see

`flutter analyze` says nothing. On Run you get yellow and black stripes down the right and `A RenderFlex overflowed by N pixels on the right`

## Clue

A Row gives each child as much width as it asks for. Two of these children have a fixed size. One asks for its full natural width and nothing tells it otherwise.

## Why it matters

Layout errors are paint time errors. The analyser will never catch one, which is why you have to run the app.

---

Solution: `solutions/exercise_06.dart`
