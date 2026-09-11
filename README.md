# MO Integrations · Flutter Mobile Application Development

Five-day technical training. Delegate handbooks, slides, exercises and the
lab application.

## What is where

| Folder | What's in it |
|---|---|
| `handbooks/` | `Day1`–`Day5_Handbook.md`. The delegate handbook for each day. Open alongside the course and copy code straight out. |
| `slides/` | The presenter deck for each day, `Day1`–`Day5`. Speaker notes are in each deck. |
| `exercises/` | Eighteen find-the-bug exercises. 1–10 run in DartPad; 11–18 run in the app. |
| `solutions/` | Worked answers to all eighteen exercises, plus the labs that were demonstrated rather than typed (1.2, 2.1, 3.1, 4.1, 4.2). Try it yourself first — then check. |
| `dartpad/` | Ready-to-paste DartPad files for the Day 1 labs. |
| `setup/` | `START_HERE` install guides and the VS Code config. Do this before Day 1. |
| `handouts-pdf/` | PDF exports for printing and emailing. |
| `full-flutter-and-dart-training/` | A separate, longer course: **Flutter for Java Developers**, 8 days. Its own handbooks and decks, four days of Dart before any Flutter. Not part of the 5-day programme above. |

## The lab app

The app is **not in this branch.** It lives on the `lab-*` branches:

```
lab-3-start        End of Day 2. Where delegates begin Day 3.
lab-3-1-solution   Brand toggle moved to a Riverpod provider.
lab-3-2-solution   Quote flow through QuoteNotifier, idle/loading/loaded/failed.
lab-4-1-solution   go_router, onboarding guard, result screen.
lab-4-2-solution   Real quote API with dio.
lab-4-3-solution   Onboarding to capture to API to result to saved. End of Day 4.
```

Work on the app in a **separate clone**, so switching branches never fights
the materials:

```
git clone <this repo> flutter-labs
cd flutter-labs
git checkout lab-3-start
cd quote_app && flutter pub get && flutter run
```

Keep this clone on the materials branches (`main`, `day*-materials`) and the
other one on `lab-*`. `quote_app/` is gitignored here for that reason.

## Running the app

```
cd quote_app
flutter pub get
flutter run
flutter analyze
flutter test
```

**5.** Open `lib/main.dart`, change the AppBar title text, save, then press **`r`** in the terminal. The title changes and the counter keeps its value. That is **hot reload**.

**6.** Press **`R`** (capital). The app restarts and the counter resets to 0. That is **hot restart**.

**7.** Press **`q`** to quit. Then open the folder in VS Code and press **F5** to run under the debugger.

```powershell
# 8. Commit
git init
git add .
git commit -m "Day 1: template app"
```

### Hot reload keys (in the `flutter run` terminal)

| Key | Does |
|---|---|
| `r` | Hot reload: inject changed code, **keep** state |
| `R` | Hot restart: re-run `main()`, **lose** state |
| `p` | Toggle debug paint (draws boxes round every widget) |
| `o` | Toggle Android / iOS rendering |
| `q` | Quit |

Hot reload does **not** pick up changes to `main()`, global initialisers, enum values, or `const` values. Press `R` for those. If you add a package with native code, stop and `flutter run` again.

**Stretch:** run it in the browser with `flutter run -d chrome`, and open `android/app/build.gradle.kts` to find `applicationId`: we change that on Day 5.

---

## Part 6 · Dart primer: copy along in DartPad

Open **https://dartpad.dev** → New Pad → Dart. Paste any block below into the pad (replacing what is there) and press Run.

### Variables

```dart
void main() {
  var count = 0;              // int, inferred, reassignable
  count = 5;
  // count = 'five';          // compile error: String is not int

  final createdAt = DateTime.now();   // set once, at runtime  (= JS const). Use case: API responses, database queries, current timestamps.
  const vatRate = 0.15;               // compile-time constant. Use case: Hardcoded strings, colors, static widgets.
  const brand = 'Alpha Insure';

  double premium = 1450.0;            // explicit type where it helps the reader
  List<String> makes = ['Toyota', 'VW'];

  print('$brand $count $createdAt $vatRate $premium $makes');
}
```

