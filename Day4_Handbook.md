# Flutter Day 4 - Delegate Handbook

**Data, APIs & Navigation** · MO Integrations · Flutter Mobile Application Development

> **How to use this document.** Open it in VS Code alongside the course so you can copy blocks straight out of it. Every code block in this handbook has been compiled and run against Flutter 3.47 with `go_router` 18, `dio` 5 and `sqflite` 2 — `flutter analyze` clean, tests passing.
>
> **Today's deliverable:** the app gets real. Routes with a guard, a real HTTP API behind the same interface as yesterday's fake, quotes saved to SQLite, and an onboarding flag that survives a restart. By the end the whole flow runs: onboarding → capture → API → result → saved.

---

## Part 0 · Where we are

You finished Day 3 with:

| File | What is in it |
|---|---|
| `lib/main.dart` | `runApp(const ProviderScope(child: QuoteApp()))` |
| `lib/app.dart` | `QuoteApp` as a `ConsumerWidget`, theme from `brandProvider` |
| `lib/core/theme/brand_provider.dart` | `BrandKeyNotifier`, `brandKeyProvider`, derived `brandProvider` |
| `lib/features/quote/domain/quote_model.dart` | `Cover`, `QuoteRequest`, `Quote`, `Money`, `calculatePremium`, sealed `QuoteState` |
| `lib/features/quote/data/quote_service.dart` | `QuoteService` interface + `FakeQuoteService` |
| `lib/features/quote/presentation/quote_providers.dart` | `quoteServiceProvider`, `QuoteNotifier`, `quoteProvider` |
| `lib/features/quote/presentation/capture_screen.dart` | `ConsumerStatefulWidget`, watches state, listens for failures |
| `lib/features/quote/presentation/premium_card.dart` | `PremiumCard` |
| `test/quote_notifier_test.dart` | One passing container test |

**Keep `FakeQuoteService`.** It does not get deleted today. It becomes the offline fallback for the rest of the week, and reverting one provider line turns any network problem into a non-event.

**Reminder:** Windows PowerShell 5.1 has no `&&`. One command per line.

---

## Part 1 · Navigation

### 1.1 Navigator 1.0 in three minutes

You will meet this everywhere — every Stack Overflow answer older than about 2022 uses it. Recognise it, then move on.

```dart
// Imperative: push a route object onto a stack
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => ResultScreen(quote: quote)),
);
Navigator.of(context).pop();

// It can return a value
final picked = await Navigator.of(context).push<Cover>(
  MaterialPageRoute(builder: (_) => const CoverPickerScreen()),
);

// Named routes are also 1.0
MaterialApp(routes: {'/result': (_) => const ResultScreen()});
Navigator.pushNamed(context, '/result', arguments: quote);
```

It is genuinely fine for a dialog-like detail page or a small app. It falls short on five things we need:

1. **No URLs**, so no deep links and no sensible web behaviour.
2. **No guards** — nothing evaluates "is this user allowed here?" on every navigation.
3. **Untyped arguments** — `arguments: quote` is an `Object?` you cast at the other end.
4. **Nested stacks are painful** — tabs each keeping their own history is a lot of manual work.
5. **Browser back button semantics are wrong** on the web.

`go_router` is the Flutter-team-maintained answer. Under the hood it *is* Navigator 2.0 (the Router API) with the boilerplate hidden.

### 1.2 The router as a provider

```
flutter pub add go_router
```

```dart
// lib/core/routing/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarded = ref.watch(onboardedProvider);

  return GoRouter(
    initialLocation: '/quote',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final goingToOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !goingToOnboarding) return '/onboarding';
      if (onboarded && goingToOnboarding) return '/quote';
      return null; // null means "allow it"
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

**Why the router is a `Provider`.** It watches `onboardedProvider`. When the flag flips, Riverpod rebuilds this value, `MaterialApp.router` picks up the new router, and the redirect re-evaluates. That is enough for this course. For a larger app the usual alternative is `refreshListenable` with a `ChangeNotifier` bridging Riverpod to GoRouter, so the router object is not recreated on every change.

**Why `result/:id` is nested under `/quote`.** A nested route builds its parent underneath. So a deep link straight to `/quote/result/q-123` still has `/quote` below it, and Back lands on the capture screen instead of leaving the app.

**`debugLogDiagnostics: true`** prints every navigation to the console. Leave it on all day.

### 1.3 MaterialApp.router, navigating, reading parameters

The change to `app.dart` is two lines — `MaterialApp.router` and `routerConfig`:

```dart
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

Four verbs, and the rule for each:

```dart
context.go('/quote');                        // REPLACE the stack
context.push('/quote/result/${quote.id}');   // PUSH on top
context.pop();                               // back
context.goNamed('result', pathParameters: {'id': quote.id});
```

| Verb | Use when |
|---|---|
| `go` | "the app is now at X" — after login, after onboarding, switching tabs |
| `push` | "look at this, then come back" — a detail from a list |
| `pop` | back, and it pops a `push` |

