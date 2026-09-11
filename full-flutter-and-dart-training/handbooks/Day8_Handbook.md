# Day 8 · Data, Testing and Shipping — Delegate Handbook

**Flutter for Java Developers · 8-Day Programme · Day 8 of 8**

A real API · Storing data · Tests · Debugging, performance and release

> **Today the fake data becomes real data from a real server**, the app remembers
> things after you close it, we write tests that prove it works, and we build
> something you could actually install. Then we finish.
>
> Eight days ago most of you had never written a line of Dart.

---

## Today's agenda

| | Time | Block |
|---|---|---|
| 1 | 09:00 – 10:30 | **A real API** — `http` and status codes, JSON by hand then generated, mapping failures to sentences, **Lab 8.1** |
| 2 | 10:45 – 12:30 | **Storing data** — `shared_preferences`, the repository pattern, surviving a restart, **Lab 8.2** |
| 3 | 13:15 – 14:45 | **Testing and debugging** — what to test at which level, unit/model/widget tests, DevTools, **Lab 8.3** |
| 4 | 15:00 – 16:00 | **Shipping and close** — performance, accessibility, release builds, signing, CI, where to go next |

> **The last hour is a demonstration, not a lab.** Do not install anything —
> watch, and take the commands from this handbook. You will do this for real on
> your own project, with your own keystore.

---

# Module 1 · Talking to a real API

**09:15 – 10:30**

By the end of this module you can:

- Make HTTP requests and check the status code properly
- Turn JSON into objects, by hand and with code generation
- Map every failure to a sentence a customer could read
- Swap the fake service for a real one **in one line**

## `http`, and the status code trap

```dart
// flutter pub add http
import 'dart:convert';
import 'package:http/http.dart' as http;

// A GET request
final response = await http.get(
  Uri.parse('https://api.example.com/orders'),
  headers: {'Accept': 'application/json'},
);

// ALWAYS CHECK THE STATUS CODE.
if (response.statusCode != 200) {
  throw Exception('Server returned ${response.statusCode}');
}
final decoded = jsonDecode(response.body);

// A POST request with a JSON body
final created = await http.post(
  Uri.parse('https://api.example.com/orders'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(order.toJson()),
);

// A timeout. EVERY network call should have one.
final r = await http
    .get(Uri.parse('https://api.example.com/orders'))
    .timeout(const Duration(seconds: 10));
```

> **`http` does not throw on a 404 or a 500.** It returns a response with that
> status. If you do not check it, **you will try to parse an error page as JSON**
> and get a `FormatException` that says nothing useful about the real problem.

- **Why `http` and not `dio`:** `http` is the official package, it is small, and
  it does everything this course needs. `dio` adds interceptors, retries and
  better error types, and is the right choice for a large app.
- **`Uri.parse` rather than a string** — a small nudge towards correctness, plus
  helpers for query parameters that handle escaping.
- **Timeouts:** a phone on a bad connection can hang for a very long time, and a
  spinner that never stops is worse than an error message.
- **`jsonDecode` returns `dynamic`** — the one place in the app where `dynamic` is
  unavoidable.

## JSON to objects, by hand

```dart
class OrderLine {
  const OrderLine({
    required this.sku,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  final String sku;
  final String description;
  final int quantity;
  final double unitPrice;

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        sku: json['sku'] as String,
        description: json['description'] as String? ?? '',
        quantity: json['quantity'] as int,
        // a JSON number may be int OR double, so go through num
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'sku': sku,
        'description': description,
        'quantity': quantity,
        'unitPrice': unitPrice,
      };
}

// A LIST of them
final list = jsonDecode(body) as List<dynamic>;
final lines = list
    .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
    .toList();

// A NESTED object
factory Order.fromJson(Map<String, dynamic> json) => Order(
      id: json['id'] as String,
      customer: json['customer'] as String,
      status: OrderStatus.values.byName(json['status'] as String),
      lines: (json['lines'] as List<dynamic>)
          .map((e) => OrderLine.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
```

> **The JSON boundary is where an untyped world meets your typed one.**
> Everything inside is typed; **the casts live here and nowhere else.**

- **The `num` cast is the one that bites.** A JSON number arrives as an `int` or
  a `double` depending on whether the server wrote `250` or `250.0`. Casting
  straight to `double` fails on the first. **This is a real bug that appears in
  production and not in testing.**
- **The nullable field pattern:** `json['description'] as String? ?? ''`. Real
  APIs omit fields, and a missing field is `null`, not an error. Defending at the
  boundary beats a null check on every screen.
- **Enums:** `OrderStatus.values.byName` **throws** on an unknown value. For a
  server you do not control, catch it and fall back — a new status added on the
  server should not crash the app.

**`factory` constructors from Day 2 arrive here in their natural home.**

## JSON, generated

```dart
// flutter pub add json_annotation
// flutter pub add --dev build_runner json_serializable
import 'package:json_annotation/json_annotation.dart';

part 'order_line.g.dart';          // the generated file

@JsonSerializable()
class OrderLine {
  const OrderLine({
    required this.sku,
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  final String sku;
  final String description;
  final int quantity;

  // Map a different name on the wire
  @JsonKey(name: 'unit_price')
  final double unitPrice;

  factory OrderLine.fromJson(Map<String, dynamic> json) =>
      _$OrderLineFromJson(json);
  Map<String, dynamic> toJson() => _$OrderLineToJson(this);
}
```

```bash
# Generate once:
dart run build_runner build --delete-conflicting-outputs

# Or watch while you work:
dart run build_runner watch --delete-conflicting-outputs
```

**The argument:** hand-written mappers are fine for five classes and a liability
for fifty, because **they drift**. Somebody adds a field to the model and forgets
the mapper, and the bug is silent.

> **The part file will not exist until you run the generator**, so the red
> underlines before the first run are expected.

**Commit the `.g.dart` files.** CI and a fresh clone then build without running
the generator first, and the compiler needs them as real source.

