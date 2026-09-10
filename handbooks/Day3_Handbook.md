# Flutter Day 3 - Delegate Handbook

**State Management** · MO Integrations · Flutter Mobile Application Development

> **How to use this document.** Open it in VS Code alongside the course so you can copy blocks straight out of it. Every code block is complete as it stands. Windows commands come first because that is what the room runs; macOS follows each one.
>
> **Today's deliverable:** the brand toggle moves into a provider and the callbacks disappear. Then the whole quote flow runs idle, loading, loaded or failed through a notifier, with the service injected and the logic unit tested without ever launching the app.

---

## Part 0 · Where we are

You finished Day 2 with:

| File | What is in it |
|---|---|
| `lib/main.dart` | `runApp(const QuoteApp())` |
| `lib/app.dart` | `QuoteApp`, **Stateful**, holding `_brandKey` and passing `brand` plus `onSwitchBrand` down |
| `lib/core/theme/brand_theme.dart` | `BrandTheme`, the `brands` map |
| `lib/features/quote/domain/quote_model.dart` | `Cover`, `QuoteRequest`, `Quote`, `Money`, `calculatePremium`, **and the sealed `QuoteState` with `QuoteIdle`, `QuoteLoading`, `QuoteLoaded`, `QuoteFailed`** |
| `lib/features/quote/presentation/capture_screen.dart` | `CaptureScreen`, `_BrandHeader`, `PremiumBadge` |
| `lib/features/quote/presentation/capture_form.dart` | `CaptureForm` with validation |

**Important.** `QuoteState` and its four subclasses already exist, in `quote_model.dart`, from Lab 1.2 on Day 1. Today we use them. Do not declare them again in a new file or you will get *"QuoteState is already declared in this scope"*.

**A note on imports.** There is one domain file, `quote_model.dart`. Everything today imports from it:

```dart
import 'package:quote_app/features/quote/domain/quote_model.dart';
```

**Reminder:** Windows PowerShell 5.1 has no `&&`. One command per line.

---

## Part 1 · What kind of state is it?

Three columns. Every decision today is "which column?"

| Kind | Definition | Examples | Where it lives |
|---|---|---|---|
| **Ephemeral** | One widget cares. Nobody else reads it. | Text in a form field, is a card expanded, current tab index, animation progress | `setState` in that widget |
| **App** | Read or changed by more than one widget or screen. | The current brand, the quote result, saved quotes, the signed in user | A provider |
| **Derived** | Computed from other state. Never stored twice. | `BrandTheme` from the brand key, premium from the request | A derived `Provider` |

Two questions decide it:

1. **Would a second screen need this?** If yes, it is app state.
2. **Does it come from other state?** If yes, derive it. Do not store it.

> **Yesterday's brand key is app state that we stored as ephemeral state.** That mismatch is exactly why we had to thread a value and a callback through three widgets. Lab 3.1 fixes it.

`setState` is not the villain. It is correct for ephemeral state and we keep using it inside `CaptureForm` all week.

---

## Part 2 · Why we need more than setState

### 2.1 What breaks

```dart
// Day 2: brand lives in QuoteApp's State and is threaded down by hand
class _QuoteAppState extends State<QuoteApp> {
  String _brandKey = 'alpha';

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: brands[_brandKey]!.toThemeData(Brightness.light),
        home: CaptureScreen(
          brand: brands[_brandKey]!,
          onSwitchBrand: () => setState(
            () => _brandKey = _brandKey == 'alpha' ? 'beta' : 'alpha',
          ),
        ),
      );
}
```

Four problems, and they get worse as the app grows:

1. **It rebuilds the whole subtree.** `setState` at the root rebuilds `MaterialApp` and every screen under it, for a one string change.
2. **Prop drilling.** Add a `SettingsScreen` and a `ResultScreen` that both need the brand, and every widget in between has to forward `brand` and `onSwitchBrand` even though it never uses them.
3. **It cannot be tested** without pumping a widget tree.
4. **It couples UI to logic.** The `State` class ends up holding validation, network calls and persistence.

Coming from React, this is `useState` in `App.js` with props drilled down, right before you reach for Context and then Zustand or Redux. Coming from Angular, it is passing `@Input` and `@Output` through five components instead of injecting a service.

### 2.2 InheritedWidget, the mechanism underneath everything

You already use this every day. `Theme.of(context)`, `MediaQuery.of(context)`, `Navigator.of(context)` and `ScaffoldMessenger.of(context)` are all `InheritedWidget` lookups.

```dart
class BrandScope extends InheritedWidget {
  const BrandScope({super.key, required this.brand, required super.child});
  final BrandTheme brand;

  static BrandTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BrandScope>()!.brand;

  @override
  bool updateShouldNotify(BrandScope old) => old.brand != brand;
}
```