### Null safety

```dart
void main() {
  String name = 'Sive';
  // name = null;               // compile error

  String? nickname;             // may be null
  print(nickname?.length);      // null
  print(nickname ?? 'none');    // 'none'
  nickname ??= 'S';             // assign only if null
  print(nickname!.length);      // ! = "trust me, not null", throws if wrong

  String? maybe = DateTime.now().hour > 0 ? 'value' : null;
  if (maybe != null) {
    print(maybe.length);        // promoted to String inside the if
  }
}
```

**Fields do not promote.** This is the one that catches everybody:

```dart
class Driver {
  String? nickname;

  void greet() {
    // if (nickname != null) print(nickname.length);  // ERROR on a field
    final n = nickname;                               // copy to a local
    if (n != null) print(n.length);                   // now it promotes
    print(nickname?.length ?? 0);                     // or just be null-aware
  }
}

void main() => Driver()..nickname = 'Sive'..greet();
```

### Functions

```dart
double premium(double base, {required int age, bool comprehensive = true}) {
  final loading = age < 25 ? 1.5 : 1.0;
  return comprehensive ? base * 1.4 * loading : base * loading;
}

void main() {
  print(premium(1000, age: 34));                        // 1400.0
  print(premium(1000, age: 22, comprehensive: false));   // 1500.0

  final int Function(int) twice = (x) => x * 2;
  print(twice(21));
}
```

Named parameters in `{}` are how every widget constructor works. `required` makes one mandatory.

### Classes

```dart
class Quote {
  final String id;
  final double premium;
  final String currency;

  const Quote({required this.id, required this.premium, this.currency = 'ZAR'});

  String get display => '$currency ${premium.toStringAsFixed(2)}';

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
        id: j['id'] as String,
        premium: (j['premium'] as num).toDouble(),
        currency: j['currency'] as String? ?? 'ZAR',
      );

  Map<String, dynamic> toJson() => {'id': id, 'premium': premium, 'currency': currency};
}

void main() {
  const q = Quote(id: 'q1', premium: 1450);
  print(q.display);
  print(q.toJson());
  print(Quote.fromJson({'id': 'q2', 'premium': 900}).display);
}
```

### Collections

```dart
void main() {
  final makes = <String>['Toyota', 'VW', 'BMW'];
  final byMake = {'VW': 1200.0, 'BMW': 2100.0};
  const showLuxury = true;

  final list = [
    'Toyota',
    if (showLuxury) 'BMW',                       // collection-if
    for (final m in makes) m.toUpperCase(),      // collection-for
    ...makes,                                    // spread
  ];
  print(list);

  final cheap = byMake.entries
      .where((e) => e.value < 2000)
      .map((e) => e.key)
      .toList();                                 // <-- .toList() matters
  print(cheap);

  print(byMake.values.fold<double>(0.0, (a, b) => a + b));
}
```

`map()` and `where()` return a lazy `Iterable`. Call `.toList()` when you need a `List`: forgetting it is the number one beginner error.

### Switch expressions and sealed classes

```dart
enum Cover { thirdParty, thirdPartyFireTheft, comprehensive }

double factor(Cover c) => switch (c) {
      Cover.thirdParty => 0.6,
      Cover.thirdPartyFireTheft => 0.8,
      Cover.comprehensive => 1.0,
    };

String band(int age) => switch (age) {
      < 18 => 'not eligible',
      >= 18 && < 25 => 'young driver',
      _ => 'standard',
    };

void main() {
  for (final c in Cover.values) {
    print('$c → ${factor(c)}');
  }
  print(band(22));
}
```

### Async

```dart
Future<String> fetchQuote(String id) async {
  await Future.delayed(const Duration(milliseconds: 500));
  if (id.isEmpty) throw Exception('no id');
  return 'quote-$id';
}

Stream<int> countdown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield i;
  }
}

void main() async {
  try {
    print(await fetchQuote('q1'));
  } catch (e, st) {
    print('$e\n$st');
  }

  await for (final n in countdown(3)) {
    print(n);
  }

  final sw = Stopwatch()..start();
  await Future.wait([fetchQuote('a'), fetchQuote('b'), fetchQuote('c')]);
  print('3 in parallel took ${sw.elapsedMilliseconds} ms');   // ~500, not 1500
}
```