**For the Java room:** this is annotation processing — the same idea as Lombok or
MapStruct, with a separate command instead of a compiler plugin.

## The service, and swapping it in

```dart
// The service, behind the interface you already registered
// yesterday. Only this file knows that HTTP exists.
class HttpOrderService implements OrderService {
  HttpOrderService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<List<Order>> fetchAll() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/orders'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ServerException(response.statusCode);
      }

      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const SlowConnectionException();
    } on FormatException {
      throw const BadResponseException();
    }
  }
}
```

> **This class implements the same `OrderService` interface the fake implemented
> yesterday.** Registering it changes **one line** in `main`, and not a single
> screen or model changes.

- **The `client` parameter is the testability hinge.** A default client for
  production, a fake client in a test. **One optional parameter buys the whole
  test pyramid.**
- **The catch blocks are the design**, not an afterthought. Each becomes a domain
  exception the rest of the app understands.
- **Notice what does not leak out:** no status codes, no `SocketException`, no
  `jsonDecode` failures. The rest of the app sees only `AppException` subtypes.

**Imports that catch people:** `SocketException` is in `dart:io`,
`TimeoutException` is in `dart:async`.

> `dart:io` is **not available on the web**, so an app targeting Chrome needs a
> different check.

## Every failure becomes a sentence

> ## The rule for the whole course
>
> **The user never sees a stack trace, a status code, or the word Exception.
> Every failure becomes a sentence a customer could read.**

```dart
sealed class AppException implements Exception {
  const AppException();
}

class NoConnectionException extends AppException {
  const NoConnectionException();
}

class SlowConnectionException extends AppException {
  const SlowConnectionException();
}

class BadResponseException extends AppException {
  const BadResponseException();
}

class ServerException extends AppException {
  const ServerException(this.statusCode);
  final int statusCode;
}

// Because it is sealed, the compiler checks you handled
// every failure mode.
String userMessage(AppException e) => switch (e) {
      NoConnectionException() =>
        'You appear to be offline. Check your connection and try again.',
      SlowConnectionException() =>
        'The server is taking too long. Please try again.',
      BadResponseException() =>
        'We could not read the response. Please try again shortly.',
      ServerException(:final statusCode) when statusCode == 404 =>
        'That order no longer exists.',
      ServerException(:final statusCode) when statusCode >= 500 =>
        'The server is having trouble. Please try again shortly.',
      ServerException() => 'Something went wrong. Please try again.',
    };
```

**Why sealed** — and this is Day 3 doing real work on the last day: the switch is
exhaustive, so **adding a fifth failure mode breaks compilation until somebody
writes a sentence for it**. It becomes structurally impossible to ship a failure
with no message.

**Contrast with the normal approach:** a chain of `instanceof` checks ending in
*"something went wrong"*. New exception types get added, the chain does not get
updated, and users see the generic message for a failure you could have explained
precisely.

**The guards** — a 404 is a different sentence from a 500, handled in the same
switch. That is Day 3's guards in a genuinely useful place.

> Read those messages against `Error: SocketException: Failed host lookup`.
> **Every one says what happened and what to do.**

## Loading, loaded, failed — rendered exhaustively

```dart
class OrderListModel extends ChangeNotifier {
  OrderListModel(this._service);
  final OrderService _service;

  OrderState _state = const OrderIdle();
  OrderState get state => _state;

  Future<void> load() async {
    _state = const OrderLoading();
    notifyListeners();
    try {
      final orders = await _service.fetchAll();
      _state = OrderLoaded(orders.first);
    } on AppException catch (e) {
      _state = OrderFailed(userMessage(e));
    }
    notifyListeners();
  }
}

// And the screen renders it EXHAUSTIVELY.
Widget build(BuildContext context) {
  final state = context.watch<OrderListModel>().state;
  return switch (state) {
    OrderIdle() => const EmptyState(message: 'Pull down to load'),
    OrderLoading() => const Center(child: CircularProgressIndicator()),
    OrderLoaded(:final order) => OrderView(order: order),
    OrderFailed(:final message) => ErrorView(
        message: message,
        onRetry: () => context.read<OrderListModel>().load(),
      ),
  };
}
```

> **You wrote this sealed state on Day 3, in a browser, with no idea what it was
> for. This is what it was for.**

**Two notifications** — loading, then the result — so the screen shows a spinner
and then the answer. Five lines.

**What that prevents:** in most applications, at least one screen forgets the
loading spinner and at least one silently swallows an error. **Neither is
possible here. That is not discipline, it is the type system.**

**The retry button is part of the design**, not an extra. An error state with no
way out is a dead end.

**Notice the screen contains no `try`, no `catch` and no null checks.** All of
that lives in the service and the model. That separation is what makes this
afternoon's widget test trivial.

---

## LAB 8.1 · The real order service · 40 min

**Goal** — a real HTTP call to the classroom API, JSON mapped to your model,
every failure turned into a sentence, and four states rendered exhaustively.

1. `flutter pub add http`. Add `fromJson` and `toJson` to `OrderLine` and `Order`.
2. Write the sealed `AppException` hierarchy with four subtypes.
3. Write `userMessage` as an exhaustive switch, with guards for 404 and 500.
4. Write `HttpOrderService` implementing `OrderService`, with a `baseUrl`, an
   optional client and a ten-second timeout.
5. **Register it in `main` instead of the fake. One line.**
6. Give `OrderListModel` a `load` method that sets Loading, awaits, then sets
   Loaded or Failed.
7. Render the four states with an exhaustive switch, including a Retry button.
8. **Turn off the wifi on the emulator and confirm you see your own sentence, not
   a stack trace.**

> **Step 8 is the one that matters.** It takes thirty seconds and it is the
> difference between a demo and a product.
>
> **Step 5 deserves a moment.** How many files did you have to change? One. That
> is the payoff of yesterday's dependency injection.

### Common errors

- Forgetting to check the status code, then getting a `FormatException` that
  blames the wrong thing.
