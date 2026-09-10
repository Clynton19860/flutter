# 17 · Onboarding that never finishes

**Day 4 · Navigation.** Run in your `quote_app`.

Two files, and both compile:

```dart
// lib/core/routing/router.dart
import 'package:quote_app/core/storage/prefs_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(onboardedProvider);      // <-- reads THIS one
  ...
});
```

```dart
// lib/features/onboarding/presentation/onboarding_screen.dart
import 'package:quote_app/core/storage/onboarding_provider.dart';

onPressed: () => ref.read(onboardedProvider.notifier).complete(),  // <-- sets THAT one
```

## What you should see

Onboarding appears. You press **Get started**. It appears again. And again. The
app never reaches `/quote`. No exception, no red screen — just a loop.

## Clue

Both files refer to `onboardedProvider` and both compile. Look at the two import
lines. How many `onboardedProvider` objects actually exist in this app?

## Why it matters

A provider's identity is the top-level `final` that declares it. Two files
declaring the same name are **two different providers**. The redirect watches one
while `complete()` sets the other, so the flag it is watching never changes.

This happens for real when a class is moved between files and one copy is left
behind. Keep `onboardedProvider` declared in exactly one place.

---

Solution: `solutions/exercise_17.dart`

## Answer

```dart
// lib/core/routing/router.dart
import 'package:quote_app/core/storage/prefs_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(onboardedProvider);
  ...
});
```

```dart
// lib/features/onboarding/presentation/onboarding_screen.dart
import 'package:quote_app/core/storage/prefs_providers.dart';

onPressed: () => ref.read(onboardedProvider.notifier).complete(),
```