**The distinction that matters today:** `push` to the result, because the user expects Back to return to the form. `go` after onboarding completes, because the user must *not* be able to go back into onboarding.

Reading parameters:

```dart
state.pathParameters['id']          // /quote/result/:id
state.uri.queryParameters['brand']  // /quote?brand=beta
state.extra                         // any object, via context.go(path, extra: obj)
```

**Prefer ids in the path over objects in `extra`.** Passing the whole `Quote` through `extra` is tempting and it breaks on deep links and on process death — there is no object to pass when the OS restarts your app from a URL. Pass the id and look the quote up. `ResultScreen` does exactly that, and it is a code-review point on Friday.

### 1.4 StatefulShellRoute: tabs with independent stacks

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => AppShell(shell: navigationShell),
  branches: [
    StatefulShellBranch(routes: [
      GoRoute(
        path: '/quote',
        builder: (context, state) => const CaptureScreen(),
        routes: [
          GoRoute(
            path: 'result/:id',
            name: 'result',
            builder: (context, state) =>
                ResultScreen(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/saved', builder: (context, state) => const SavedQuotesScreen()),
    ]),
    StatefulShellBranch(routes: [
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ]),
  ],
)
```

```dart
// lib/core/routing/app_shell.dart
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: shell,                       // the shell IS the body
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(
            i,
            initialLocation: i == shell.currentIndex, // re-tap pops to root
          ),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Quote'),
            NavigationDestination(icon: Icon(Icons.bookmark_outline), label: 'Saved'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
          ],
        ),
      );
}
```

Three gotchas, all of which will bite someone:

1. **Routes inside branches need absolute paths** starting with `/`. Relative paths only work for children of a route, not for branch roots.
2. **The shell must be the body.** Do not wrap `navigationShell` in another `Navigator`.
3. **Onboarding stays outside the shell.** You do not want a bottom navigation bar during onboarding.

`NavigationBar` is the Material 3 widget. `BottomNavigationBar` is the older one.

### 1.5 Deep links

```xml
<!-- android/app/src/main/AndroidManifest.xml, inside <activity android:name=".MainActivity"> -->
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />

<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="quoteapp" />
</intent-filter>
```

Test it from a terminal on either OS:

```
adb shell am start -a android.intent.action.VIEW -d "quoteapp:///quote/result/q-123"
```

**Note the triple slash.** Flutter takes the route from the URI *path*. With two slashes, `quote` becomes the host and your route is only `/result/q-123`, which will not match.

A manifest change needs a full stop and `flutter run`. Hot restart is not enough.

`https://` App Links need an `assetlinks.json` file served from the domain — worth showing, not worth building in a classroom. On iOS the equivalents are `CFBundleURLTypes` in `Info.plist` (custom scheme) or Associated Domains (universal links).

---

## READ & BREAK DOWN · 8 min read + 5 min debrief

**Read:** go_router's *Redirection* and *Error handling* pages, then break the guard on purpose.

`pub.dev/packages/go_router` → the documentation link in the README.

**Answer these as you read.**

1. What is the redirect limit, and what error do you get when a redirect loops? How would our onboarding rules loop if written carelessly?
2. Top-level `redirect` versus per-route `redirect`: which runs first, and when would you use each?
3. What does `errorBuilder` do, and what should our 404 screen show?
4. How do you navigate from somewhere with no `BuildContext` — a notifier, say? What does the doc recommend instead?

**Then:** one person writes a looping redirect on the whiteboard and the room finds the fix. Redirect loops are the go_router bug everyone hits exactly once; constructing one deliberately is cheaper than discovering it in a lab.

---

## LAB 4.1 · Routes and the onboarding guard · 40 min

**Goal:** the app has `/onboarding`, `/quote` and `/quote/result/:id`. A redirect forces onboarding once. Submitting a quote navigates to the result. A deep link opens a result.

### Steps

1. `flutter pub add go_router`.
2. Create `lib/core/storage/onboarding_provider.dart` with an in-memory `OnboardedNotifier` (this afternoon it moves to `shared_preferences` and nothing else changes).
3. Create `lib/core/routing/router.dart` from Part 1.2.
4. `app.dart` → `MaterialApp.router(routerConfig: ref.watch(routerProvider))`.
5. Create `OnboardingScreen` (solution below). Confirm the redirect sends you there, and that after "Get started" you cannot get back to it.
6. Create `ResultScreen(id)`. It reads `quoteProvider` and shows `PremiumCard` when the loaded quote's id matches, otherwise "Quote not found".
7. `CaptureScreen`: change `ref.listen` so `QuoteLoaded` pushes `/quote/result/<id>` and `QuoteFailed` still shows the SnackBar.
8. Add the intent filter to `AndroidManifest.xml`. Stop the app and `flutter run` again — hot restart is not enough. Then `adb shell am start -a android.intent.action.VIEW -d "quoteapp:///quote/result/q-1"`.
9. `flutter analyze` clean, then commit.

### Solution: `lib/core/storage/onboarding_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

### Solution: the changed part of `capture_screen.dart`