Provide it once near the root:

```dart
BrandScope(brand: brands[_brandKey]!, child: MaterialApp(/* ... */))
```

Read it anywhere below, in constant time:

```dart
final brand = BrandScope.of(context);
```

`dependOnInheritedWidgetOfExactType` registers the caller as a dependent. When `updateShouldNotify` returns true, every dependent rebuilds.

**Now the question that matters: how does the AppBar button change the brand?** It cannot. `InheritedWidget` is read only from below. It has no way to write, no lifecycle, no dependency injection, and no way to test without a widget tree. Every package on the next page exists to add those four things.

You will not build this in a lab. It is understanding, not a pattern we use directly.

### 2.3 ValueNotifier, ChangeNotifier and Provider

You will meet all three in existing codebases and in most Stack Overflow answers, so recognise them.

```dart
// Smallest possible observable
final brandKey = ValueNotifier<String>('alpha');

ValueListenableBuilder<String>(
  valueListenable: brandKey,
  builder: (context, key, _) => Text(brands[key]!.name),
)

brandKey.value = 'beta';
```

```dart
// ChangeNotifier: same idea for an object with several fields
class BrandModel extends ChangeNotifier {
  String _key = 'alpha';
  BrandTheme get brand => brands[_key]!;

  void toggle() {
    _key = _key == 'alpha' ? 'beta' : 'alpha';
    notifyListeners();
  }
}
```

Forget `notifyListeners()` and nothing rebuilds. That is the classic `ChangeNotifier` bug.

The **provider** package puts a `ChangeNotifier` inside an `InheritedWidget`:

```dart
ChangeNotifierProvider(create: (_) => BrandModel(), child: const QuoteApp())

final brand = context.watch<BrandModel>().brand;   // rebuilds on change
context.read<BrandModel>().toggle();               // callbacks, no rebuild
final name = context.select<BrandModel, String>((m) => m.brand.name);
```

It is widely used and perfectly good. We go one step further for three specific reasons:

| Provider | Riverpod |
|---|---|
| Tied to `BuildContext`, so logic is hard to use in services and tests | No `BuildContext` needed |
| `ProviderNotFoundException` at **runtime** if you forget the ancestor | A provider is a global final. It cannot be "not found" |
| Models are mutable, so a missed `notifyListeners` silently does nothing | State is immutable by convention. You assign, and assignment notifies |

If a colleague says "Provider is enough for us", they are often right. For a small app, yes. For a multi brand insurance platform with pricing logic you want to unit test, the testability pays for itself in week two.

---

## READ & BREAK DOWN · 10 min read + 5 min debrief

**Read:** *Simple app state management* — and find the Provider gap.

`docs.flutter.dev/data-and-backend/state-mgmt/simple`

The whole page: "Our example", "Lifting state up", "Accessing the state", "ChangeNotifier", "ChangeNotifierProvider", "Consumer". About ten minutes.

**Answer these as you read.** Write your answers down; two of you present.

1. Where does the doc put the `CartModel`, and why there? Map that to where our brand key should live.
2. What is the difference between `Consumer` and `Provider.of(context, listen: false)`? Which of our two uses — the AppBar toggle, the header rebuild — needs which?
3. The doc says "don't put `ChangeNotifier` in a widget's `build`". What goes wrong if you do?
4. Name one thing the doc does **not** solve that you would need for the insurance app. Hint: testing, services, async.

**Then:** one person answers Q1 and Q2, another Q3 and Q4. The instructor shows the Provider version of the brand toggle for sixty seconds. Then Riverpod, which is the answer to Q4.

---

## Part 3 · Riverpod

### 3.1 Setup

```
flutter pub add flutter_riverpod
```

Optional but recommended lints:

```
flutter pub add --dev riverpod_lint custom_lint
```

Pin the major version in `pubspec.yaml` so the whole team resolves the same API:

```yaml
dependencies:
  flutter_riverpod: ^3.0.0
```

If you added the lints, add this to `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

Current Dart answers that line with `analysis_options_deprecated_plugins`, a **warning, not an error**: *"Support for legacy plugins is deprecated."* The lints still run. Run them with `dart run custom_lint`, which is separate from `flutter analyze`. If you want a spotless `flutter analyze` in the labs, leave the optional lints out.

Then wrap the app **once**, in `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/app.dart';