- Casting a JSON number straight to `double`.
- Missing the `dart:io` or `dart:async` import.
- **Using `localhost` from an Android emulator.** The host machine is
  **`10.0.2.2`**, not `localhost`. This catches somebody every single time.

### Stretch

- Add a POST that submits the order, and handle a 422 as a specific message.
- Add a pull-to-refresh that calls `load` again.
- Set up `json_serializable` for one class and compare the generated code with
  your hand-written version.

---

# Module 2 · Storing data on the device

**10:45 – 12:30**

By the end of this module you can:

- Use `shared_preferences` for settings and small values
- Hide storage behind a repository interface
- Make the app survive being closed and reopened
- Know when you have outgrown key-value storage

## `shared_preferences`

```dart
// flutter pub add shared_preferences
import 'package:shared_preferences/shared_preferences.dart';

// Reading is asynchronous the first time
final prefs = await SharedPreferences.getInstance();

await prefs.setString('seedColor', '2A9D8F');
await prefs.setBool('darkMode', true);
await prefs.setInt('lastOrderNumber', 1042);

final seed = prefs.getString('seedColor');      // String? - may be null
final dark = prefs.getBool('darkMode') ?? false;

await prefs.remove('darkMode');
await prefs.clear();
```

**`SharedPreferences` on Android, `UserDefaults` on iOS.** Strings, ints,
doubles, bools and a list of strings. That is the whole API.

| Good for | Not for |
|---|---|
| Settings, feature flags | Lists of records |
| A theme choice | Anything you want to query |
| The last screen visited | Anything large |
| A token in a low-risk app | **Anything secret** |

> **It is not encrypted**, and on a rooted device it is readable. For secrets use
> `flutter_secure_storage`, which uses the Keychain on iOS and the Keystore on
> Android.

- **Getting the instance is asynchronous the first time**, then cached. Loading
  at startup, once, into a model is the usual answer.
- **The getters return nullable types**, which is correct — on first run nothing
  is stored. `??` supplies the default. **That first-run case is step 7 of the
  lab and people forget it.**
- **Storing a big JSON blob in a preference works** and is what Lab 8.2 does
  deliberately — and **it is the point at which you should be thinking about a
  database.**

## The repository pattern

```dart
// A repository hides WHERE the data comes from.
abstract class OrderRepository {
  Future<List<Order>> load();
  Future<void> save(List<Order> orders);
}

class LocalOrderRepository implements OrderRepository {
  static const _key = 'orders';

  @override
  Future<List<Order>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];            // first run
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];                           // corrupt, start clean
    }
  }

  @override
  Future<void> save(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(orders.map((o) => o.toJson()).toList()),
    );
  }
}
```

**Why it matters more on mobile than on a server:** the data source is genuinely
uncertain. Sometimes the network is there and sometimes it is not. **A repository
is where you decide:** try the network, fall back to the cache, save what you got.
The screen should never contain that logic and never even know it exists.

> **The error handling on `load` is worth pointing at.** A corrupt stored value
> returns an empty list rather than crashing. **Stored data can be corrupt because
> a previous version of your app wrote a different shape.** Version two of your
> app reads version one's data — either version the stored format, or be tolerant
> on read. Most teams learn this the hard way.

**When you outgrow it:** `sqflite` gives you real SQLite with SQL, `drift` gives
you a typed query layer on top. **The repository interface does not change**,
which is the whole point.

---

## LAB 8.2 · Make it survive a restart · 40 min

**Goal** — the order and the theme stored on the device, loaded at startup, and
saved after every change, all behind a repository interface.

1. `flutter pub add shared_preferences`
2. Write the `OrderRepository` interface with `load` and `save`.
3. Write `LocalOrderRepository` using `SharedPreferences` with `jsonEncode` and
   `jsonDecode`.
4. Register it with `Provider`, and give `OrderModel` the repository.
5. Load at startup, and save after every change.
6. **Run the app, add two lines, kill it completely from the task switcher, and
   reopen it.** The lines should still be there.
7. Persist the theme seed colour and mode too.
8. Handle the first run, where nothing is stored, without crashing.

> **Step 6 must be a real kill, not a hot restart.** Swipe the app away from the
> task switcher. A hot restart keeps the process alive and proves nothing.

> **Note the order of operations:** `notifyListeners()` **first**, then save.
> **The user should never wait for a disk write** to see their own tap take effect.

### Common errors

- Forgetting that `getInstance` is async.
- Not handling the first run, so a null string goes into `jsonDecode` and throws.
- Calling `restore` in `build` instead of at creation, which reloads on every
  rebuild.
- Saving inside the state change and blocking the UI.

### Stretch

- Add a `lastSavedAt` timestamp and show it in the app bar.
- Make `load` tolerant of a corrupt stored value.
- **Write an `InMemoryOrderRepository` and swap it in with one line.** That is
  what your tests will use this afternoon.

---

# Module 3 · Testing and debugging

**13:15 – 14:45**

By the end of this module you can:

- Decide what to test at which level
- Write unit tests, model tests and widget tests
- Use DevTools to inspect, measure and debug
- Read a Flutter error properly

> **You have been testable since Day 7.** The models import nothing from Flutter,
> the services are injected, the pricing logic is pure. **Testing is not extra
> work bolted on at the end; it is what the architecture was for.**

## What to test, and at which level

| Level | Shape |
|---|---|
| **Unit** | Many, fast, **no Flutter imports**. Pricing rules, validators, models, mappers. Milliseconds each. Write lots. |
| **Model** | Several, fast, no widgets. A `ChangeNotifier` with a fake service. State transitions, and **every failure path**. |
| **Widget** | Some, fast enough, a real tree in memory. Does this screen render the right thing; does tapping this do what it should. |
| **Integration** | Few, slow, a real device. The one or two journeys that must never break. |

> **The shape that goes wrong:** lots of slow end-to-end tests and almost no unit
> tests. They take twenty minutes, they fail for unrelated reasons, and eventually
> somebody turns them off.