```dart
// Side effects: navigation and snackbars. Never in the returned tree.
ref.listen(quoteProvider, (prev, next) {
  switch (next) {
    case QuoteLoaded(:final quote):
      context.push('/quote/result/${quote.id}');
    case QuoteFailed(:final message):
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    default:
      break;
  }
});
```

The `QuoteLoaded` case in the switch expression becomes a placeholder, because the card now lives on the result screen:

```dart
QuoteLoaded() => const Text('Opening your quote...'),
```

**Navigation is a side effect.** It belongs in `ref.listen`, not in the widget you return. Put a `context.push` in a `build` return and it fires on every rebuild.

### Solution: `lib/features/quote/presentation/result_screen.dart`

```dart
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = switch (ref.watch(quoteProvider)) {
      QuoteLoaded(:final quote) when quote.id == id => quote,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Your quote')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: quote == null
            ? Center(child: Text('Quote not found: $id'))
            : PremiumCard(quote: quote),
      ),
    );
  }
}
```

Note the `when` clause on the pattern — it matches `QuoteLoaded` **and** checks the id in one expression.

### Step 9 commands

```
flutter analyze
```

```
git add .
```

```
git commit -m "Day 4: routing"
```

### Stretch

- Add the `StatefulShellRoute` with Quote / Saved / Settings tabs.
- Add `errorBuilder` with a 404 screen and a "Go home" button.
- Add `?brand=beta` on `/onboarding` that pre-selects the brand, read via `state.uri.queryParameters`.

---

## Part 2 · REST and JSON

### 2.1 The mock API

`tool/mock_server.dart` is a zero-dependency `dart:io` server. Every delegate runs their own copy, so nobody depends on the venue network. The full source is in Part 6.1.

```
dart run tool/mock_server.dart
```

Reach it from:

| From | URL |
|---|---|
| Android emulator | `http://10.0.2.2:8080` — `10.0.2.2` is the emulator's alias for the host machine |
| iOS simulator | `http://localhost:8080` |
| Physical phone | `http://<laptop LAN IP>:8080`, same Wi-Fi |
| Chrome | `http://localhost:8080` |

Test it before you write any Dart:

```
curl -s -X POST localhost:8080/quote -H 'content-type: application/json' -d '{"make":"VW","year":2020,"driverAge":30,"cover":"comprehensive"}'
```

```
Invoke-RestMethod -Method Post -Uri http://localhost:8080/quote -ContentType 'application/json' -Body '{"make":"VW","year":2020,"driverAge":30,"cover":"comprehensive"}'
```

**Android blocks plain HTTP** on API 28 and above. For the local mock, allow it:

```xml
<application android:usesCleartextTraffic="true" ... >
```

Remove that before release, or replace it with a `network_security_config` restricted to `10.0.2.2`.

**Windows firewall:** the first run prompts *"allow dart to accept connections"*. Click Allow on private networks, or the emulator cannot reach it. If you dismissed the prompt: Windows Security → Firewall → Allow an app → `dart.exe`.

### 2.2 One configured dio client

```
flutter pub add dio
```

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
    headers: {'Accept': 'application/json'},
  ));
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
  return dio;
});
```

```
flutter run --dart-define=API_URL=http://10.0.2.2:8080
```

**Never hard-code an environment URL.** `String.fromEnvironment` reads a compile-time constant supplied by `--dart-define`, with a default for the classroom. On Day 5 the same mechanism selects a flavour.

**`kDebugMode` gates the logger.** Without it, a release build prints request and response bodies — which in this app means customer data in the device log. That is not a style point.

**Why dio over `http`.** `http` is minimal and fine. `dio` adds interceptors, timeouts, cancellation, form-data and typed errors. The typed errors are what make the next section possible.

### 2.3 Errors mapped to messages

```dart
// lib/features/quote/data/dio_quote_service.dart
class DioQuoteService implements QuoteService {
  DioQuoteService(this._dio);
  final Dio _dio;

  @override
  Future<Quote> getQuote(QuoteRequest request) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/quote',
        data: request.toJson(),
      );
      return Quote.fromJson(res.data!);
    } on DioException catch (e) {
      throw QuoteException(_message(e));
    }
  }

  String _message(DioException e) => switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout =>
          'The server took too long. Check your connection.',
        DioExceptionType.connectionError => 'Cannot reach the quote service.',
        DioExceptionType.badResponse => switch (e.response?.statusCode) {
            422 => (e.response?.data as Map?)?['message'] as String? ??
                'Invalid request',
            _ => 'Server error (${e.response?.statusCode})',
          },
        _ => 'Unexpected error: ${e.message}',
      };
}

class QuoteException implements Exception {
  QuoteException(this.message);
  final String message;

  @override
  String toString() => message;
}
```

This is the layer that turns `SocketException: Connection refused` into *"Cannot reach the quote service."* Nothing above it knows what a socket is.

`QuoteException.toString()` returns the bare message, so yesterday's `catch (e) { state = QuoteFailed(e.toString()...) }` shows clean text with no `Exception:` prefix.

**The swap is one line** in `quote_providers.dart`:

```dart
final quoteServiceProvider =
    Provider<QuoteService>((ref) => DioQuoteService(ref.watch(dioProvider)));