void main() {
  runApp(const ProviderScope(child: QuoteApp()));
}
```

**Hot restart after this, not hot reload.** `main` changed.

> **"Providers are global variables?"** The provider is a global **description**, like a route definition. The state is created lazily inside `ProviderScope` and can be overridden per scope, which is how tests swap in fakes. Nothing is shared between scopes.

Import `package:flutter_riverpod/flutter_riverpod.dart` in Flutter code. Do not import `package:riverpod` directly.

### 3.2 Provider and Notifier

```dart
// lib/core/theme/brand_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'brand_theme.dart';

class BrandKeyNotifier extends Notifier<String> {
  @override
  String build() => 'alpha';

  void set(String key) => state = key;
  void toggle() => state = state == 'alpha' ? 'beta' : 'alpha';
}

final brandKeyProvider =
    NotifierProvider<BrandKeyNotifier, String>(BrandKeyNotifier.new);

// Derived: recomputes only when brandKeyProvider changes
final brandProvider = Provider<BrandTheme>((ref) {
  final key = ref.watch(brandKeyProvider);
  return brands[key] ?? brands['alpha']!;
});
```

| Type | What it is |
|---|---|
| `Notifier<T>` | A class with `build()` returning the initial state, plus methods that assign `state = ...`. Every assignment notifies watchers |
| `NotifierProvider<N, T>` | Exposes it. `NotifierProvider(N.new)` uses the constructor tear off |
| `Provider<T>` | Read only and computed. Perfect for derived values and for services |

**State is immutable.** Assign a new value, never mutate the old one.

```dart
state = newValue;
state = [...state, item];          // lists
state = state.copyWith(name: 'x'); // objects
```

If you mutate in place and do not reassign, Riverpod sees an equal value and nothing rebuilds. This is the single most common support question in week one.

Coming from Angular, `Notifier` is a service holding a `BehaviorSubject` and `Provider` is a computed observable. Coming from React, `Notifier` is a Zustand store slice.

### 3.3 Consuming

```dart
// lib/app.dart - no State class, no callbacks
class QuoteApp extends ConsumerWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return MaterialApp(
      title: brand.name,
      theme: brand.toThemeData(Brightness.light),
      darkTheme: brand.toThemeData(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const CaptureScreen(),
    );
  }
}
```

`CaptureScreen` now takes nothing. Compare that against yesterday's version.

Three consumer flavours:

```dart
// 1) A whole stateless widget that reads providers
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quoteProvider);
    return Text(state.toString());
  }
}

// 2) Stateful and reads providers. `ref` is a field.
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandProvider);
    return Scaffold(appBar: AppBar(title: Text(brand.name)));
  }
}

// 3) Rebuild only a sub-tree inside a plain widget
Consumer(builder: (context, ref, child) => Text(ref.watch(brandProvider).name))
```

### 3.4 watch, read, listen, select

This is the part everyone gets wrong in week one. Four verbs, one rule each.

```dart
// watch - in build(): subscribe, rebuild when the value changes
final brand = ref.watch(brandProvider);

// read - in callbacks: one-off, no subscription
onPressed: () => ref.read(brandKeyProvider.notifier).toggle()

// listen - in build(), for side effects. Does not rebuild.
ref.listen<QuoteState>(quoteProvider, (prev, next) {
  if (next is QuoteFailed) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.message)),
    );
  }
});

// select - rebuild only when one field changes
final name = ref.watch(brandProvider.select((b) => b.name));
```

| Verb | Where | What it does |
|---|---|---|
| `watch` | `build` only | Subscribes. This is how a widget stays up to date |
| `read` | Callbacks, `initState` | One off read. **Never in build**, because it does not subscribe and the widget silently stops updating |
| `listen` | `build`, before the return | Side effects: snackbars, navigation, analytics |
| `select` | `build` | Narrows the subscription to one field. Use for expensive widgets |

**The bug you will hit today:** someone writes `ref.read(brandProvider)` in `build`, hot reloads, and the header never changes when they toggle. Change it to `watch`.

Never `watch` in a callback. It throws or leaks, and `riverpod_lint` flags it.

### 3.5 Dependency injection: services are providers too

```dart
// lib/features/quote/data/quote_service.dart
import 'package:quote_app/features/quote/domain/quote_model.dart';

abstract interface class QuoteService {
  Future<Quote> getQuote(QuoteRequest request);
}

class FakeQuoteService implements QuoteService {
  @override
  Future<Quote> getQuote(QuoteRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (request.year < 2000) throw Exception('Vehicle too old to insure');
    return Quote(
      id: 'q-${DateTime.now().millisecondsSinceEpoch}',
      premium: calculatePremium(request),
    );
  }
}
```

```dart
// lib/features/quote/presentation/quote_providers.dart
final quoteServiceProvider = Provider<QuoteService>((ref) => FakeQuoteService());
```

The UI never constructs a service. Tomorrow, one line changes and nothing else does:

```dart
final quoteServiceProvider =
    Provider<QuoteService>((ref) => DioQuoteService(ref.watch(dioProvider)));