```bash
flutter test                     # everything except integration
flutter test test/one_test.dart  # a single file
flutter test --coverage          # writes coverage/lcov.info
```

**For a Java room the API is familiar:** `group` is a test class, `test` is a
`@Test` method, `expect` is an assertion. `setUp` and `tearDown` exist and mean
what you expect.

> **`expect` takes actual then expected**, which is the opposite order from some
> JUnit assertions.

## Unit tests

```dart
// test/order_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Order', () {
    test('itemCount sums the quantities', () {
      const order = Order(
        id: 'ORD-1',
        customer: 'Acme',
        lines: [
          OrderLine(sku: 'SKU-1', description: 'a', quantity: 40, unitPrice: 250),
          OrderLine(sku: 'SKU-2', description: 'b', quantity: 10, unitPrice: 120),
        ],
      );
      expect(order.itemCount, 50);
    });

    test('subtotal multiplies and adds', () {
      const order = Order(
        id: 'ORD-1',
        customer: 'Acme',
        lines: [
          OrderLine(sku: 'SKU-1', description: 'a', quantity: 40, unitPrice: 250),
        ],
      );
      expect(order.subtotal, 10000.0);
    });

    test('copyWith does not change the original', () {
      const original = Order(id: 'ORD-1', customer: 'Acme', lines: []);
      final copy = original.copyWith(status: OrderStatus.submitted);
      expect(original.status, OrderStatus.draft);
      expect(copy.status, OrderStatus.submitted);
    });
  });
}
```

**Matchers:** `isA<T>()`, `contains`, `isEmpty`, `greaterThan`, `throwsA`. Rich
enough that you rarely need a custom one.

> **These tests run in milliseconds because nothing in them imports Flutter.**
> That is the Day 1 domain rule, paying off on Day 8. If the model had imported
> `material.dart`, every one of these would need a widget binding and be an order
> of magnitude slower.

**Test names are sentences.** *"itemCount sums the quantities"* reads as
documentation in the output. A test called `testOrder1` tells a future maintainer
nothing.

**Where to start on an untested codebase at home:** the pure functions. Pricing,
validation, formatting. Fastest to write, highest value, no refactoring needed.

## Testing a model with a fake service

```dart
class FakeOrderService implements OrderService {
  FakeOrderService({this.shouldFail = false});
  final bool shouldFail;

  @override
  Future<List<Order>> fetchAll() async {
    if (shouldFail) throw const NoConnectionException();
    return const [Order(id: 'ORD-1', customer: 'Acme', lines: [])];
  }
}

void main() {
  test('load moves idle to loading to loaded', () async {
    final model = OrderListModel(FakeOrderService());
    final seen = <OrderState>[];
    model.addListener(() => seen.add(model.state));

    await model.load();

    expect(seen.map((s) => s.runtimeType),
        [OrderLoading, OrderLoaded]);
  });

  test('a connection failure becomes a readable message', () async {
    final model = OrderListModel(FakeOrderService(shouldFail: true));
    await model.load();
    expect(model.state, isA<OrderFailed>());
    expect((model.state as OrderFailed).message, contains('offline'));
  });
}
```

**The fake is four lines.** No mocking framework required — although `mocktail`
exists (the Mockito equivalent) if you want verification and argument matchers.

**The listener trick captures the sequence of states.** Asserting on the **order**
of states, loading then loaded, rather than just the final state, **is what proves
the spinner appears.** That is a bug people ship constantly: the data arrives but
the loading state never rendered.

**The failure test is the more valuable of the two.** It proves that a connection
failure produces the sentence a customer reads. That is a requirement, and it is
now enforced.

> **The entire order flow, including its failure path, verified in under a
> second** — no emulator, no network, no widget tree. **This is why the model
> imports nothing from Flutter.**

## Widget tests

```dart
void main() {
  testWidgets('shows the empty state when there are no lines',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => OrderModel(),
          child: const OrderScreen(),
        ),
      ),
    );
    expect(find.text('No lines yet'), findsOneWidget);
  });

  testWidgets('adding a line shows it in the list',
      (WidgetTester tester) async {
    final model = OrderModel()
      ..addLine(const OrderLine(
          sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: model,
          child: const OrderScreen(),
        ),
      ),
    );

    expect(find.text('Widget'), findsOneWidget);
    expect(find.text('No lines yet'), findsNothing);
  });

  testWidgets('tapping clear empties the list',
      (WidgetTester tester) async {
    // ...pump as above...
    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();               // rebuild after setState
    expect(find.text('No lines yet'), findsOneWidget);
  });
}
```

- **`testWidgets` instead of `test`**, and you get a `WidgetTester`.
- **`pumpWidget` needs a `MaterialApp`** around your screen, because `Theme` and
  `Navigator` must exist above it.
- **Finders:** `find.text`, `find.byType`, `find.byIcon`, `find.byTooltip`,
  `find.byKey`. **Matchers:** `findsOneWidget`, `findsNothing`, `findsNWidgets`.
- **`findsNothing` is underused.** Asserting the empty state is **gone** after
  adding a line is as valuable as asserting the line appeared.

> **`pump` versus `pumpAndSettle` is the thing people get wrong.** `pump` advances
> exactly one frame. `pumpAndSettle` keeps pumping until nothing is animating.
> After a tap that triggers a rebuild, `pump` is enough. After a navigation with a
> transition, you need `pumpAndSettle`. **Getting it wrong gives a test that fails
> intermittently.**

**`find.byTooltip` is why tooltips matter.** The accessibility habit from Day 5
makes icon buttons findable in tests — one property, three benefits.

## Debugging and DevTools

```dart
debugPrint('order: $order');           // truncates huge output
// Never ship print() in release code. There is a lint for it.
```

**Breakpoints work exactly as you expect** in VS Code and Android Studio. Set one
in `build()` and step through.

**DevTools** — press `v` in the `flutter run` terminal, or use the editor button:

| Tab | For |
|---|---|
| **Widget Inspector** | Tap a widget on the device, jump to the source line that created it |
| **Layout Explorer** | See flex factors and constraints |
| **Performance** | One bar per frame; red means over budget |
| **Memory** | Allocations and leaks |
| **Network** | Every HTTP request the app made |

**Debug paint** — press `p` in the terminal. It draws layout guides over your app,
which makes padding and alignment problems visible instantly.

> **A red screen is a debug-only courtesy.** In release the user gets a grey box
> and no information, **so every red screen must be fixed before shipping.**

**Reading Flutter errors is a skill.** They are long, and engineers learn to skim
long messages. Flutter's name the widget, the file, the line, and usually suggest
the fix.

---

## LAB 8.3 · A green test suite · 35 min

**Goal** — unit tests for the model, boundary tests for the discount bands, a
model test with a fake service, and one widget test. All green.

1. `test/order_test.dart` with a group for `Order`: `itemCount`, `subtotal`,
   `copyWith` immutability, and an empty order.
2. **Test the discount bands at the boundaries: 9999, 10000, 49999, 50000.**
3. `test/order_model_test.dart` with a `FakeOrderService` that can be told to fail.
4. Test that `load` moves through Loading then Loaded, and that a failure produces
   your message.
5. `test/order_screen_test.dart`: the empty state shows, a line appears when
   added, and tapping Clear empties the list.
6. `flutter test`, and get everything green.
7. **BREAK SOMETHING on purpose**, such as the subtotal calculation, and confirm a
   test catches it.
8. `flutter test --coverage`, and look at what is not covered.

> **Step 2 is the most valuable in the lab.** Off-by-one at a band boundary is the
> classic pricing bug, it is invisible to manual testing, and four tests pin it
> forever.
>
> **Step 7 is the one people skip and should not.** A test suite you have never
> seen fail is not a test suite, it is a ritual.
>
> **The coverage step is a discussion, not a target.** Generated code and simple
> getters do not matter; the error paths do. **A coverage percentage is a terrible
> goal and a useful map.**

### Common errors

- Using `test` instead of `testWidgets` for widget tests.
- Missing the `MaterialApp` wrapper, giving a confusing error about
  `Directionality`.
- Using `pump` where `pumpAndSettle` was needed.
- Writing a test that passes whatever the code does.

### Stretch

- Add a test that a null description in JSON does not crash `fromJson`.
- Use `mocktail` instead of a hand-written fake and compare.
- **Add a widget test that the error state shows a Retry button and that tapping
  it calls `load` again.**

---

# Module 4 · Shipping, and where to go next

**15:00 – 16:00 · demonstration, not a lab**

## Performance

```bash
# MEASURE IN PROFILE MODE. Debug numbers are meaningless.
flutter run --profile
```

**The budget:** 16.7 ms per frame at 60 Hz, 8.3 ms at 120 Hz — covering building,
laying out and painting everything.

**The checklist, in order of how often it is the answer:**

1. **`const` constructors** everywhere the compiler allows
2. **Extract widgets** so a rebuild touches less of the tree
3. `ListView.builder`, never a `Column` of a thousand children
4. `context.select` instead of `watch` for expensive widgets
5. `cacheWidth` and `cacheHeight` on large images
6. `RepaintBoundary` around something animating inside a static parent
7. `compute()` for any CPU work over a few milliseconds
8. Do not `await` network calls in `main()` before `runApp`

> **The first two solve more real problems than everything below them combined.**
> People reach for isolates and `RepaintBoundary` first and they are almost never
> the issue.

**Finding the problem:** DevTools → Performance → record → use the app → look for
frames over the line. Or DevTools → Inspector → **Track widget rebuilds**, and
watch which widgets rebuild that should not have.

**The honest framing:** most Flutter apps do not have a performance problem, and
the ones that do usually have exactly one, findable in ten minutes. **Do not
optimise speculatively.**

## Accessibility, in six checks

> Accessibility is **not optional** in most enterprise and public sector work, and
> most of it costs one line.

```dart
// 1. LABEL EVERYTHING A SCREEN READER WILL ANNOUNCE
IconButton(
  icon: const Icon(Icons.delete),
  tooltip: 'Delete line',          // announced, and shown on hover
  onPressed: _delete,
)

Image.asset('assets/logo.png', semanticLabel: 'OrderFlow logo')

// 2. WRAP ANYTHING CUSTOM IN Semantics
Semantics(
  label: 'Order total, 11 500 rand',
  child: Text(order.subtotal.rands),
)
```

3. **Test at 200% text scale.** Device settings → Display → Font size → largest.
   **Anything with a fixed height around text will break.** Thirty seconds, and it
   finds real bugs.
4. **Touch targets must be at least 48 × 48.** `IconButton` already is. A bare
   `GestureDetector` on a small icon is not.
5. **Contrast** comes free from `ColorScheme.fromSeed`, because the role and its
   `on` colour are generated with correct contrast. **Hard-coded colours are where
   contrast failures come from** — the fourth reason not to use them.
6. **Do not rely on colour alone.** A red border with no message is invisible to a
   colour-blind user, and around eight per cent of men are.

> **The tooltip habit from Day 5 was this all along.** One property: announced by a
> screen reader, shown on hover, **and** findable in a widget test.

## Building a release

```bash
# 1. CHECK IT BUILDS AND RUNS AS A RELEASE
flutter build apk --release
flutter run --release

# 2. SET THE APPLICATION ID AND VERSION
#    android/app/build.gradle.kts   applicationId
#    pubspec.yaml                   version: 1.0.0+1

# 3. ICONS AND SPLASH, without opening the native projects
flutter pub add --dev flutter_launcher_icons
flutter pub add --dev flutter_native_splash

# 4. SIGN IT
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# 5. BUILD THE BUNDLE for Google Play
flutter build appbundle --release

# 6. CHECK THE SIZE
flutter build apk --analyze-size --target-platform android-arm64
```

- **Build and run in release first.** Things that work in debug can fail in
  release — usually an assertion that was doing real work, or a lazily-registered
  provider.