```

Hot restart, submit, and watch the `LogInterceptor` output. Nothing else in the app changes — that is what the interface bought you yesterday.

### 2.4 JSON by hand, once

Do this once so the generated code is not magic when it breaks.

```dart
Map<String, dynamic> toJson() => {
      'make': make,
      'model': model,          // null is fine; jsonEncode writes null
      'year': year,
      'driverAge': driverAge,
      'cover': cover.name,     // enum -> string
    };

factory QuoteRequest.fromJson(Map<String, dynamic> j) => QuoteRequest(
      make: j['make'] as String,
      model: j['model'] as String?,
      year: j['year'] as int,
      driverAge: j['driverAge'] as int,
      cover: Cover.values.byName(j['cover'] as String),
    );
```

Four Dart-specific traps:

1. **Numbers.** JSON `1200` decodes as `int`, `1200.5` as `double`. Always cast through `num`: `(j['premium'] as num).toDouble()`. This is the Day 1 exercise, and it is still the most common JSON crash.
2. **Enums.** `.name` out, `Cover.values.byName(...)` in. `byName` **throws** on an unknown value — for a public API, wrap it and default.
3. **Lists.** `(json['items'] as List).map((e) => Quote.fromJson(e as Map<String, dynamic>)).toList()`.
4. **dio already decoded it.** `res.data` is a `Map` or `List` when the content type is JSON. Only use `jsonDecode` on raw strings.

### 2.5 json_serializable

```
flutter pub add json_annotation
```

```
flutter pub add --dev build_runner json_serializable
```

```dart
import 'package:json_annotation/json_annotation.dart';

part 'quote_model.g.dart';   // must match this file's name

@JsonSerializable()
class Quote {
  const Quote({
    required this.id,
    required this.premium,
    this.currency = 'ZAR',
    this.breakdown,
  });

  final String id;
  final double premium;
  final String currency;

  @JsonKey(name: 'breakdown_lines')   // the API field name differs
  final List<String>? breakdown;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
  Map<String, dynamic> toJson() => _$QuoteToJson(this);
}
```

```
dart run build_runner build --delete-conflicting-outputs
```

```
dart run build_runner watch --delete-conflicting-outputs
```

Open the generated `quote_model.g.dart` afterwards. It is the code you hand-wrote in 2.4 — including the `(json['year'] as num).toInt()` cast, which the generator gets right automatically.

**Three errors everyone hits:**

| Error | Cause |
|---|---|
| *"Found 1 declared output which already exists on disk"* | You omitted `--delete-conflicting-outputs`. Always pass it. |
| *"Target of URI hasn't been generated: 'quote_model.g.dart'"* | You have not run the generator yet. |
| *"_$QuoteFromJson isn't defined"* | The `part` directive does not match the file name. |

**Commit the generated files.** They are build output, but committing them means a fresh clone compiles without running the generator first.

`freezed` builds on top of `json_serializable` and also generates `copyWith`, `==` and unions. Worth adopting after the course, not during it.

---

## LAB 4.2 · Real quote API with dio · 45 min

**Goal:** submitting the form calls the mock API through `DioQuoteService`, errors show friendly messages, and the models use `json_serializable`.

**The first ten minutes are infrastructure.** Get the mock answering on every machine before anyone writes Dart.

### Steps

1. Copy `tool/mock_server.dart` (Part 6.1). Run it in a second terminal: `dart run tool/mock_server.dart`. `curl` / `Invoke-RestMethod` it once.
2. `AndroidManifest.xml`: `android:usesCleartextTraffic="true"` on `<application>`. Stop the app and run it again.
3. `flutter pub add dio`. Create `lib/core/network/dio_client.dart` from Part 2.2.
4. Create `lib/features/quote/data/dio_quote_service.dart` from Part 2.3, with `QuoteException`.
5. `quote_providers.dart`: one line — `DioQuoteService(ref.watch(dioProvider))`. Hot restart. Submit. The premium now comes from the server; check the `LogInterceptor` output.
6. Add `QuoteRequest.toJson` / `fromJson` by hand (Part 2.4) so the request serialises.
7. `flutter pub add json_annotation`, `flutter pub add --dev build_runner json_serializable`. Annotate `Quote` and `QuoteRequest`, generate, delete the hand-written methods.
8. Test all three failure modes: year 1998 (a 422 with the server's message), stop the mock (connection message), `--dart-define=API_URL=http://10.0.2.2:9` (connection error).
9. `flutter analyze` clean, then commit.

### The three failure modes, and what you should see

| What you do | What the user sees |
|---|---|
| Year 1998 | *Vehicle too old to insure* — the server's own 422 message |
| Stop the mock server | *Cannot reach the quote service.* |
| Point at a dead port | *Cannot reach the quote service.* |
| Firewall drops packets | *The server took too long. Check your connection.* |