```

And in a test:

```dart
ProviderScope(
  overrides: [quoteServiceProvider.overrideWithValue(FakeQuoteService())],
  child: const QuoteApp(),
)
```

For the C# and Angular people: **providers are the DI container.** Interface, implementation, registration, override in tests. No reflection, no annotations, checked at compile time.

---

## LAB 3.1 · Brand toggle to a provider · 35 min

**Goal:** the brand key lives in a `NotifierProvider`. `QuoteApp` and `CaptureScreen` have no brand parameters and no callbacks. The toggle still works.

### Steps

1. `flutter pub add flutter_riverpod`, then pin `^3.0.0` in `pubspec.yaml`.
2. `main.dart`: wrap in `ProviderScope`.
3. Create `lib/core/theme/brand_provider.dart` from Part 3.2.
4. `QuoteApp` becomes a `ConsumerWidget`. Theme and title come from `ref.watch(brandProvider)`. `home: const CaptureScreen()`.
5. `CaptureScreen` becomes a `ConsumerStatefulWidget`. Remove the `brand` and `onSwitchBrand` parameters. AppBar title from `ref.watch(brandProvider).name`, toggle via `ref.read(brandKeyProvider.notifier).toggle()`.
6. `_BrandHeader` becomes a `ConsumerWidget` and reads the brand itself.
7. **Hot restart** (main changed). Toggle should work.
8. Deliberately change one `watch` to `read`, toggle, watch nothing happen, change it back.
9. Add a third brand to the `brands` map and confirm you change no widget file.
10. `flutter analyze` clean, then commit.

### Solution: `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';

class QuoteApp extends ConsumerWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    return MaterialApp(
      title: brand.name,
      theme: brand.toThemeData(Brightness.light),
      darkTheme: brand.toThemeData(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const CaptureScreen(),
    );
  }
}
```

### Solution: the changed parts of `capture_screen.dart`

```dart
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(brand.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Switch brand',
            onPressed: () => ref.read(brandKeyProvider.notifier).toggle(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            const header = _BrandHeader();
            // rest of yesterday's LayoutBuilder, unchanged
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
```

Keep yesterday's `LayoutBuilder` body. The only changes are the class type, the removed parameters, and where `brand` comes from.

### Solution: `_BrandHeader`

Step 6 removes its parameters too. It reads the brand itself, so nothing has to be handed down to it:

```dart
class _BrandHeader extends ConsumerWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = ref.watch(brandProvider);
    // yesterday's Stack body, with brand.name and brand.logoAsset
    return Text(brand.name);
  }
}
```

That is the whole point of the lab: `CaptureScreen` no longer passes `name` and `logoAsset` down, because the header can reach the provider directly.

### Step 10 commands

```
flutter analyze
```

```
git add .
```

```
git commit -m "Day 3: brand provider"
```

### Stretch

- Use `select` so `_BrandHeader` rebuilds only when the brand **name** changes.
- Add a `ProviderObserver` that prints every brand change (Part 6.3).

---

## Part 4 · Async state

### 4.1 A Notifier for the quote flow

`QuoteState` is already in `quote_model.dart` from Day 1. We only add the notifier.

```dart
// lib/features/quote/presentation/quote_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

final quoteServiceProvider = Provider<QuoteService>((ref) => FakeQuoteService());

class QuoteNotifier extends Notifier<QuoteState> {
  @override
  QuoteState build() => const QuoteIdle();

  Future<void> submit(QuoteRequest request) async {
    state = const QuoteLoading();
    try {
      final quote = await ref.read(quoteServiceProvider).getQuote(request);
      state = QuoteLoaded(quote);
    } catch (e) {
      state = QuoteFailed(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void reset() => state = const QuoteIdle();
}

final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(QuoteNotifier.new);
```

Three things to notice:

1. **The UI never sees an exception.** The notifier catches it and turns it into `QuoteFailed` with a message.
2. `Exception.toString()` gives `"Exception: Vehicle too old to insure"`. The `replaceFirst` strips the prefix so the message reads properly on screen. Tomorrow, with dio, we map `DioException` to friendlier text.
3. **This file does not import `package:flutter/material.dart`.** That is the boundary. If your notifier imports widgets, UI has leaked into your logic.

### 4.2 Rendering it

```dart
@override
Widget build(BuildContext context) {
  final state = ref.watch(quoteProvider);

  ref.listen(quoteProvider, (prev, next) {
    if (next is QuoteFailed) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(next.message)));
    }
  });