- **The version number is what teams get wrong for months.** Before the `+` is
  what users see. **After the `+` is the build number, and it must increase for
  every single upload.** Upload the same build number twice and the store rejects
  it with a message that does not explain why.

> ## The keystore
>
> **You create it once. Every future update must be signed with the same key.
> Lose it and you cannot update your app, ever** — you have to publish a new
> listing and lose your users and your reviews.
>
> **Back it up somewhere your organisation will still have in five years.**
>
> **Play App Signing** changes this and most new apps should use it: Google holds
> the app signing key and you keep an upload key, which **can** be reset.

**App Bundle rather than APK** for Google Play — the store builds a trimmed APK
per device, so users download less.

**iOS in one sentence:** you need a Mac, an Apple Developer account and Xcode.
The Flutter side is identical; everything different is Apple's process, not
Flutter's.

## CI and lints: the four gates

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --release
```

| Gate | Buys you |
|---|---|
| `dart format --set-exit-if-changed` | No formatting debates, permanently |
| `flutter analyze` | No warnings merged |
| `flutter test` | Nothing merged broken |
| `flutter build` | It still compiles for real |

> **Every one of these is cheap on day one of a project and expensive to introduce
> in month six**, when there are four hundred existing warnings and nobody wants
> to fix them. **If you take one process improvement home, make it this.**

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_print
    - prefer_const_constructors
    - prefer_final_locals
    - unawaited_futures
    - use_build_context_synchronously

analyzer:
  errors:
    # promote the dangerous ones from warning to error
    use_build_context_synchronously: error
    unawaited_futures: error
```

**Two lints deserve promotion to error**, and both have bitten you this week:
`use_build_context_synchronously` catches using a context after an `await` with no
`mounted` check; `unawaited_futures` catches the silent crash from Day 4.

**`dart fix --apply`** applies every mechanical fix across the project in one
pass, including adding `const` everywhere.

**For the Java room:** this is Checkstyle and SpotBugs, with a much smaller
configuration and much better defaults.

## Where to go next

**Roughly in the order you will want it:**

| | |
|---|---|
| **Routing at scale** | `go_router` — URL routes, typed parameters, redirect guards, deep links |
| **State management, next step** | `riverpod` — the same ideas without `BuildContext`, testable in isolation, no runtime provider-not-found |
| **Real databases** | `sqflite` for SQLite and SQL; `drift` for a typed query layer |
| **Code generation** | **`freezed`** — immutable classes, `copyWith`, equality and sealed unions, all generated. `json_serializable` for the JSON you wrote by hand today |
| **Animation** | Implicit (`AnimatedContainer`, `AnimatedOpacity`), explicit (`AnimationController` and `Tween`), `Hero` for shared elements |
| **Platform code** | `MethodChannel` — call Kotlin or Swift from Dart when no plugin exists |
| **The rest** | Flavours for dev/staging/production, `firebase_crashlytics` or Sentry, `integration_test`, golden tests, `flutter_secure_storage` |

> **`freezed` is the one you will thank us for.** Everything you hand-wrote on Day
> 2 and Day 3 — `copyWith`, equality, sealed unions — generated from an
> annotation. Learning it **now**, after having written it by hand, is the right
> order.
>
> **Platform channels mean Flutter is never a dead end.** When no plugin exists, a
> `MethodChannel` calls Kotlin or Swift directly.

**None of this is needed for the app you built.** The foundations are what matter
and you have them.

---

# Course close

- **Eight days ago most of you had never written Dart.** Today the app calls a
  real API, stores data on the device, has three layers of tests, and builds a
  release.
- **Four days on the language was the right call.** Every Flutter problem you will
  hit is a Dart problem wearing a costume.
- **The architecture is the point:** domain knows nothing about the UI, services
  are injected, and the model imports nothing from Flutter.
- **Sealed states and exhaustive switches** mean you cannot forget the loading
  case or the error case. The compiler enforces it.
- **Every failure becomes a sentence a customer could read.** No stack traces, no
  status codes, no leaked exception text.
- **The handbooks contain every file in full.** You are not reconstructing
  anything from memory on Monday.

### Tomorrow

1. Start your real project from the folder structure in the Day 1 handbook
2. **Add the four CI gates on day one, not month six**
3. Pick one state management approach and be consistent
4. Write the unit tests for your pure logic first — the cheapest tests you will
   ever write

---

# Appendix A · Lab 8.1

### Starter

```dart
// LAB 8.1 - a real API
// flutter pub add http

// TODO 1: add fromJson and toJson to OrderLine and Order.
//         Remember (json['unitPrice'] as num).toDouble()
// TODO 2: a sealed AppException with NoConnection,
//         SlowConnection, BadResponse and Server(statusCode)
// TODO 3: String userMessage(AppException e) as an exhaustive
//         switch, returning a sentence a customer could read
// TODO 4: HttpOrderService implements OrderService, taking a
//         baseUrl and an optional http.Client. fetchAll does a
//         GET, checks the status code, and maps the failures
//         from TODO 2. Give it a 10 second timeout
// TODO 5: register it in main instead of the fake, in ONE line
// TODO 6: give OrderListModel a load() that sets Loading,
//         awaits the service, then sets Loaded or Failed
// TODO 7: render the four states with an exhaustive switch
// TODO 8: turn off the wifi on the emulator and confirm you
//         see your own sentence, not a stack trace
```

### Solution

