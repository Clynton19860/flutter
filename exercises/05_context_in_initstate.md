# 05 · The header that dies on the first frame

Paste the whole file into **dartpad.dev** (Flutter pad) and press Run.

```dart
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
  home: Scaffold(
    body: SafeArea(
      BrandHeader()
      )
    )
  ));

// BrandHeader displays a branding bar using the current theme's primary color. It avoids accessing inherited widgets in initState by using the 'didChangeDependencies' lifecycle method or by accessing the theme within the 'build' method

class BrandHeader extends StatefulWidget {
  const BrandHeader({super.key});

  @override
  State<BrandHeader> createState() => _BrandHeaderState();
}

class _BrandHeaderState extends State<BrandHeader> {
  // late is used to signify that this depends on build context context
  late final Color _accent;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // this is safe to call because the widget is attached to the tree
  _accent = Theme.of(context).colorScheme.primary;
}

@override
Widget build(BuildContext context) {
  return ColoredBox(
    color: _accent,
    child: const SizedBox(
      height: 80.
      width: double.infinity,
      child: Center(
        child: Text(
          'Brand Header',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20
          )
        )
      )
    ))
  }
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
