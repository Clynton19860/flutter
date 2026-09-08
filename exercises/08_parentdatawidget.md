# 08 · Expanded in the wrong place

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: BrandCard()));

class BrandCard extends StatelessWidget {
  const BrandCard({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Container(
        height: 120,
        color: Colors.indigo.shade50,
        child: const Center(
          child: Text('Alpha Insure'),
        ),
      ),
    ),
  );
}
```

## What you should see

Compiles. On Run: `Incorrect use of ParentDataWidget`

## Clue

`Expanded` does not size anything itself. It writes flex information onto its parent. Look at what its parent actually is here, and ask whether that parent knows what flex means.

## Why it matters

`Expanded` and `Flexible` are ParentDataWidgets. They only mean something directly inside a Row, Column or Flex. Not one Container away.

---

Solution: `solutions/exercise_08.dart`

INITIAL attempt
```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: BrandCard()));

class BrandCard extends StatelessWidget {
  const BrandCard({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Container(
            height: 120,
            color: Colors.indigo.shade50,
            child: Column(
              children: const [
                Expanded(child: Text('Alpha Insure')),
              ],
            ),
          ),
        ),
      );
}
```