`Future` = Promise / `Task<T>`. `Stream` = Observable / `IAsyncEnumerable<T>`.

### Mixins and extensions

```dart
mixin Loggable {
  void log(String m) => print('[$runtimeType] $m');
}

extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
}

class QuoteService with Loggable {
  void quote() => log('quoting…');
}

void main() {
  QuoteService().quote();
  print(1450.0.rands);          // R 1450.00
}
```

---

## LAB 1.2 · Quote domain model · 35 min

**Goal:** a null-safe, immutable domain model, exercised from `main()`. Runs entirely in **dartpad.dev**: no SDK needed.

### Starter: paste this into DartPad and fill in the TODOs

```dart
// ---------- 1. Cover ----------
enum Cover {
  thirdParty, thirdPartyFireTheft, comprehensive;

  // TODO: double get factor => switch (this) { ... 0.6 / 0.8 / 1.0 ... };
}

// ---------- 2. QuoteRequest ----------
// TODO: fields make (String), model (String?), year (int), driverAge (int), cover (Cover)
//       const constructor with required named params
//       copyWith

// ---------- 3. Quote ----------
// TODO: id (String), premium (double), currency defaulting to 'ZAR'
//       a `display` getter, fromJson / toJson

// ---------- 4. Premium calculation ----------
// TODO: double calculatePremium(QuoteRequest r)
//       base 1000; x1.5 if driverAge < 25; x1.2 if year < 2015; x cover.factor
//       round to 2 decimals

// ---------- 5. Sealed state ----------
// TODO: sealed class QuoteState with Idle / Loading / Loaded(quote) / Failed(message)
//       String describe(QuoteState s) using an exhaustive switch expression

void main() {
  // TODO: build three requests with copyWith, print each premium
  // TODO: print describe() for all four states
}
```

### Solution

Published after the lab, in `solutions/lab_1_2_solution.dart`.

Work from the starter above. If you get stuck for more than a few minutes,
ask - that is what the 35 minutes and the instructor in the room are for.


**Expected output**

```
VW 2020 → R 1000.00
VW 2020 → R 1500.00
VW 2012 → R 720.00
Fill in the form
Calculating…
Premium ZAR 1000.00
Error: too old
```

**Stretch**
1. Prove `r1.copyWith() == r1` now that `==` is overridden.
2. Add `QuoteExpired` to the sealed class and watch `describe()` refuse to compile until you handle it. That is the whole point of sealed classes.
3. Use the `Money` extension inside `Quote.display`.

**Keep this pad open**: Lab 1.3 builds on it.

---

## LAB 1.3 · Async quote service · 25 min

**Goal:** a fake service with realistic latency, failure, timeout, and a `Stream` of states.

Add `import 'dart:async';` at the top of your Lab 1.2 pad (needed for `TimeoutException`), then add the code below and replace `main()`.

```dart
import 'dart:async';

// ... keep everything from Lab 1.2 above this line ...

abstract interface class QuoteService {
  Future<Quote> getQuote(QuoteRequest r);
}

class FakeQuoteService implements QuoteService {
  @override
  Future<Quote> getQuote(QuoteRequest r) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (r.year < 2000) throw Exception('Vehicle too old to insure');
    return Quote(id: 'q-${r.hashCode}', premium: calculatePremium(r));
  }
}

Future<void> runOnce(QuoteService s, QuoteRequest r) async {
  try {
    final q = await s.getQuote(r).timeout(const Duration(seconds: 3));
    print('OK ${q.display}');
  } on TimeoutException {
    print('Timed out');
  } catch (e) {
    print('Failed: $e');
  }
}

Stream<QuoteState> quoteStates(QuoteService s, QuoteRequest r) async* {
  yield const QuoteLoading();
  try {
    yield QuoteLoaded(await s.getQuote(r));
  } catch (e) {
    yield QuoteFailed(e.toString());
  }
}

void main() async {
  final svc = FakeQuoteService();
  const ok = QuoteRequest(make: 'VW', year: 2020, driverAge: 30, cover: Cover.comprehensive);

  await runOnce(svc, ok);

  await for (final st in quoteStates(svc, ok)) {
    print(describe(st));
  }
  await for (final st in quoteStates(svc, ok.copyWith(year: 1998))) {
    print(describe(st));
  }

  final sw = Stopwatch()..start();
  await Future.wait([svc.getQuote(ok), svc.getQuote(ok), svc.getQuote(ok)]);
  print('3 parallel quotes in ${sw.elapsedMilliseconds} ms');   // ~1500, not 4500
}
```