  return Scaffold(
    appBar: AppBar(title: Text(ref.watch(brandProvider).name)),
    body: Column(children: [
      CaptureForm(
        enabled: state is! QuoteLoading,
        onSubmit: (r) => ref.read(quoteProvider.notifier).submit(r),
      ),
      const SizedBox(height: 16),
      switch (state) {
        QuoteIdle() => const Text('Fill in the form to get a quote'),
        QuoteLoading() => const CircularProgressIndicator(),
        QuoteLoaded(:final quote) => PremiumCard(quote: quote),
        QuoteFailed(:final message) => Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      },
    ]),
  );
}
```

The `switch` expression is **exhaustive**. Add a fifth state to the sealed class tomorrow and this stops compiling until you handle it. That is the feature, not a bug.

`ref.listen` goes at the top of `build`, before the return. It is a side effect, so it must not be part of the returned widget tree. Put it inside a nested builder and your SnackBar fires twice.

### 4.3 AsyncNotifier, AsyncValue and FutureProvider

Sometimes the state **is** the async value, with no extra domain meaning. Then let Riverpod model loading and error for you.

```dart
class SavedQuotesNotifier extends AsyncNotifier<List<Quote>> {
  @override
  Future<List<Quote>> build() async {
    return ref.read(quoteRepositoryProvider).loadAll();
  }

  Future<void> add(Quote q) async {
    final repo = ref.read(quoteRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repo.save(q);
      return repo.loadAll();
    });
  }
}

final savedQuotesProvider =
    AsyncNotifierProvider<SavedQuotesNotifier, List<Quote>>(SavedQuotesNotifier.new);
```

```dart
ref.watch(savedQuotesProvider).when(
  data: (quotes) => SavedQuotesList(quotes: quotes, onDelete: (_) {}),
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, st) => Text('Could not load: $e'),
)
```

```dart
// Read-only async, for config and lookup lists
final makesProvider =
    FutureProvider<List<String>>((ref) async => ['Toyota', 'VW', 'BMW']);
```

`AsyncValue.guard` catches exceptions into `AsyncError`, so the notifier never throws.

**How to choose:**

| Use | When |
|---|---|
| A sealed state with `Notifier` | The state has domain meaning beyond loading, data and error. Ours has `Idle` |
| `AsyncNotifier` | The state **is** the async value. Tomorrow's saved quotes list from SQLite |
| `FutureProvider` | Read only async, cached. `ref.invalidate` to refetch |

`quoteRepositoryProvider` does not exist yet. Day 4 creates it. The code above is for reading today, not typing.

### 4.4 family, autoDispose, keepAlive

Reference level. The stretch lane uses it.

```dart
// A provider per argument. Riverpod 3: the argument is a constructor parameter.
class QuoteByIdNotifier extends AsyncNotifier<Quote> {
  QuoteByIdNotifier(this.id);
  final String id;

  @override
  Future<Quote> build() => ref.read(quoteRepositoryProvider).byId(id);
}

final quoteByIdProvider =
    AsyncNotifierProvider.family<QuoteByIdNotifier, Quote, String>(
  QuoteByIdNotifier.new,
);

ref.watch(quoteByIdProvider('q-123'));
```

```dart
// Dispose state when the last watcher goes away
final searchProvider = Provider.autoDispose<String>((ref) {
  ref.onDispose(() => debugPrint('search disposed'));
  return '';
});

// Keep a specific instance alive after it loads successfully
final cachedProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  ref.keepAlive();
  return fetchMakes();
});
```

By default providers are kept alive. Make detail screen and search providers `autoDispose` so you do not grow stale caches.

**If you find a 2.x tutorial online**, the old family signature was `build(String id)` with an `AutoDisposeFamilyNotifier` class. Those classes are gone in Riverpod 3.

### 4.5 Riverpod 3 behaviours worth knowing

```dart
// 1) Failures are wrapped. ProviderException is NOT in the main barrel:
import 'package:flutter_riverpod/misc.dart';

try {
  ref.read(quoteProvider);
} on ProviderException catch (e) {
  print(e.exception);
}

// 2) Automatic retry of failed providers is ON by default, with back-off.
//    Turn it off while learning so errors show immediately.
ProviderScope(retry: (retryCount, error) => null, child: const QuoteApp())

