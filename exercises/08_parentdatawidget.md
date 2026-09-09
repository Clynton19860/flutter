# 08 · Expanded in the wrong place

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BrandCard(),
    ));

class BrandCard extends StatelessWidget {
  const BrandCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          height: 120,
          width: 300,
          color: Colors.indigo.shade50,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: const Row(
            children: [
              Icon(Icons.shield, color: Colors.indigo, size: 40),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Alpha Insure',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
