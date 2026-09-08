# 05 · The header that dies on the first frame

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

[//]: # TODO confrim lifecycle fix(https://mailharshkhatri.medium.com/understanding-didchangedependencies-in-flutter-a-guide-to-statefulwidget-lifecycle-methods-4b64d7883e25)
[//]: # didChangeDependencies() runs right after initState() (once the widget is actually attached to the tree) and again whenever an inherited ancestor it depends on changes — so it's the safe place to call Theme.of(context)/MediaQuery.of(context).
```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: BrandHeader())));

class BrandHeader extends StatefulWidget {
  const BrandHeader({super.key});
  @override
  State<BrandHeader> createState() => _BrandHeaderState();
}

class _BrandHeaderState extends State<BrandHeader> {
  late Color _accent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _accent = Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _accent,
    child: const SizedBox(height: 80, width: double.infinity),
  );
}
```

## What you should see

It compiles. On Run you get a red screen: `dependOnInheritedWidgetOfExactType<_InheritedTheme>() or dependOnInheritedElement() was called before _BrandHeaderState.initState() completed`

## Clue

`Theme.of(context)` walks up the tree looking for an ancestor. Ask yourself whether this widget is properly attached to that tree at the moment `initState` runs.

## Why it matters

Anything that reads `Theme`, `MediaQuery` or a Provider is doing an inherited lookup, and none of them are safe in `initState`.

---

Solution: `solutions/exercise_05.dart`