// 3) Legacy providers moved
import 'package:flutter_riverpod/legacy.dart';   // StateProvider, ChangeNotifierProvider
```

4. **Updates are filtered with `==`.** Two equal states do not rebuild. Override `==` and `hashCode`, or use records, or use freezed.
5. **`Ref` has no type parameter** any more. A tutorial using `ProviderRef<T>` is 2.x.

The retry behaviour is the one that catches people in a demo. Our sealed notifier catches its own exceptions so it is unaffected, but an `AsyncNotifier` whose `build()` throws **is** retried, which looks like the app calling your API in a loop.

---

## Part 5 · Bloc awareness

You are not building this today. You need to read it fluently, because some of you will join Bloc codebases.

```dart
// Cubit: the same shape as our Notifier
class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit(this._service) : super(const QuoteIdle());
  final QuoteService _service;

  Future<void> submit(QuoteRequest r) async {
    emit(const QuoteLoading());
    try {
      emit(QuoteLoaded(await _service.getQuote(r)));
    } catch (e) {
      emit(QuoteFailed(e.toString()));
    }
  }
}
```

```dart
// Bloc: events in, states out
sealed class QuoteEvent {}

class QuoteRequested extends QuoteEvent {
  QuoteRequested(this.request);
  final QuoteRequest request;
}

class QuoteBloc extends Bloc<QuoteEvent, QuoteState> {
  QuoteBloc(this._service) : super(const QuoteIdle()) {
    on<QuoteRequested>(_onRequested);
  }
  final QuoteService _service;

  Future<void> _onRequested(QuoteRequested e, Emitter<QuoteState> emit) async {
    emit(const QuoteLoading());
    try {
      emit(QuoteLoaded(await _service.getQuote(e.request)));
    } catch (err) {
      emit(QuoteFailed(err.toString()));
    }
  }
}