None of those is a stack trace, and the UI code did not change to produce any of them.

### Step 9 commands

```
flutter analyze
```

```
git commit -am "Day 4: dio + json_serializable"
```

### Stretch

- Add a retry interceptor for connection errors, max two attempts.
- Add `@JsonKey(name: 'breakdown_lines')` and render the breakdown list on `PremiumCard`.
- Point `API_URL` at a hosted function and compare latency.

---

## Part 3 · Local storage

### 3.1 shared_preferences: load once, provide, read synchronously

```
flutter pub add shared_preferences
```

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();   // required before any plugin call
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: const QuoteApp(),
  ));
}
```

```dart
// lib/core/storage/prefs_providers.dart
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

class OnboardedNotifier extends Notifier<bool> {
  static const _key = 'onboarded';

  @override
  bool build() => ref.watch(sharedPrefsProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    await ref.read(sharedPrefsProvider).setBool(_key, true);
    state = true;
  }
}

final onboardedProvider =
    NotifierProvider<OnboardedNotifier, bool>(OnboardedNotifier.new);
```

**The pattern to remember:** async initialisation in `main`, override a provider with the ready instance, everything else reads synchronously. No `FutureBuilder` in the widget tree just to read a boolean.

**`throw UnimplementedError()` in the base provider is deliberate.** Forgetting the override then fails loudly and immediately, instead of silently returning something wrong.

Compare this class against Lab 4.1's version. Only `build()` and `complete()` changed. The router, the redirect and the onboarding screen are all untouched — and the flag now survives a restart.

**To see onboarding again while testing:** `adb shell pm clear <applicationId>`, or Settings → Apps → quote_app → Clear storage.

**Not for secrets.** `shared_preferences` is plain text on disk. Tokens go in `flutter_secure_storage`.

### 3.2 sqflite: open, create, migrate

```
flutter pub add sqflite path
```

```dart
// lib/core/storage/database.dart
Future<Database> openQuoteDb() async {
  final dir = await getDatabasesPath();
  return openDatabase(
    p.join(dir, 'quotes.db'),
    version: 1,
    onCreate: (db, version) => db.execute('''
      CREATE TABLE quotes (
        id TEXT PRIMARY KEY,
        premium REAL NOT NULL,
        currency TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    '''),
    onUpgrade: (db, oldV, newV) async {
      if (oldV < 2) await db.execute('ALTER TABLE quotes ADD COLUMN make TEXT');
    },
  );
}

final databaseProvider = Provider<Database>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);
```

**`version` + `onCreate` + `onUpgrade` *is* the migration mechanism.** Bump the version, add the `ALTER` in `onUpgrade`. **Never edit `onCreate` for a table that already exists in the wild** — existing installs never run it again, so your change reaches new installs only and the two diverge.

**sqflite is mobile-only.** `flutter run -d chrome` throws `MissingPluginException`. Anyone on the Chrome fallback uses `InMemoryQuoteRepository` (Part 6.2) — the interface is identical, so every other line is unchanged. Windows desktop needs `sqflite_common_ffi`.

`drift` gives you type-safe SQL with generated DAOs and reactive queries. Worth it once the schema passes about five tables.

### 3.3 Repository plus AsyncNotifier

```dart
// lib/features/quote/data/quote_repository.dart
abstract interface class QuoteRepository {
  Future<List<Quote>> loadAll();
  Future<Quote?> byId(String id);
  Future<void> save(Quote quote);
  Future<void> delete(String id);
}

final quoteRepositoryProvider = Provider<QuoteRepository>(
  (ref) => SqliteQuoteRepository(ref.watch(databaseProvider)),
);
```

```dart
class SqliteQuoteRepository implements QuoteRepository {
  SqliteQuoteRepository(this._db);
  final Database _db;

  @override
  Future<List<Quote>> loadAll() async {
    final rows = await _db.query('quotes', orderBy: 'created_at DESC');
    return rows.map(_fromRow).toList();
  }

