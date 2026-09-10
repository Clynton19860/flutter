# 11 · The header that stops updating

**Day 3 · Riverpod.** These need the packages, so run them in your `quote_app`,
not DartPad. Drop the widget into `capture_screen.dart` and hot restart.

```dart
class BrandTitle extends ConsumerWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.read(brandProvider);      // <-- here
    return Text(brand.name);
  }
}
```

## What you should see

Nothing. It compiles, it analyzes clean, the app runs, the title shows the right
brand on first paint. Then you press the switch-brand button and **the title does
not change.** No exception. No red screen. No log line.

## Clue

Four verbs, one rule each. One of them subscribes; one of them does not. Which
one is in `build` here, and which one belongs there?

## Why it matters

This is the single most common Riverpod bug, and the worst kind: it fails
silently. `flutter analyze` cannot see it. Only `riverpod_lint` can, which is why
it is worth adding. Get in the habit: **watch in build, read in callbacks.**

---

Solution: `solutions/exercise_11.dart`

## ANSWER

```dart
class BrandTitle extends ConsumerWidget {
  const BrandTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);      // <-- here
    return Text(brand.name);
  }
}
```