// UI
context.read<QuoteBloc>().add(QuoteRequested(r));
```

Same sealed `QuoteState`, same service interface. **`Cubit.emit` is `Notifier.state =`.** Bloc adds an event type on top, plus an observer hook and stream transformers.

### The honest comparison

| | Riverpod (our pattern) | Bloc / Cubit |
|---|---|---|
| Mental model | Providers and notifiers, DI built in | Events to states, DI via `BlocProvider` |
| Boilerplate | Low | Medium for Cubit, higher for Bloc events |
| Auditability | `ProviderObserver` logs state changes | `BlocObserver` logs **events and** transitions |
| Testing | `ProviderContainer`, no widgets | `bloc_test` package, no widgets |
| Compile time safety | Providers cannot be "not found" | `BlocProvider` lookups can fail at runtime |
| Async modelling | `AsyncValue` built in | You model loading and error yourself |
| Ecosystem | `riverpod_generator`, `riverpod_lint` | `hydrated_bloc`, `replay_bloc`, `bloc_concurrency` |
| Pick it when | Small to medium teams, lots of derived and async state | Large teams, regulated domains wanting explicit event logs, an existing Bloc codebase |

Both are production grade. **Consistency across your codebase matters more than the choice.** The one concrete reason to pick Bloc for an insurer is a compliance requirement for an event level audit trail, because `BlocObserver` sees the event that caused each transition and `ProviderObserver` only sees the transition.

---

## READ & BREAK DOWN · 12 min read + 8 min debrief

**Read:** *Bloc core concepts* — then argue for it against Riverpod.

`bloclibrary.dev/bloc-concepts`

The sections "Streams", "Cubit", "Bloc", "Cubit vs Bloc" and "BlocObserver". About twelve minutes. Then skim `bloclibrary.dev/architecture`.

**Answer these as you read.**

1. In one sentence each: what is a Cubit, what is a Bloc, and what does a Bloc have that a Cubit does not?
2. What does `BlocObserver` give you, and why might an insurance product owner care?
3. The docs recommend a three layer architecture. Map our feature-first folders onto it.
4. Make the case **for** Bloc over Riverpod for this app in three bullets — even if you disagree.

**Then:** two volunteers debate, one for Bloc and one for Riverpod, ninety seconds each. The room votes. The comparison table above is the instructor's position, not the debate's.

---

## LAB 3.2 · Quote flow with Riverpod · 60 min

**Goal:** submitting the form shows a spinner, then a premium card or an error SnackBar, driven by `QuoteNotifier` and an injected `FakeQuoteService`. One test passes with no emulator.

**Everyone must reach step 5.** Steps 6 to 8 are the quality bar.

### Steps

1. Create `lib/features/quote/data/quote_service.dart` from Part 3.5.
2. Create `lib/features/quote/presentation/quote_providers.dart` from Part 4.1. **Do not redeclare `QuoteState`.** Import it from `quote_model.dart`.
3. Create `lib/features/quote/presentation/premium_card.dart` (code below).
4. Give `CaptureForm` an `enabled` flag so the button disables and shows a spinner while loading (code below).
5. In `CaptureScreen`: watch `quoteProvider`, render the switch, add `ref.listen` for the SnackBar, and submit via `ref.read(quoteProvider.notifier).submit(r)`.
6. Test three paths on the emulator: a valid year shows the card, year 1998 shows the error, a rapid double tap does nothing because the button is disabled.
7. Write `test/quote_notifier_test.dart` (code below) and run it.
8. `flutter analyze` clean, then commit.

### `premium_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key, required this.quote});
  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your monthly premium',
                style: tt.labelLarge?.copyWith(color: cs.onPrimaryContainer)),
            const SizedBox(height: 8),
            Text(quote.display,
                style: tt.displaySmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 4),
            Text('Quote ref ${quote.id}',
                style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer)),
          ],
        ),
      ),
    );
  }
}
```

### The `enabled` flag on `CaptureForm`

Change the constructor:

```dart
class CaptureForm extends StatefulWidget {
  const CaptureForm({super.key, required this.onSubmit, this.enabled = true});
  final void Function(QuoteRequest) onSubmit;
  final bool enabled;
```

And the submit button inside `_fields`:

```dart
FilledButton.icon(
  onPressed: widget.enabled ? _submit : null,
  icon: widget.enabled
      ? const Icon(Icons.calculate)
      : const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
  label: Text(widget.enabled ? 'Get quote' : 'Calculating...'),
)
```

`onPressed: null` is what disables a button in Flutter. It greys out on its own.

### `test/quote_notifier_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/features/quote/data/quote_service.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';

void main() {
  test('submit moves idle to loading to loaded', () async {
    final container = ProviderContainer(
      overrides: [quoteServiceProvider.overrideWithValue(FakeQuoteService())],
    );
    addTearDown(container.dispose);

    final states = <QuoteState>[];
    container.listen(quoteProvider, (_, next) => states.add(next),
        fireImmediately: true);

    await container.read(quoteProvider.notifier).submit(
          const QuoteRequest(
            make: 'VW',
            year: 2020,
            driverAge: 30,
            cover: Cover.comprehensive,
          ),
        );

    expect(states.map((s) => s.runtimeType),
        [QuoteIdle, QuoteLoading, QuoteLoaded]);
  });
}
```

Run it:

```
flutter test test/quote_notifier_test.dart
```

`addTearDown(container.dispose)` is not optional. Without it the providers leak across tests.

`fireImmediately: true` captures the initial `Idle` state so the sequence assertion includes it.

**This one test is the argument for the whole architecture.** The pricing flow of an insurance app, verified in under two seconds, with no emulator, no widget tree and no network.

### Imports for `capture_screen.dart` after this lab

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quote_app/core/theme/brand_provider.dart';
import 'package:quote_app/core/theme/brand_theme.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';
import 'package:quote_app/features/quote/presentation/capture_form.dart';
import 'package:quote_app/features/quote/presentation/premium_card.dart';
import 'package:quote_app/features/quote/presentation/quote_providers.dart';
```

### Step 8 commands

```
flutter analyze
```

```
git add .
```

```
git commit -m "Day 3: quote flow"
```

### Stretch

- Wire `QuoteNotifier.reset()` to a "New quote" button that also resets the form via the form key.
- Add a `ProviderObserver` (Part 6.3), name your providers, and watch the log during a submit.

---

## Part 6 · Reference

### 6.1 The dependency direction

```
CaptureForm   ->  knows nothing about Riverpod. Validates and calls onSubmit.
CaptureScreen ->  watches quoteProvider, listens for failures, calls submit.
QuoteNotifier ->  Loading, await service, Loaded or Failed. No Flutter imports.
QuoteService  ->  interface plus FakeQuoteService. Day 4 swaps in dio.
```

Dependencies point one way: widgets to providers to services. **The notifier file must never import `package:flutter/material.dart`.** If it does, you have leaked UI into logic and you have lost the fast tests.

### 6.2 Which provider do I use?

| You have | Use |
|---|---|
| A value computed from other providers | `Provider` |
| A service or repository | `Provider` returning the interface type |
| State with methods that change it | `Notifier` plus `NotifierProvider` |
| Async state that is just data, loading or error | `AsyncNotifier` plus `AsyncNotifierProvider` |
| Read only async data | `FutureProvider` |
| A stream | `StreamProvider` |
| One provider instance per argument | `.family` |
| State that should die with the screen | `.autoDispose` |

### 6.3 ProviderObserver

```dart
// `ProviderObserver` is a base class in Riverpod 3, so yours must be `base`.
// The parameter names must be `previousValue` and `newValue` or the analyser
// reports avoid_renaming_method_parameters.
base class AppProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
      ProviderObserverContext context, Object? previousValue, Object? newValue) {
    debugPrint(
        '${context.provider.name ?? context.provider.runtimeType}: '
        '$previousValue to $newValue');
  }
}

runApp(ProviderScope(
  observers: [AppProviderObserver()],
  child: const QuoteApp(),
));
```

Name your providers so the log is readable:

```dart
final quoteProvider = NotifierProvider<QuoteNotifier, QuoteState>(
  QuoteNotifier.new,
  name: 'quote',
);
```

### 6.4 Coming from another stack

| You know | Riverpod equivalent |
|---|---|
| Angular service with `BehaviorSubject` | `Notifier` |
| Angular computed observable | `Provider` that watches other providers |
| Angular DI token and `providers: []` | A provider plus `overrides` in a scope |
| C# interface registered in the DI container | `Provider<IService>` returning the implementation |
| React `useState` | `setState`, for ephemeral state |
| React Context | `InheritedWidget` |
| Zustand store slice | `Notifier` |
| React Query | `FutureProvider` and `AsyncNotifier` |
| Redux `useSelector` | `ref.watch(provider.select(...))` |

---

## Part 7 · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| "No ProviderScope found" | `main` not wrapped, or hot reload after changing `main` | Wrap `runApp` in `ProviderScope`, then hot **restart** |
| Widget never updates after the toggle | `ref.read` in `build` | Use `ref.watch` in `build` |
| "Undefined name 'ref'" | Still a `StatelessWidget` or a plain `State` | `ConsumerWidget`, or `ConsumerStatefulWidget` plus `ConsumerState` |
| "The argument type 'WidgetRef' can't be assigned" | Same cause | Same fix |
| "QuoteState is already declared" | You redeclared the sealed state | Delete it, import `quote_model.dart` |
| "The switch expression isn't exhaustive" | A sealed subtype is unhandled | Add the case. This is the feature working |
| Spinner never stops | An exception escaped the `try` | Await **inside** the try; the catch sets `QuoteFailed` |
| State assigned but nothing rebuilds | Mutated in place, or the new value is `==` the old one | Assign a new object. Override `==` or use `copyWith` |
| A `FutureProvider` re-runs after an error | Riverpod 3 automatic retry | `ProviderScope(retry: (c, e) => null)` while learning |
| "StateProvider isn't defined" | Moved in Riverpod 3 | `import 'package:flutter_riverpod/legacy.dart';` or use a `Notifier` |
| `build(String id)` will not compile | 2.x family signature | Riverpod 3 puts the argument on the constructor |
| SnackBar shows twice | `ref.listen` inside a nested builder | Call it once at the top of `build` |
| Test: "A ProviderContainer was not disposed" | Missing tear down | `addTearDown(container.dispose)` |
| "No tests ran" | Wrong file name or location | File must end in `_test.dart` and live under `test/` |
| `flutter pub add` fails | Venue network | Ask the instructor. The package is already listed in `pubspec.yaml` on the course repo |

---

## Part 8 · Homework for Day 4

Day 4 is navigation, APIs and local storage. Navigation scored unevenly in the survey, so this reading levels the room.

Read:

1. [pub.dev/packages/go_router](https://pub.dev/packages/go_router) - the README "Getting started"
2. The package docs linked at the top of that README: **Redirection**, **Parameters**, **Navigation**

About 20 minutes. Come with an answer to these four:

1. What is the difference between `context.go()` and `context.push()`? Give one use of each in our app.
2. How does go_router express a path parameter, and how do you read it in the builder?
3. What is `redirect` for, and how would you implement "must complete onboarding first"?
4. What is a `ShellRoute` or `StatefulShellRoute`, and which of our screens would live inside one?

Two of you present at 09:00. We then add routing to the app live, from your answers.

---

## Links from today

| Topic | Link |
|---|---|
| State management overview | docs.flutter.dev/data-and-backend/state-mgmt/intro |
| Simple app state management | docs.flutter.dev/data-and-backend/state-mgmt/simple |
| Options compared | docs.flutter.dev/data-and-backend/state-mgmt/options |
| InheritedWidget | api.flutter.dev/flutter/widgets/InheritedWidget-class.html |
| Why Riverpod | riverpod.dev/docs/from_provider/motivation |
| Riverpod getting started | riverpod.dev/docs/introduction/getting_started |
| Riverpod 3 migration | riverpod.dev/docs/3.0_migration |
| Riverpod testing | riverpod.dev/docs/how_to/testing |
| Riverpod retry (Part 4.5) | riverpod.dev/docs/concepts2/retry |
| riverpod_lint | pub.dev/packages/riverpod_lint |
| Bloc concepts | bloclibrary.dev/bloc-concepts |
| Bloc architecture | bloclibrary.dev/architecture |
| Provider package | pub.dev/packages/provider |
| Homework | pub.dev/packages/go_router |
| Course repo | github.com/Clynton19860/flutter |

---

*MO Integrations · Flutter Mobile Application Development · Day 3*