```dart
sealed class AppException implements Exception {
  const AppException();
}

class NoConnectionException extends AppException {
  const NoConnectionException();
}

class SlowConnectionException extends AppException {
  const SlowConnectionException();
}

class BadResponseException extends AppException {
  const BadResponseException();
}

class ServerException extends AppException {
  const ServerException(this.statusCode);
  final int statusCode;
}

String userMessage(AppException e) => switch (e) {
      NoConnectionException() =>
        'You appear to be offline. Check your connection and try again.',
      SlowConnectionException() =>
        'The server is taking too long. Please try again.',
      BadResponseException() =>
        'We could not read the response. Please try again shortly.',
      ServerException(:final statusCode) when statusCode == 404 =>
        'That order no longer exists.',
      ServerException(:final statusCode) when statusCode >= 500 =>
        'The server is having trouble. Please try again shortly.',
      ServerException() => 'Something went wrong. Please try again.',
    };

class HttpOrderService implements OrderService {
  HttpOrderService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  @override
  Future<List<Order>> fetchAll() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/orders'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ServerException(response.statusCode);
      }

      final list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const SlowConnectionException();
    } on FormatException {
      throw const BadResponseException();
    }
  }
}

class OrderListModel extends ChangeNotifier {
  OrderListModel(this._service);
  final OrderService _service;

  OrderState _state = const OrderIdle();
  OrderState get state => _state;

  Future<void> load() async {
    _state = const OrderLoading();
    notifyListeners();
    try {
      final orders = await _service.fetchAll();
      _state = OrderLoaded(orders.first);
    } on AppException catch (e) {
      _state = OrderFailed(userMessage(e));
    }
    notifyListeners();
  }
}
```

```dart
// The screen:
Widget build(BuildContext context) {
  final state = context.watch<OrderListModel>().state;
  return Scaffold(
    appBar: AppBar(title: const Text('OrderFlow')),
    body: switch (state) {
      OrderIdle() => const EmptyState(message: 'Pull down to load'),
      OrderLoading() => const Center(child: CircularProgressIndicator()),
      OrderLoaded(:final order) => OrderView(order: order),
      OrderFailed(:final message) => ErrorView(
          message: message,
          onRetry: () => context.read<OrderListModel>().load(),
        ),
    },
  );
}
```

> **Imports needed:** `dart:io` for `SocketException`, `dart:async` for
> `TimeoutException`, `dart:convert` for `jsonDecode`.

---

# Appendix B · Lab 8.2

### Starter

```dart
// LAB 8.2 - make it survive a restart
// flutter pub add shared_preferences

// TODO 1: an abstract class OrderRepository with
//           Future<List<Order>> load()
//           Future<void> save(List<Order> orders)
// TODO 2: LocalOrderRepository implements it using
//         SharedPreferences and jsonEncode / jsonDecode
// TODO 3: register it with Provider
// TODO 4: give OrderModel the repository, load in a method
//         called at startup, and save after every change
// TODO 5: run the app, add two lines, kill it completely and
//         reopen it. The lines should still be there
// TODO 6: also persist the theme seed colour and the theme mode
// TODO 7: handle the first-run case, without crashing
// TODO 8 (stretch): add a lastSavedAt timestamp
```

### Solution

```dart
abstract class OrderRepository {
  Future<List<Order>> load();
  Future<void> save(List<Order> orders);
}

class LocalOrderRepository implements OrderRepository {
  static const _key = 'orders';

  @override
  Future<List<Order>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];            // first run
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];                           // corrupt, start clean
    }
  }

  @override
  Future<void> save(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(orders.map((o) => o.toJson()).toList()),
    );
  }
}

class OrderModel extends ChangeNotifier {
  OrderModel(this._repository);
  final OrderRepository _repository;

  Order _order = const Order(id: 'ORD-1042', customer: 'Acme Ltd', lines: []);

  Order get order => _order;
  int get itemCount => _order.itemCount;
  bool get isEmpty => _order.lines.isEmpty;

  Future<void> restore() async {
    final saved = await _repository.load();
    if (saved.isNotEmpty) _order = saved.first;
    notifyListeners();
  }

  Future<void> addLine(OrderLine line) async {
    _order = _order.copyWith(lines: [..._order.lines, line]);
    notifyListeners();
    await _repository.save([_order]);
  }

  Future<void> removeLine(OrderLine line) async {
    _order = _order.copyWith(
      lines: _order.lines.where((l) => l != line).toList(),
    );
    notifyListeners();
    await _repository.save([_order]);
  }
}
```

```dart
// main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<OrderRepository>(create: (_) => LocalOrderRepository()),
        ChangeNotifierProvider(
          create: (context) =>
              OrderModel(context.read<OrderRepository>())..restore(),
        ),
      ],
      child: const OrderFlowApp(),
    ),
  );
}
```

> **Note the order:** `notifyListeners()` **first** so the screen updates
> immediately, then save to disk. The user should never wait for a write.

---

# Appendix C · Lab 8.3

### Starter

```dart
// LAB 8.3 - tests

// TODO 1: test/order_test.dart
//         group('Order') with tests for
//           itemCount sums the quantities
//           subtotal multiplies and adds
//           copyWith does not change the original
//           an empty order has a subtotal of zero
// TODO 2: test the discount bands from Day 3 at the
//         boundaries: 9999, 10000, 49999, 50000
// TODO 3: test/order_model_test.dart with a FakeOrderService
//         that can be told to fail
// TODO 4: test/order_screen_test.dart, a widget test
// TODO 5: run flutter test and get everything green
// TODO 6: BREAK SOMETHING on purpose and confirm a test catches it
// TODO 7: flutter test --coverage
```

### Solution

