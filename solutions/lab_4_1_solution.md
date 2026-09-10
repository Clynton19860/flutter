# LAB 4.1 · Routes and the onboarding guard

go_router replaces `home:`. A redirect forces onboarding once. Submitting a quote pushes to a result screen that reads the id from the path.

**This lab was demonstrated on the projector, not typed.** The full branch is
`lab-4-1-solution` — `git checkout lab-4-1-solution`. The files below are what changed.

> **Note on the file name.** This branch creates
> `lib/core/storage/onboarding_provider.dart`. The Day 4 handbook now tells you to
> create `lib/core/storage/prefs_providers.dart` instead, so that Part 3.1 can
> rewrite two methods in place this afternoon rather than silently relocating the
> class. Either name works for Lab 4.1 on its own — but you must end up with
> `onboardedProvider` declared in **exactly one file**, with `router.dart` and
> `onboarding_screen.dart` both importing that one. Two copies is exercise 17,
> and it loops onboarding forever.

## Files changed

| | File |
|---|---|
| changed | `lib/app.dart` |
| new | `lib/core/routing/router.dart` |
| new | `lib/core/storage/onboarding_provider.dart` |
| new | `lib/features/onboarding/presentation/onboarding_screen.dart` |
| changed | `lib/features/quote/presentation/capture_screen.dart` |
| new | `lib/features/quote/presentation/result_screen.dart` |
| changed | `pubspec.lock` |
| changed | `pubspec.yaml` |
| new | `test/routing_test.dart` |

## `lib/core/routing/router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/core/storage/onboarding_provider.dart';
import 'package:quote_app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';
import 'package:quote_app/features/quote/presentation/result_screen.dart';

/// The router is a Provider so it can watch app state. When `onboarded` flips,
/// Riverpod rebuilds this value and MaterialApp.router picks the new one up.
final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(onboardedProvider);

  return GoRouter(
    initialLocation: '/quote',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !goingToOnboarding) return '/onboarding';
      if (onboarded && goingToOnboarding) return '/quote';
      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/quote',
        builder: (context, state) => const CaptureScreen(),
        routes: [
          // Relative path: 'result/:id' under '/quote' => /quote/result/q-123
          GoRoute(
            path: 'result/:id',
            name: 'result',
            builder: (context, state) =>
                ResultScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
```

## `lib/core/storage/onboarding_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lab 4.1: in memory only. Lab 4.3 changes `build()` to read shared_preferences
/// and `complete()` to write it, and nothing else in the app changes.
class OnboardedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> complete() async {
    state = true; // the router's redirect reacts to this
  }
}

final onboardedProvider =
    NotifierProvider<OnboardedNotifier, bool>(OnboardedNotifier.new);
```

## `lib/features/onboarding/presentation/onboarding_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/storage/onboarding_provider.dart';
import 'package:quote_app/core/theme/brand_provider.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield, size: 72, color: cs.primary),
              const SizedBox(height: 24),
              Text('Welcome to ${brand.name}',
                  style: tt.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Get a motor insurance quote in under a minute. '
                'We only ask for what we need.',
                style: tt.bodyLarge,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(onboardedProvider.notifier).complete(),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## `lib/features/quote/presentation/result_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

/// Takes an id, not a Quote. Ids survive deep links and process death;
/// objects passed through `extra` do not.
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoteProvider);
    final quote = switch (state) {
      QuoteLoaded(:final quote) when quote.id == id => quote,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your quote'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: quote == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 48),
                    const SizedBox(height: 12),
                    Text('Quote not found: $id'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/quote'),
                      child: const Text('Start a new quote'),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [PremiumCard(quote: quote)],
              ),
      ),
    );
  }
}
```

## `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/routing/router.dart';
import 'package:quote_app/core/theme/brand_provider.dart';

class QuoteApp extends ConsumerWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: brand.name,
      theme: brand.toThemeData(Brightness.light),
      darkTheme: brand.toThemeData(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
```