The last line is the point of `Future.wait`: three 1.5-second calls finish in about 1.5 seconds, not 4.5.

**Stretch**
1. Make `FakeQuoteService` fail randomly 30% of the time and add one retry with back-off.
2. Add `.distinct()` to the state stream and see what changes.

---

## LAB 1.4 · Quote app skeleton · 40 min

**Goal:** the app runs on your emulator with the Lab 1.2 model inside it and one stateful screen.

### 1. Folder structure

```powershell
# from inside quote_app
mkdir lib\core\theme, lib\core\routing, lib\core\network, lib\core\widgets
mkdir lib\features\onboarding\presentation
mkdir lib\features\quote\domain, lib\features\quote\data, lib\features\quote\presentation
```

```bash
# macOS / Linux
mkdir -p lib/core/{theme,routing,network,widgets}
mkdir -p lib/features/onboarding/presentation
mkdir -p lib/features/quote/{domain,data,presentation}
```

### 2. `lib/features/quote/domain/quote_model.dart`

Paste your **entire Lab 1.2 solution** into this file, then delete its `main()`. Add this import at the top. Nothing else is needed:

```dart
// lib/features/quote/domain/quote_model.dart
// (paste the Lab 1.2 solution here, minus main())
```

### 3. `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:quote_app/app.dart';

void main() => runApp(const QuoteApp());
```

### 4. `lib/app.dart`

```dart
import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/presentation/capture_screen.dart';

class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Quote App',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF0B2545),
          useMaterial3: true,
        ),
        home: const CaptureScreen(),
      );
}
```

### 5. `lib/features/quote/presentation/capture_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:quote_app/features/quote/domain/quote_model.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  Cover _cover = Cover.comprehensive;
  double? _premium;

  void _calculate() {
    final r = QuoteRequest(
      make: 'VW',
      year: 2020,
      driverAge: 30,
      cover: _cover,
    );
    setState(() => _premium = calculatePremium(r));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Get a quote')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SegmentedButton<Cover>(
                segments: [
                  for (final c in Cover.values)
                    ButtonSegment(value: c, label: Text(c.name)),
                ],
                selected: {_cover},
                onSelectionChanged: (s) => setState(() => _cover = s.first),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _calculate,
                child: const Text('Calculate'),
              ),
              const SizedBox(height: 24),
              if (_premium != null) PremiumBadge(amount: _premium!),
            ],
          ),
        ),
      );
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, required this.amount});
  final double amount;

  @override
  Widget build(BuildContext context) => Text(
        amount.rands,
        style: Theme.of(context).textTheme.headlineMedium,
      );
}
```

Day 4 onwards needs the mock API in a second terminal:

```
dart run tool/mock_server.dart
```

Android emulator reaches it at `10.0.2.2:8080` (the default). For Chrome or
the iOS simulator:

```
flutter run --dart-define=API_URL=http://localhost:8080

Tap the segments, tap Calculate, watch the premium change.

### 8. Try the Extract Widget refactor

Put your cursor on the `Text(...)` inside `PremiumBadge`, press `⌥+Enter`, and look at the refactor menu: **Wrap with Padding / Center / Column**, **Extract Widget**. You will use this constantly.

### 9. Open the Widget Inspector