```dart
// test/order_test.dart
void main() {
  group('Order', () {
    const line1 = OrderLine(
        sku: 'SKU-1', description: 'a', quantity: 40, unitPrice: 250);
    const line2 = OrderLine(
        sku: 'SKU-2', description: 'b', quantity: 10, unitPrice: 120);

    test('itemCount sums the quantities', () {
      const order =
          Order(id: 'ORD-1', customer: 'Acme', lines: [line1, line2]);
      expect(order.itemCount, 50);
    });

    test('subtotal multiplies and adds', () {
      const order =
          Order(id: 'ORD-1', customer: 'Acme', lines: [line1, line2]);
      expect(order.subtotal, 11200.0);
    });

    test('an empty order has a subtotal of zero', () {
      const order = Order(id: 'ORD-1', customer: 'Acme', lines: []);
      expect(order.subtotal, 0.0);
    });

    test('copyWith does not change the original', () {
      const original = Order(id: 'ORD-1', customer: 'Acme', lines: []);
      final copy = original.copyWith(status: OrderStatus.submitted);
      expect(original.status, OrderStatus.draft);
      expect(copy.status, OrderStatus.submitted);
    });
  });

  group('discount bands', () {
    double discountFor(double subtotal) =>
        subtotal >= 50000 ? 0.10 : subtotal >= 10000 ? 0.05 : 0.0;

    test('below 10000 there is no discount', () {
      expect(discountFor(9999), 0.0);
    });
    test('at exactly 10000 the discount starts', () {
      expect(discountFor(10000), 0.05);
    });
    test('just below 50000 it is still five per cent', () {
      expect(discountFor(49999), 0.05);
    });
    test('at exactly 50000 it becomes ten per cent', () {
      expect(discountFor(50000), 0.10);
    });
  });
}
```

```dart
// test/order_model_test.dart
class FakeOrderService implements OrderService {
  FakeOrderService({this.shouldFail = false});
  final bool shouldFail;

  @override
  Future<List<Order>> fetchAll() async {
    if (shouldFail) throw const NoConnectionException();
    return const [Order(id: 'ORD-1', customer: 'Acme', lines: [])];
  }
}

void main() {
  test('load moves through loading to loaded', () async {
    final model = OrderListModel(FakeOrderService());
    final seen = <Type>[];
    model.addListener(() => seen.add(model.state.runtimeType));

    await model.load();

    expect(seen, [OrderLoading, OrderLoaded]);
  });

  test('a connection failure becomes a readable message', () async {
    final model = OrderListModel(FakeOrderService(shouldFail: true));
    await model.load();
    expect(model.state, isA<OrderFailed>());
    expect((model.state as OrderFailed).message, contains('offline'));
  });
}
```

> **The boundary tests in the second group are the most valuable four tests in the
> file.** Off-by-one at a band boundary is the classic pricing bug and it is
> invisible to manual testing.

---

# Appendix D · Release checklist

| Step | What to do | Watch out for |
|---|---|---|
| Test in release | `flutter run --release` | Things that work in debug can fail in release |
| Version | `version: 1.0.0+1` in pubspec | **The build number MUST increase every upload** |
| Application id | `applicationId` in build.gradle | **It can never be changed after publishing** |
| Icons | `flutter_launcher_icons` | Supply a 1024 square source image |
| Splash | `flutter_native_splash` | Keep it simple. It shows before your code runs |
| Permissions | Android manifest, iOS Info.plist | Each one needs a reason at review |
| **Keystore** | `keytool -genkey ...` | **LOSE IT AND YOU CANNOT UPDATE, EVER. Back it up** |
| Play App Signing | Let Google hold the app key | Recommended. The upload key can be reset |
| Bundle | `flutter build appbundle --release` | Not an APK, for Google Play |
| Size | `--analyze-size --target-platform android-arm64` | The engine is a 15–20 MB floor |
| Obfuscation | `--obfuscate --split-debug-info=...` | Keep the symbols or crash reports are unreadable |
| Crash reporting | Crashlytics or Sentry | Add it before launch, not after the first crash |
| Store listing | Screenshots, description, privacy policy | **A privacy policy URL is mandatory on both stores** |
| iOS | Mac, Apple Developer account, Xcode | Everything different is Apple's process, not Flutter's |

---

# Appendix E · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `FormatException: Unexpected character` | Parsing an error page as JSON | Check `statusCode` before decoding |
| `type int is not a subtype of double` | JSON number cast straight to double | `(json[k] as num).toDouble()` |
| Connection refused from the emulator | Used `localhost` | **The host machine is `10.0.2.2`** |
| `SocketException` on the web build | `dart:io` is not available on web | Guard it, or check the platform |
| `Null check operator used on a null value` | A field was missing from the JSON | Use `as String?` and a default |
| `part` file not found | Generator has not run yet | `dart run build_runner build --delete-conflicting-outputs` |
| Data does not survive a restart | Tested with hot restart, not a real kill | Swipe the app away and reopen it |
| `getInstance` errors at startup | Called before the bindings are ready | `WidgetsFlutterBinding.ensureInitialized()` in `main` |
| Stored data crashes on load | Format changed between versions | Catch `FormatException` and start clean |
| `No Directionality widget found` in a test | No `MaterialApp` around the widget | Wrap it in `MaterialApp` in `pumpWidget` |
| A widget test fails intermittently | `pump` where `pumpAndSettle` was needed | Use `pumpAndSettle` after animations |
| `flutter test` finds nothing | Wrong file name or folder | Must end in `_test.dart`, under `test/` |
| Release build crashes, debug is fine | Assertion doing real work, or lazy init | Test release builds before shipping |
| Store rejects the upload | Build number not increased | Raise the number after the `+` |

---

# Appendix F · Links

| Topic | Link |
|---|---|
| Fetch data from the internet | https://docs.flutter.dev/cookbook/networking/fetch-data |
| `http` package | https://pub.dev/packages/http |
| JSON and serialization | https://docs.flutter.dev/data-and-backend/serialization/json |
| `json_serializable` | https://pub.dev/packages/json_serializable |
| `shared_preferences` | https://pub.dev/packages/shared_preferences |
| `sqflite`, for later | https://pub.dev/packages/sqflite |
| Testing overview | https://docs.flutter.dev/testing/overview |
| Widget testing | https://docs.flutter.dev/cookbook/testing/widget/introduction |
| `mocktail` | https://pub.dev/packages/mocktail |
| DevTools | https://docs.flutter.dev/tools/devtools/overview |
| Performance best practices | https://docs.flutter.dev/perf/best-practices |
| Accessibility | https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility |
| Build and release for Android | https://docs.flutter.dev/deployment/android |
| Build and release for iOS | https://docs.flutter.dev/deployment/ios |
| Continuous delivery | https://docs.flutter.dev/deployment/cd |
