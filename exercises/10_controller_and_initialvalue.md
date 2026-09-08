# 10 · Two sources of truth

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: MakeField())));

class MakeField extends StatefulWidget {
  const MakeField({super.key});
  @override
  State<MakeField> createState() => _MakeFieldState();
}

class _MakeFieldState extends State<MakeField> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: _controller,
        initialValue: 'VW',
        decoration: const InputDecoration(labelText: 'Make'),
      );
}
```

## What you should see

Compiles. On Run, an assertion fires: `'initialValue == null || controller == null' is not true`

## Clue

Both of those parameters are trying to decide what the field starts with. Flutter refuses to guess which one you meant.

## Why it matters

There is a second bug in this one that Flutter will not tell you about. The controller is never disposed, which leaks every time the screen is rebuilt. Fix that too.

---

Solution: `solutions/exercise_10.dart`