With your app running on the emulator/device, go to View → Tool Windows → Flutter Inspector (or find the "Flutter Inspector" tab, usually docked on the right or bottom).
In that panel's toolbar, click the Toggle Select Widget Mode button (looks like a target/cursor select icon).
Tap the premium text on the emulator — it highlights the widget tree and jumps you to the matching source line, same as the DevTools version.

```powershell
flutter analyze          # must be clean
dart fix --apply         # applies suggested fixes (adds missing const, etc.)
git add .
git commit -m "Day 1: skeleton"
```

## Course shape
**Stretch** TODO MISH
1. Make Calculate async: `await FakeQuoteService().getQuote(...)` with a `CircularProgressIndicator` while it runs. Add `if (!mounted) return;` after the await.
2. `flutter pub add intl`, then format with `NumberFormat.currency(locale: 'en_ZA', symbol: 'R ').format(premium)`.
3. Add a second screen and `Navigator.push` to it, a preview of Day 4.

---

## Part 7 · Cheat sheets

### Flutter CLI

| Command | Does |
|---|---|
| `flutter create --org za.co.moint quote_app` | New project with the right package id |
| `flutter run` · `flutter run -d chrome` | Build and run |
| `flutter pub add dio` | Add a dependency |
| `flutter pub add --dev mocktail` | Add a dev dependency |
| `flutter pub get` | Install from pubspec |
| `flutter pub outdated` | What is newer |
| `flutter analyze` | Static analysis |
| `flutter test` | Run tests |
| `flutter clean` | Delete build output, first thing to try when a build misbehaves |
| `dart format .` | Format everything |
| `dart fix --apply` | Apply automated fixes |

### Coming from TypeScript, C# or Java

| Concept | TypeScript | C# | Dart |
|---|---|---|---|
| Immutable binding | `const x = 1` | `readonly` | `final x = 1;` |
| Compile-time constant | - | `const` | `const x = 1;` |
| Nullable | `string \| null` | `string?` | `String?` (enforced at runtime too) |
| Named args | object destructuring | named arguments | `f({required int age})` |
| Interfaces | `interface` | `interface` | any class: `implements` |
| Mixins | - | - | `mixin M {}` · `class A with M` |
| Tuples / records | tuple types | records | `(double, String)` |
| Discriminated union | union + `kind` | abstract records | `sealed class` + `switch` |
| Async | `Promise<T>` | `Task<T>` | `Future<T>` |
| Streams | Observable | `IAsyncEnumerable<T>` | `Stream<T>` |
| Packages | npm / package.json | NuGet / .csproj | pub / pubspec.yaml |

### Coming from React Native

| React Native | Flutter |
|---|---|
| Component | Widget |
| `useState` | `StatefulWidget` + `setState` |
| Props | named constructor params with `required` |
| JSX children | `child:` / `children: [...]` |
| `View` + flex | `Row` / `Column` + `Expanded` |
| `FlatList` | `ListView.builder` |
| `TextInput` | `TextField` / `TextFormField` |
| `useEffect` mount/cleanup | `initState` / `dispose` |
| Context / Zustand | Riverpod (Day 3) |
| Expo Router | `go_router` (Day 4) |
| Fast Refresh | Hot reload (`r`) |

| Day | Subject | Deck |
|---|---|---|
| 1 | Foundations and Dart | `slides/Day1_Foundations_and_Dart.pptx` |
| 2 | Widgets and layout | `slides/Day2_Widgets_and_Layout.pptx` |
| 3 | State management | `slides/Day3_State_Management.pptx` |
| 4 | Data, APIs and navigation | `slides/Day4_Data_APIs_Navigation.pptx` |
| 5 | Testing, CI/CD and shipping | `slides/Day5_Testing_CICD_Shipping.pptx` |

CAN;T USE COLOR AND DECORAITIN

1. What does flutter mean by the size from the child and width and height constraint from parent?
2. Infinite width canvas - redners perfectly on al the different screens all the different time.
3. Safe Area for phone camera and iPhone island
4. Dismissed not on the UI e..g swipe to remove a product, click on undo and it comes back

Rows children unbounded width. Wrapped in an expanded