  @override
  Future<Quote?> byId(String id) async {
    final rows =
        await _db.query('quotes', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : _fromRow(rows.first);
  }

  @override
  Future<void> save(Quote q) => _db.insert(
        'quotes',
        {
          'id': q.id,
          'premium': q.premium,
          'currency': q.currency,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,   // makes save() an upsert
      );

  @override
  Future<void> delete(String id) =>
      _db.delete('quotes', where: 'id = ?', whereArgs: [id]);

  Quote _fromRow(Map<String, Object?> r) => Quote(
        id: r['id'] as String,
        premium: (r['premium'] as num).toDouble(),   // the num cast again
        currency: r['currency'] as String,
      );
}
```

```dart
class SavedQuotesNotifier extends AsyncNotifier<List<Quote>> {
  @override
  Future<List<Quote>> build() => ref.watch(quoteRepositoryProvider).loadAll();

  Future<void> add(Quote q) async {
    await ref.read(quoteRepositoryProvider).save(q);
    ref.invalidateSelf();      // re-run build() so the list matches the DB
  }

  Future<void> remove(String id) async {
    await ref.read(quoteRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final savedQuotesProvider =
    AsyncNotifierProvider<SavedQuotesNotifier, List<Quote>>(SavedQuotesNotifier.new);
```

**The notifier never sees SQL.** That is the whole point of the repository. It also means tests override `quoteRepositoryProvider` with an in-memory implementation and never touch SQLite.

**`invalidateSelf()` versus assigning `state`.** Invalidating re-runs `build()`, so the list is always exactly what the database holds. Assigning `state = AsyncData([...newList])` avoids a re-query but lets the UI drift from the DB. Teach and use `invalidate`.

**Row types come back as `Map<String, Object?>`.** SQLite has no strict typing, so `premium` arrives as `num` — cast it. Yes, this is the Day 1 exercise for a third time.

Parameterised `where` / `whereArgs`, always. Never string-concatenate SQL.

### 3.4 Which store for what

| Store | For | Notes |
|---|---|---|
| `shared_preferences` | Flags, last brand, small settings | Plain text on disk. Not for secrets |
| `sqflite` / `drift` | Structured data with queries and migrations | Saved quotes, offline cache |
| `hive` / `isar` | Fast object stores, no SQL | Caches. No relations |
| `flutter_secure_storage` | Tokens, credentials | Keychain / Keystore. **Never** prefs |
| `path_provider` + `File` | Arbitrary files | Exports, PDFs, downloaded images |

For an insurer specifically: auth tokens go to secure storage; policy documents go to files in the app's documents directory, encrypted if the regulator requires it.

---

## READ & BREAK DOWN · 10 min read + 5 min debrief

**Read:** the sqflite README and the *Persist data with SQLite* cookbook — and spot the difference from what we built.

`docs.flutter.dev/cookbook/persistence/sqlite`, then the sqflite README sections *Opening a database*, *Transactions*, *Batch*.

**Answer these as you read.**

1. The cookbook opens the database inside each function; we open it once in `main` and provide it. What are the trade-offs?
2. When would you use a transaction, and what happens to a write inside a transaction that throws?
3. What does `Batch` buy you when saving 200 rows? Write the three lines.
4. The cookbook stores a `Dog` with an `int` id; we use a `String` id. What changes for conflicts and ordering?

The cookbook is the top Google result and it shows a simpler-but-worse pattern. Reading it against our version is the point — it teaches judgement rather than obedience.

---

## LAB 4.3 · Mini-project: onboarding → capture → API → result → saved · 60 min

**Goal:** a fresh install shows onboarding once. A quote from the real API can be saved, listed, deleted, reopened after a restart, and opened by deep link.

**Everyone must reach step 5.** Steps 6 to 8 are the quality bar. Friday's testing and release work runs on this exact code.

### Steps

1. `flutter pub add shared_preferences sqflite path`. Rewrite `main.dart` (below): prefs and DB loaded before the first frame, both providers overridden, retry disabled.
2. `lib/core/storage/prefs_providers.dart`: `sharedPrefsProvider`, `OnboardedNotifier` reading and writing `"onboarded"`. Delete the in-memory version from Lab 4.1. Restart the app twice — onboarding must not show the second time.
3. `lib/core/storage/database.dart` (`openQuoteDb`, `databaseProvider`) and `lib/features/quote/data/sqlite_quote_repository.dart`.
4. `quote_repository.dart` with the interface and `quoteRepositoryProvider`; `SavedQuotesNotifier` and `savedQuotesProvider`.
5. `ResultScreen`: a Save button → `savedQuotesProvider.notifier.add(quote)` → SnackBar → `context.go('/saved')`.
6. `SavedQuotesScreen`: `when()` over the `AsyncValue`, swipe to delete, `RefreshIndicator` → `ref.refresh(savedQuotesProvider.future)`.
7. Add the `StatefulShellRoute` if you have not. Settings shows the brand choice and persists it.
8. `ResultScreen`: when `quoteProvider` has no matching quote, fall back to `savedQuotesProvider`. A deep link to a saved id now works after a restart.
9. `flutter analyze` clean, then commit.

### `lib/main.dart` — the bootstrap Day 5 builds on

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final db = await openQuoteDb();

  runApp(ProviderScope(
    // Course setting: surface failures immediately. Remove for production.
    retry: (retryCount, error) => null,
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      databaseProvider.overrideWithValue(db),
    ],
    child: const QuoteApp(),
  ));
}
```

### The Save button, and the one line people forget

```dart
FilledButton.icon(
  onPressed: alreadySaved
      ? null
      : () async {
          await ref.read(savedQuotesProvider.notifier).add(quote);
          if (!context.mounted) return;      // after EVERY await
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quote saved')),
          );
          context.go('/saved');
        },
  icon: const Icon(Icons.bookmark_add_outlined),
  label: Text(alreadySaved ? 'Saved' : 'Save this quote'),
)
```

`if (!context.mounted) return;` after the await. The user may have navigated away while the write was in flight, and touching a dead context throws. The `use_build_context_synchronously` lint catches it when you forget.

### The deep-link fallback

```dart
final live = switch (ref.watch(quoteProvider)) {
  QuoteLoaded(:final quote) when quote.id == id => quote,
  _ => null,
};
final saved =
    ref.watch(savedQuotesProvider).value?.where((q) => q.id == id).firstOrNull;
final quote = live ?? saved;
```

Look in the live flow first, then in what is saved. That is what makes `quoteapp:///quote/result/<saved-id>` work after the app has been killed and restarted — there is no live quote at that point, only a row in SQLite.

Use `.where(...).firstOrNull`, not `firstWhere`. `firstWhere` with no `orElse` throws `Bad state: No element`, and it is the most common crash in this lab.

### Step 9 commands

```
flutter analyze
```

```
git commit -am "Day 4: mini-project"
```

### Stretch

- Show `created_at` with `intl`'s `DateFormat` and add a sort toggle on the Saved tab.
- Cache the last API response in SQLite and show a "cached" badge when the API is unreachable.
- Write a unit test for `SqliteQuoteRepository` using `sqflite_common_ffi` in memory. Part 6.3 has one that passes.

---

## Part 4 · Reference

### 4.1 The dependency direction, after today

```
CaptureForm       ->  knows nothing about Riverpod, routing or HTTP
CaptureScreen     ->  watches quoteProvider, listens, navigates
QuoteNotifier     ->  Loading, await service, Loaded or Failed. No Flutter imports
QuoteService      ->  interface; FakeQuoteService or DioQuoteService
DioQuoteService   ->  the only place that knows what a DioException is
QuoteRepository   ->  interface; SqliteQuoteRepository or InMemoryQuoteRepository
SqliteQuoteRepo   ->  the only place that knows any SQL
```

Two seams, and both earn their keep today: swapping the fake service for the real one was one line, and swapping SQLite for an in-memory store on Chrome is also one line.

### 4.2 go and push, decided

| Situation | Verb |
|---|---|
| After onboarding completes | `go` — they must not go back |
| After login | `go` |
| Switching tabs | `goBranch` on the shell |
| Capture → result | `push` — Back should return to the form |
| List → detail | `push` |
| A deep link arriving | the router handles it; nested routes build the parent underneath |

### 4.3 Which async tool

| You have | Use |
|---|---|
| State with domain meaning beyond loading/data/error | Sealed state + `Notifier` (the quote flow: it has `Idle`) |
| State that IS the async value | `AsyncNotifier` (the saved list) |
| Read-only async, cached | `FutureProvider` |
| A write that should refresh a list | `invalidateSelf()` after the write |

---

## Part 5 · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| "No GoRouter found in context" | Calling `context.go` above `MaterialApp.router` | Move the call below the router, or use `ref` |
| Redirect loop / `GoException` | The redirect returns a location while already there | Guard with `state.matchedLocation` |
| Back returns to onboarding | Used `push` instead of letting the redirect `go` | Let the redirect do it |
| Deep link does nothing | Manifest edited but app only hot-restarted | Stop and `flutter run` |
| Deep link opens the wrong route | Two slashes instead of three | `quoteapp:///quote/...` |
| "Connection refused" | Mock not running, or app using `localhost` on Android | Start the mock; use `10.0.2.2` |
| "Cleartext HTTP traffic not permitted" | `usesCleartextTraffic` missing | Add it, then full restart |
| Windows: emulator cannot reach the mock | Firewall prompt dismissed | Allow `dart.exe` on private networks |
| "Found 1 declared output which already exists" | build_runner without the flag | `--delete-conflicting-outputs` |
| "_$QuoteFromJson isn't defined" | `part` name mismatch, or generator not run | Fix the name; run the generator |
| `MissingPluginException(getDatabasesPath)` | Plugin added, app only hot-reloaded | Stop and run |
| `UnimplementedError` | A provider override missing in `main` | Add it to `overrides:` |
| `Bad state: No element` | `firstWhere` with no `orElse` | `.where(...).firstOrNull` |
| Saved list does not refresh | Forgot `invalidateSelf()` | Add it after the write |
| Onboarding shows every launch | `setBool` not awaited, or wrong key | Await it; check the key |
| `MissingPluginException` on Chrome | sqflite is mobile-only | `InMemoryQuoteRepository` |

---

## Part 6 · Appendix

### 6.1 `tool/mock_server.dart`

A zero-dependency `dart:io` server. Run it with `dart run tool/mock_server.dart`.

```dart
import 'dart:convert';
import 'dart:io';

const _port = 8080;

double _premium(Map<String, dynamic> r) {
  var p = 1000.0;
  final age = (r['driverAge'] as num).toInt();
  final year = (r['year'] as num).toInt();
  if (age < 25) p *= 1.5;
  if (year < 2015) p *= 1.2;
  p *= switch (r['cover'] as String?) {
        'thirdParty' => 0.6,
        'thirdPartyFireTheft' => 0.8,
        _ => 1.0,
      };
  return (p * 100).roundToDouble() / 100;
}

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, _port);
  stdout.writeln('Mock quote API listening on http://localhost:$_port');
  stdout.writeln('Android emulator reaches it at http://10.0.2.2:$_port');

  await for (final req in server) {
    final res = req.response..headers.contentType = ContentType.json;

    if (req.method == 'GET' && req.uri.path == '/health') {
      res.write(jsonEncode({'status': 'ok'}));
      await res.close();
      continue;
    }

    if (req.method != 'POST' || req.uri.path != '/quote') {
      res.statusCode = HttpStatus.notFound;
      res.write(jsonEncode({'message': 'Not found'}));
      await res.close();
      continue;
    }

    try {
      final body = jsonDecode(await utf8.decoder.bind(req).join())
          as Map<String, dynamic>;
      await Future<void>.delayed(const Duration(milliseconds: 800));

      final year = (body['year'] as num).toInt();
      if (year < 2000) {
        res.statusCode = 422;
        res.write(jsonEncode({'message': 'Vehicle too old to insure'}));
        await res.close();
        continue;
      }

      res.write(jsonEncode({
        'id': 'q-${DateTime.now().millisecondsSinceEpoch}',
        'premium': _premium(body),
        'currency': 'ZAR',
        'breakdown_lines': [
          'Base premium',
          if (body['driverAge'] as int < 25) 'Young driver loading',
          if (year < 2015) 'Vehicle age loading',
        ],
      }));
      await res.close();
    } catch (e) {
      res.statusCode = HttpStatus.badRequest;
      res.write(jsonEncode({'message': 'Malformed request: $e'}));
      await res.close();
    }
  }
}
```

### 6.2 `InMemoryQuoteRepository` — the Chrome and desktop fallback

```dart
class InMemoryQuoteRepository implements QuoteRepository {
  final _quotes = <String, Quote>{};

  @override
  Future<List<Quote>> loadAll() async =>
      _quotes.values.toList().reversed.toList();

  @override
  Future<Quote?> byId(String id) async => _quotes[id];

  @override
  Future<void> save(Quote quote) async => _quotes[quote.id] = quote;

  @override
  Future<void> delete(String id) async => _quotes.remove(id);
}
```

Override it in `main` or in a test:

```dart
overrides: [quoteRepositoryProvider.overrideWithValue(InMemoryQuoteRepository())]
```

### 6.3 Testing the repository with real SQLite, no emulator

```
flutter pub add --dev sqflite_common_ffi
```

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  late Database db;
  late SqliteQuoteRepository repo;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, v) => db.execute('''
          CREATE TABLE quotes (
            id TEXT PRIMARY KEY,
            premium REAL NOT NULL,
            currency TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        '''),
      ),
    );
    repo = SqliteQuoteRepository(db);
  });

  tearDown(() => db.close());

  test('save is an upsert - the same id twice does not duplicate', () async {
    await repo.save(const Quote(id: 'q-1', premium: 1000));
    await repo.save(const Quote(id: 'q-1', premium: 2000));
    final all = await repo.loadAll();
    expect(all, hasLength(1));
    expect(all.single.premium, 2000);
  });
}
```

Real SQL, real SQLite, in memory, in milliseconds. This is Friday's material arriving a day early.

---

## Part 7 · Homework for Day 5

Day 5 is testing, flavours, signing and CI. Publishing scored lowest in the survey (1.6), so the afternoon is all release.

Read:

1. `docs.flutter.dev/testing/overview`
2. `docs.flutter.dev/cookbook/testing/widget/introduction` and `.../widget/finders`
3. Skim `riverpod.dev/docs/how_to/testing`

About 20 minutes. Come with an answer to these four:

1. Unit, widget, integration — one sentence each, and which layer of our app each one covers.
2. What do `pumpWidget`, `pump` and `pumpAndSettle` do, and when does `pumpAndSettle` hang forever?
3. Three finders you would use on the capture form, and how you tap a button in a test.
4. How does the Riverpod testing doc swap the API for a fake in a widget test?

Two of you present at 09:00, and we write the first widget test live from your answers.

---

## Links from today

| Topic | Link |
|---|---|
| go_router | pub.dev/packages/go_router |
| go_router redirection | pub.dev/documentation/go_router/latest/topics/Redirection-topic.html |
| Deep linking | docs.flutter.dev/ui/navigation/deep-linking |
| dio | pub.dev/packages/dio |
| json_serializable | pub.dev/packages/json_serializable |
| build_runner | pub.dev/packages/build_runner |
| shared_preferences | pub.dev/packages/shared_preferences |
| sqflite | pub.dev/packages/sqflite |
| SQLite cookbook | docs.flutter.dev/cookbook/persistence/sqlite |
| Secure storage | pub.dev/packages/flutter_secure_storage |
| drift | drift.simonbinder.eu |
| Homework | docs.flutter.dev/testing/overview |
| Course repo | github.com/Clynton19860/flutter |

---

*MO Integrations · Flutter Mobile Application Development · Day 4*
