# 13 · No ProviderScope found

**Day 3 · Riverpod.** Run in your `quote_app`.

```dart
void main() {
  runApp(const QuoteApp());     // <-- here
}

class QuoteApp extends ConsumerWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return MaterialApp(title: brand.name, home: const CaptureScreen());
  }
}
```

## What you should see

A red screen on launch:
`ProviderScope not found. A ProviderScope is required to use providers.`

## Clue

A provider is a global *description*. Where does the actual state get created,
and who owns it?

## Why it matters

Two traps sit behind this one. First, the scope has to wrap the app **once**, at
the root. Second — and this catches people who fix the code correctly — changing
`main()` needs a **hot restart**, not a hot reload. Half the delegates who "fixed
it and it still fails" only reloaded.

---

Solution: `solutions/exercise_13.dart`

## Answer

```dart
void main() {
  runApp(const ProviderScope(child: QuoteApp()));
}

class QuoteApp extends ConsumerWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return MaterialApp(title: brand.name, home: const CaptureScreen());
  }
}
```