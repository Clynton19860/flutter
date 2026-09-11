# Day 3 · Dart Advanced — Delegate Handbook

**Flutter for Java Developers · 8-Day Programme · Day 3 of 8**

Generics · Records · Sealed classes and patterns · Extensions and mixins

> **Yesterday was translation. Today is the opposite:** four features where Java
> either has nothing, or has something much heavier.
>
> **Sealed classes and pattern matching are the single most important idea on
> this course.** Every screen you build from Day 5 onward is a switch over a
> sealed state. If you take one thing home from this week, make it that.

---

## Today's agenda

| | Time | Block |
|---|---|---|
| 1 | 09:00 – 10:30 | **Generics** — why type parameters exist, generic classes and functions, bounds, reified generics |
| 2 | 10:45 – 12:30 | **Records** — positional and named, returning several values, destructuring, **Lab 3.1** |
| 3 | 13:15 – 14:45 | **Sealed classes and patterns** — the problem with boolean flags, `sealed`, exhaustive switch, object patterns and guards, **Lab 3.2** |
| 4 | 15:00 – 16:00 | **Extensions and mixins** — extension methods, mixins and when not to use one, **Lab 3.3** |

> **Before you start:** paste your Day 2 `Order`, `OrderLine` and `OrderStatus`
> into a fresh DartPad. All three labs build on them.

---

# Module 1 · Generics

**09:15 – 10:30**

By the end of this module you can:

- Explain what a type parameter buys you
- Write a generic class and a generic function
- Constrain a type parameter with `extends`
- Know how Dart generics differ from Java generics

> You know all of this. It is here so that when you see `Future<List<Order>>` on
> Day 5 it reads as ordinary rather than as noise. **There are two places where
> Dart is different, and both are simpler than Java.**

## Why generics, and the one big difference

```dart
// Without generics you lose the type and have to cast back.
// This is Java before 1.5, and it is why generics exist.
List things = [];          // List<dynamic> - anything goes in
things.add('SKU-1');
things.add(42);            // no complaint
// String s = things[0];   // runtime failure waiting to happen

// With generics the compiler knows, and checks, every element.
List<String> skus = [];
skus.add('SKU-1');
// skus.add(42);           // COMPILE ERROR

// Generics are erased at runtime in Java. In Dart they are
// REIFIED, which means the type survives into the running program:
print(skus.runtimeType);          // List<String>
print(skus is List<String>);      // true
print(skus is List<int>);         // false
```

**Reification is the headline.** In Java, type arguments are erased at compile
time — at runtime a `List<String>` and a `List<Integer>` are the same class,
which is why you cannot test for one, cannot create an array of a generic type,
and cannot overload on a type parameter.

**In Dart the type survives.** `skus.runtimeType` prints `List<String>`, and
`skus is List<String>` compiles and returns `true`. In Java,
`skus instanceof List<String>` will not even compile.

A lot of the awkwardness Java developers associate with generics comes from
erasure, and most of it simply is not here.

> **Is there a raw type?** No. There is `dynamic`, which turns off checking
> entirely, and we will not use it once this week.

## Generic classes

```dart
// A generic class. T is a placeholder for a real type.
class Box<T> {
  Box(this.value);
  final T value;
  T get item => value;
  bool holds(Object? other) => value == other;
}

final skuBox = Box<String>('SKU-1');
final qtyBox = Box<int>(40);
final inferred = Box('SKU-2');        // T is inferred as String
print(skuBox.item.toUpperCase());     // the compiler knows it is a String

// A generic class with two type parameters
class Pair<K, V> {
  const Pair(this.key, this.value);
  final K key;
  final V value;

  @override
  String toString() => '($key, $value)';
}

final line = Pair<String, int>('SKU-1', 40);

// A generic result type
class Result<T> {
  const Result.success(this.value) : error = null;
  const Result.failure(this.error) : value = null;
  final T? value;
  final String? error;
  bool get isSuccess => error == null;
}
```

The syntax is identical to Java. Type inference means you rarely write the
argument at the call site — `Box('SKU-2')` infers `T` as `String`. Java has the
diamond operator for this; Dart just does it.

Letter conventions are the same as Java: `T` for a general type, `K` and `V` for
a map, `E` for an element, `R` for a result.

> **`Result<T>` works, and it is what you would write in Java.** This afternoon
> you will see a better way to express exactly this, using a sealed class.

## Generic functions and methods

```dart
// A generic FUNCTION. The type parameter goes after the name.
T firstOr<T>(List<T> items, T fallback) {
  return items.isEmpty ? fallback : items.first;
}

print(firstOr<String>(['SKU-1'], 'NONE'));
print(firstOr([], 0));                   // T inferred as int

// A generic method on a class
class Repository<T> {
  final List<T> _items = [];
  void add(T item) => _items.add(item);
  List<T> all() => List.unmodifiable(_items);

  // A method with its OWN type parameter, independent of T
  List<R> mapAll<R>(R Function(T) transform) =>
      _items.map(transform).toList();
}

final repo = Repository<OrderLine>();
final skus = repo.mapAll<String>((line) => line.sku);
```

**The position is the difference.** Java writes `public <T> T firstOr(...)`.
Dart writes `T firstOr<T>(...)`. Same meaning, different place.

**A method with its own type parameter** is the bit worth slowing down for. In
`Repository<T>`, `mapAll<R>` introduces `R`, independent of `T`. That is what
lets one class transform into another type.

> **This retroactively explains yesterday.** Every collection method you used is
> a generic method. `map<R>` is why `lines.map((l) => l.sku)` gives you an
> `Iterable<String>` from a `List<OrderLine>`.
>
> **And `fold<double>` finally makes sense.** `fold` has its own type parameter,
> and inference sometimes picks `num` instead of `double`. That is why you always
> write the type argument.

## Bounds, and no wildcards

```dart
// A BOUND restricts what T can be. Java: <T extends Number>
class Ledger<T extends num> {
  final List<T> _amounts = [];
  void add(T amount) => _amounts.add(amount);

  // Because T is a num, we can do arithmetic on it
  double get total => _amounts.fold<double>(0, (sum, a) => sum + a);
}

final l = Ledger<double>();
l.add(250.0);
// final bad = Ledger<String>();   // COMPILE ERROR: String is not a num

// Bounding on your own type works the same way
abstract class Identifiable {
  String get id;
}

class Store<T extends Identifiable> {
  final Map<String, T> _byId = {};
  void save(T item) => _byId[item.id] = item;   // .id is available
  T? find(String id) => _byId[id];
}
```

**Bounds are identical to Java.** Inside the class you can use whatever the bound
provides.

**No wildcards, and this is the second real difference.** Java has `? extends T`
and `? super T` because Java generics are **invariant**: a `List<String>` is
*not* a `List<Object>`.

**In Dart, a `List<String>` *is* a `List<Object>`.** Generics are covariant by
default. That removes the need for wildcards entirely — and the PECS rule with
them.

> **The cost, honestly:** covariance is less safe. You can pass a `List<String>`
> where a `List<Object>` is expected and then try to add an `int`, which compiles
> and throws at runtime. In practice it rarely bites, because most Dart
> collections you pass around are read from rather than written to.

**The practical summary:** bounds yes, wildcards no, and if you find yourself
reaching for PECS, you do not need it here.

## The generic types you will actually meet

```dart
List<String>                  // an ordered collection
Set<String>                   // no duplicates
Map<String, int>              // key to value
Iterable<String>              // anything you can loop over
Future<Order>                 // a value that arrives later
Stream<Order>                 // many values that arrive over time
Comparable<Order>             // has a compareTo

// Nested generics read inside out, same as Java
Future<List<Order>>           // later, you will get a list of orders
Map<String, List<OrderLine>>  // sku to the lines that use it

// Flutter ones you meet from Day 5
List<Widget>                  // the children of a Row or Column
Future<void>                  // an async job with no result
ValueChanged<String>          // a callback taking a String
```

**Reading inside out is the only skill that matters.** Say it in words:
`Future<List<Order>>` is "later, you will get a list of orders".
`Map<String, List<OrderLine>>` is "sku to the lines that use it".

`List<Widget>` is the one you will type most from Day 5 — the children of every
`Row` and `Column` — and yesterday's collection-for is how you build one.

`Future<void>` is Java's `CompletableFuture<Void>`. `ValueChanged<String>` is a
Flutter type alias for `void Function(String)`.

---

# Module 2 · Records

**10:45 – 12:30**

By the end of this module you can:

- Write positional and named records
- Return several values from a function without declaring a class
- Destructure a record in a declaration, a loop and a pattern
- Decide when a record is right and when you want a class

> You have all written a small class whose only job was to carry three values out
> of one method, and you have all named it something you were not happy with.
> **This is the feature that fixes that.**

## Records: positional and named

```dart
// POSITIONAL: the fields have no names, just positions
(String, int) firstLine() => ('SKU-1', 40);
final line = firstLine();
print(line.$1);          // SKU-1   - dollar one, dollar two
print(line.$2);          // 40

// NAMED: much more readable, and what you should prefer
({String sku, int quantity}) namedLine() => (sku: 'SKU-1', quantity: 40);
final l = namedLine();
print(l.sku);
print(l.quantity);

// MIXED
(String, {int quantity}) mixed() => ('SKU-1', quantity: 40);

// The type IS the shape. Two records with the same field names
// and types are the same type, with no declaration anywhere.
({String sku, int quantity}) a = (sku: 'SKU-1', quantity: 40);
({String sku, int quantity}) b = (sku: 'SKU-1', quantity: 40);
print(a == b);          // true - equality is structural and free
```

**If you know Java 16 records, be precise about the difference:** a Java record
is a **named class you declare**. A Dart record is **anonymous and structural**,
with no declaration anywhere.

- **Positional records** give you `$1` and `$2` accessors. They exist, they are
  unreadable, and you should steer away from them.
- **Named records are the useful form.** The type is written as a set of named
  fields in brackets.
- **Structural typing is the key idea.** Any record with a `sku` String and a
  `quantity` int *is* that type. Nothing imported, nothing registered.
- **Equality is free and structural.** After yesterday, where you wrote `==` and
  `hashCode` by hand, that lands well.

> **The syntax trap:** a single positional record needs a trailing comma —
> `(42,)`, not `(42)`. Without the comma it is just a bracketed expression.

## Returning several values

```dart
// The classic use: a function that needs to return more than
// one thing, without you inventing a class for it.
({double subtotal, double discount, double vat, double total})
    calculateTotal(Order order) {
  final subtotal = order.lines.fold<double>(0, (s, l) => s + l.lineTotal);
  final rate = subtotal >= 50000 ? 0.10 : subtotal >= 10000 ? 0.05 : 0.0;
  final discount = subtotal * rate;
  final vat = (subtotal - discount) * 0.15;
  return (
    subtotal: subtotal,
    discount: discount,
    vat: vat,
    total: subtotal - discount + vat,
  );
}

final t = calculateTotal(order);
print(t.total);

// A record as a map key works, because equality is structural
final cache = <({String sku, int qty}), double>{};
cache[(sku: 'SKU-1', qty: 40)] = 10000;
```

**The Java version:** declare a small class or record, pick a name for it, decide
which package it lives in, write the constructor and the getters, import it
wherever it is used. This replaces all of that — the shape is written where it is
used.

> **The nested ternary for the rate band is deliberately ugly.** This afternoon
> you will rewrite it as a switch with guards, and it will read far better.

**The one gotcha:** the return type on a function returning a named record is
long. A `typedef` can name it if it starts to hurt.

## Destructuring

```dart
// DESTRUCTURING pulls a record apart into variables.
final (sku, qty) = ('SKU-1', 40);
print(sku);
print(qty);

// Named records destructure by field name
final (sku: s, quantity: q) = (sku: 'SKU-1', quantity: 40);

// Shorthand when the variable name matches the field name
final (:sku, :quantity) = (sku: 'SKU-1', quantity: 40);
print(sku);
print(quantity);

// In a for loop, over a list of records
final lines = [('SKU-1', 40), ('SKU-2', 10)];
for (final (sku, qty) in lines) {
  print('$sku x $qty');
}

// Over map entries, which destructure as a pair
final stock = {'SKU-1': 12, 'SKU-2': 0};
for (final MapEntry(key: sku, value: qty) in stock.entries) {
  print('$sku has $qty');
}

// Swapping two variables, with no temporary
var a = 1;
var b = 2;
(a, b) = (b, a);
print('$a $b');          // 2 1
```

The colon-with-nothing-in-front shorthand, `final (:sku, :quantity)`, looks alien
for about a day.

> **This is the bridge to the afternoon.** Everything you just learned about
> pulling values out of a shape is the **same machinery that runs inside
> `switch`**. Patterns are one idea used in several places, and you have just met
> the easy one.

## Record or class?

| Use a **record** when | Use a **class** when |
|---|---|
| The grouping has no name in the business domain | The thing has a name a business person would recognise |
| It is a return value rather than something stored | It needs methods or validation |
| You need it in one or two places | It will be stored or serialised |
| Structural equality is what you want | You want to control its equality |

- **The naming test is the best one.** If you found it hard to name the class,
  that is a signal there is no concept there, only a shape. `OrderTotals`,
  `TotalsResult`, `CalculationOutput` — everyone has written one of those and
  been faintly unhappy.
- **The three-places rule.** If you write the same record shape in three
  different places, it wanted to be a class. Write the class.
- **What records cannot do:** no methods, no inheritance, no abstract, no private
  fields. They are data and nothing else, by design. **This limitation is what
  stops records eating your domain model.**

**In our app:** `Order`, `OrderLine` and `Product` are classes, because the
business names all three. The four totals that `calculateTotal` returns are a
record, because nobody calls them anything.

> **A record is a shape. A class is a concept.**

---

## LAB 3.1 · Generics and records · 35 min

**Goal** — a generic `Box`, a generic function, a bounded `Store` keyed by id,
and `calculateTotal` returning a named record that you destructure.

1. Fresh pad. **Paste in your Day 2 `Order`, `OrderLine` and `OrderStatus`
   first**, then the starter from **Appendix A**.
2. **TODO 1–2:** the generic `Box` class and the generic `firstOr` function.
3. **TODO 3:** declare `abstract class Identifiable`, make `Order` implement it,
   and write `Store<T extends Identifiable>`.
4. **TODO 4:** `calculateTotal`, returning a named record of four doubles.
5. **TODO 5:** destructure the result with the colon shorthand and print each.
6. **TODO 6:** loop over a list of two-value records and print each.
7. **TODO 7:** save the order in your `Store`, read it back by id, print totals.

> **The nice moment is TODO 3.** `Order` already has a `String id`, so
> `implements Identifiable` requires **no extra code whatsoever**. That is
> yesterday's implicit interfaces paying off immediately.

**Expected totals:** subtotal `11650.00`, discount `582.50`, VAT `1660.13`,
total `12727.63`.

### Common errors

- Forgetting `fold<double>` again.
- Writing `Store<Order>` before `Order` implements `Identifiable`.
- Destructuring with the wrong field names — a compile error, and a good one.
- Trying to give the record a method.

### Stretch

- Make `Store` also hold a `count` and a `findAll` returning an unmodifiable list.
- Try to create a `Store<String>`. Read the error and explain it to your neighbour.
- Add a `typedef` for the totals record type and decide whether it reads better.

---

# Module 3 · Sealed classes and pattern matching

**13:15 – 14:45**

By the end of this module you can:

- Explain why a set of boolean flags is a bad way to model state
- Declare a sealed class hierarchy and know what `sealed` guarantees
- Write an exhaustive switch expression with no `default` branch
- Use object patterns, guards and `if-case`

> **The most important ninety minutes of the entire course.**

## The problem: four booleans, sixteen combinations, four legal

```dart
// THE PROBLEM. An order flow has four possible situations, and
// every screen has to handle all four. In Java you reach for
// flags, and the flags can contradict each other.
class OrderScreenState {
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  Order? order;
}
```

**What does this mean?** `isLoading = true`, `hasError = true`, `order = something`.

It is nonsense — but nothing stops you creating it, and every screen has to
defend against it. **Four booleans is sixteen combinations. Four are legal.
Twelve are bugs waiting for a rainy Tuesday**, and nothing in the type system
stops any of them.

Everyone has a class with `isLoading` and `hasError` in it. Everyone has written
an `if` that checks `isLoading` first because the order of checks accidentally
matters. **That accidental ordering is the bug.**

**The other half of the problem is the data.** `errorMessage` is nullable because
it only exists sometimes. `order` is nullable for the same reason. So every read
needs a null check, forever, in every screen.

> **The goal: make the illegal states impossible to write down**, rather than
> defending against them.

## `sealed`: the compiler knows every subtype

```dart
// sealed means: the compiler knows EVERY subtype, because they
// must all live in this same file.
sealed class OrderState {
  const OrderState();
}

class OrderIdle extends OrderState {
  const OrderIdle();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  const OrderLoaded(this.order);
  final Order order;
}

class OrderFailed extends OrderState {
  const OrderFailed(this.message);
  final String message;
}

// You cannot create a sealed class itself:
// final bad = OrderState();     // COMPILE ERROR
```

**What `sealed` means:** every direct subtype must be in the same file. Because
of that, the compiler knows the complete list and can check you handled all of
them. **That is the entire feature.**

**Why the same file?** It is the only way the compiler can be certain nobody
added a fifth subtype elsewhere. Java 17 uses a `permits` clause for the same
reason; Dart chose the file boundary — which is consistent with privacy being by
file.

> **The data point is as important as the exhaustiveness.** Look at what each
> class carries. `OrderLoaded` has an order, and it is **not nullable**, because
> if you have an `OrderLoaded` you definitely have an order. `OrderFailed` has a
> message and no order. Sixteen combinations became four, and **every field is
> non-nullable**.
>
> The nullable fields are gone. That is not a side effect — it is the main
> benefit. Every null check on every screen disappears.

Three of these four states carry no data, so they are compile-time constants and
Flutter reuses one instance of each. That is why we write `const` constructors.

## Exhaustive switch expressions

```dart
// A switch EXPRESSION returns a value, so you can use it
// anywhere a value is expected. Note the commas, not colons,
// and the absence of break.
String describe(OrderState s) => switch (s) {
      OrderIdle() => 'Start a new order',
      OrderLoading() => 'Submitting...',
      OrderLoaded(:final order) => 'Order ${order.id} accepted',
      OrderFailed(:final message) => 'Failed: $message',
    };

// The old switch STATEMENT still exists and still works:
void describeOld(OrderState s) {
  switch (s) {
    case OrderIdle():
      print('Start a new order');
    case OrderLoaded(:final order):
      print('Order ${order.id}');
    default:
      print('Something else');
  }
}
```

**There is no `default` branch, and that is the point.** In Java you write a
default branch, usually throwing, because the compiler cannot help you. Here
there is no default, because the compiler knows the four subtypes and checks all
four are handled.

> **Try this.** Add a fifth class, `OrderCancelled`, to the hierarchy. Save.
> `describe` turns red. Read the error. Then add the branch and watch it go green.
>
> **In a system with forty screens, adding a state means the compiler shows you
> every one of the forty places you have to think about.** Not a test, not a code
> review, not a bug report from production. The compiler, before you commit.

**Prefer the expression form.** It returns a value, it forces exhaustiveness, and
it cannot fall through.

## Object patterns

```dart
// OBJECT PATTERNS match a type and pull fields out at the same
// time. The colon-final syntax binds a field to a variable.
String summarise(OrderState s) => switch (s) {
      OrderLoaded(:final order) => 'Order ${order.id}',
      OrderFailed(:final message) => 'Error: $message',
      _ => 'Nothing yet',
    };

// You can rename the variable
String rename(OrderState s) => switch (s) {
      OrderFailed(message: final why) => 'Error: $why',
      _ => '',
    };

// You can match nested fields
String customerOf(OrderState s) => switch (s) {
      OrderLoaded(order: Order(:final customer)) => customer,
      _ => 'unknown',
    };

// You can match on a literal value inside the pattern
String special(OrderState s) => switch (s) {
      OrderLoaded(order: Order(customer: 'Acme Ltd')) => 'Key account',
      OrderLoaded() => 'Standard account',
      _ => '',
    };
```

`OrderLoaded(:final order)` means "if this is an `OrderLoaded`, bind its `order`
field to a variable called `order`". The colon with nothing in front is shorthand
for "same name as the field".

**Compare to Java 8:** `instanceof`, then a cast, then a field access, on three
lines, with a variable you had to name. Here it is one pattern, and the variable
arrives typed and non-null.

**Nested patterns** reach two levels down in one expression. Do not go three
levels deep — readability falls off fast.

> **Order matters.** The first matching branch wins, so the specific case must
> come before the general one. Put `OrderLoaded()` above the Acme case and the
> specific branch becomes unreachable — the analyser will tell you so.

## Guards, value patterns, and `if-case`

```dart
// GUARDS add a condition to a pattern with `when`.
String band(Order o) => switch (o) {
      Order(:final subtotal) when subtotal >= 50000 => 'platinum',
      Order(:final subtotal) when subtotal >= 10000 => 'gold',
      _ => 'standard',
    };

// Patterns on plain values: literals, ranges and or-patterns
String size(int qty) => switch (qty) {
      0 => 'none',
      1 || 2 => 'small',
      >= 3 && < 10 => 'medium',
      _ => 'bulk',
    };

// Patterns on records
String shape((int, int) point) => switch (point) {
      (0, 0) => 'origin',
      (final x, 0) => 'on the x axis at $x',
      (0, final y) => 'on the y axis at $y',
      (final x, final y) => 'at $x, $y',
    };

// if-case, for when you only care about one shape
void handle(OrderState s) {
  if (s case OrderFailed(:final message)) {
    print('Only failures reach here: $message');
  }
}
```

**This is where this morning's nested ternary gets its revenge.** Put the
discount band as a nested ternary next to the switch with guards and ask which
one you would rather review.

**Value patterns** on a plain `int` — literals, or-patterns with `||`, ranges with
`>=` and `<`, combined with `&&`. The `size` function reads like a specification
rather than like code.

> **The underscore is the wildcard, and it turns exhaustiveness checking OFF for
> the remaining cases.** An underscore in a sealed switch is you telling the
> compiler to stop helping. Sometimes right, often lazy. `canRetry` uses it
> correctly, because it genuinely only cares about one case.

## The complete pattern

```dart
sealed class OrderState {
  const OrderState();
}

class OrderIdle extends OrderState {
  const OrderIdle();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  const OrderLoaded(this.order);
  final Order order;
}

class OrderFailed extends OrderState {
  const OrderFailed(this.message);
  final String message;
}

String describe(OrderState s) => switch (s) {
      OrderIdle() => 'Start a new order',
      OrderLoading() => 'Submitting...',
      OrderLoaded(:final order) =>
        'Order ${order.id} accepted, ${order.itemCount} items',
      OrderFailed(:final message) => 'Failed: $message',
    };

bool canRetry(OrderState s) => switch (s) {
      OrderFailed() => true,
      _ => false,
    };
```

> **This exact shape appears on every screen from Day 5 onwards.** The screen
> watches this state and renders a different widget per case: Idle shows a
> prompt, Loading shows a spinner, Loaded shows the order, Failed shows an error
> with a retry button. Four states, four widgets, and **the compiler will not let
> anyone forget the error case**.
>
> In most codebases the loading spinner is forgotten on at least one screen, and
> the error case is a silent failure. This makes both impossible.

**Keep this pad.** Lab 3.2 extends it and Day 5 uses it.

---

## LAB 3.2 · The order state model · 35 min

**Goal** — a sealed `OrderState` with four subtypes, an exhaustive `describe`, a
guarded `band` function, and value patterns. Then break it on purpose.

1. Continue in the same pad. Copy the starter from **Appendix B**.
2. **TODO 1:** the sealed `OrderState` and its four subtypes, **all in the same
   file**.
3. **TODO 2:** `describe`, using a switch expression with **no default branch**.
4. **TODO 3:** `canRetry`, true only for the failed state.
5. **TODO 4:** `band`, using guards with `when` on the order subtotal.
6. **TODO 5:** `size`, using literal, or, and range patterns on an `int`.
7. **TODO 6:** loop over all four states and print `describe` and `canRetry`.
8. **TODO 7:** add a **fifth** state, `OrderCancelled`, and **do not touch
   `describe`**. Run it. Read the error. Then handle it.

> **Step 7 is not optional.** Everyone must add the fifth state, see the compile
> error, and read it. That thirty seconds is the argument for the whole
> architecture of the next five days.

### Common errors

- **Putting a `default` branch in** and then wondering why adding the fifth state
  did not break anything. That is the most instructive mistake available.
- Using a colon instead of an arrow.
- Forgetting the commas between branches.
- Writing `case OrderIdle:` with a colon — that is the statement form, inside an
  expression.

### Stretch

- Add a nested pattern matching only when the customer is Acme Ltd, and put it in
  the right position.
- Write a `retryable` getter using `if-case` instead of a switch and compare.
- Replace the wildcard in `canRetry` with all four explicit cases and argue which
  version you prefer.

---

# Module 4 · Extensions and mixins

**15:00 – 16:00**

By the end of this module you can:

- Add methods to a type you do not own, using an extension
- Write a generic extension
- Use a mixin to share behaviour across unrelated classes
- Choose between `extends`, `implements`, `with` and `extension`

## Extension methods

```dart
// An extension adds members to a type you did not write and
// cannot change. Java has NO equivalent.
extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
  double get withVat => this * 1.15;
  double percent(double p) => this * p / 100;
}

print(1250.0.rands);        // R 1250.00
print(1000.0.withVat);      // 1150.0
print(1000.0.percent(15));  // 150.0

extension SkuChecks on String {
  bool get isValidSku => RegExp(r'^SKU-\d{1,6}$').hasMatch(this);
  String get shortened => length <= 8 ? this : '${substring(0, 8)}...';
}

// Extensions work on your own types too
extension OrderReporting on Order {
  String get oneLine => '$id  $customer  ${lines.length} lines';
  bool get isLarge => itemCount > 100;
}
```

**The pitch:** every Java codebase has a `StringUtils`, a `DateUtils` and a
`MoneyUtils`. Every one reads backwards — `MoneyUtils.format(amount)` puts the
tool before the material. Extensions let you write `amount.rands`.

```
MoneyUtils.format(1250.0)      utility first, value second
1250.0.rands                   value first, operation second
```

Inside an extension, `this` refers to the value and you can usually omit it,
which is why `toStringAsFixed` appears with no receiver.

> **`Money on double` is a course convention.** Every amount on every screen from
> Day 5 is formatted with `.rands`.

### The four limits, and they matter

1. **No new fields** — there is nowhere to store them. Computed members only.
2. **No overriding an existing member** — the real one always wins.
3. **Resolved at compile time from the STATIC type.** An extension on `String`
   does not fire on a variable declared as `Object`.
4. **It must be imported to be visible.** This is the one that confuses people in
   a multi-file project.

Limit 3 is worth proving to yourself: declare `Object o = 'SKU-1'` and try
`o.isValidSku`. It does not compile. **Extensions are compile-time sugar, not
runtime dispatch.**

## Generic extensions

```dart
extension ListExtras<T> on List<T> {
  T? get secondOrNull => length < 2 ? null : this[1];
  List<T> get reversedCopy => [...this].reversed.toList();

  Map<K, List<T>> groupBy<K>(K Function(T) key) {
    final out = <K, List<T>>{};
    for (final item in this) {
      out.putIfAbsent(key(item), () => []).add(item);
    }
    return out;
  }
}

final byBand = lines.groupBy((l) => l.quantity >= 100 ? 'bulk' : 'standard');

// Extensions on a nullable type are allowed
extension StringOrEmpty on String? {
  String get orEmpty => this ?? '';
}
```

`groupBy` is worth writing because Java has `Collectors.groupingBy` and Dart
ships no equivalent. `putIfAbsent` creates the bucket on first use, then `add`
puts the item in. Five lines.

The method has its **own type parameter `K`**, independent of the extension's
`T` — this morning's generic method idea, applied.

> **The warning:** an extension is invisible until imported, so a team that
> scatters them across files gets a codebase where the same expression compiles
> in one file and not another. Keep them in a small number of well-named files.
> On this course, one file called `extensions.dart`.

## Mixins

```dart
// A mixin is reusable implementation WITHOUT inheritance.
// The closest Java thing is an interface with default methods,
// with one important difference: a mixin can hold state.
mixin Auditable {
  DateTime? _lastChanged;
  void touch() => _lastChanged = DateTime.now();
  Duration? get sinceChange => _lastChanged == null
      ? null
      : DateTime.now().difference(_lastChanged!);
}

mixin Describable {
  String get displayName;                 // abstract, must be provided
  String describe() => 'This is $displayName';
}

// `with` applies one or more mixins
class Basket with Auditable, Describable {
  final List<String> skus = [];

  @override
  String get displayName => 'Basket of ${skus.length}';

  void add(String sku) {
    skus.add(sku);
    touch();
  }
}

// `on` restricts where a mixin can be applied
mixin Timestamped on Auditable {
  String get stamp => _lastChanged?.toIso8601String() ?? 'never';
}
```

- **Unlike an interface with default methods, a mixin can declare and use its own
  fields** — that is what `_lastChanged` demonstrates.
- **A mixin can declare an abstract member**, as `Describable` does. The class
  using it must provide it.
- **Order matters, and this is the uncomfortable part.** With `with A, B`, the
  **later one wins** any conflict. Java's default methods refuse to compile on a
  conflict and make you resolve it explicitly. Dart resolves it silently by
  position.
- **`on`** restricts a mixin to classes that already have something — the mixin
  equivalent of a bound.

> **Where you will actually meet mixins:** Flutter uses them for lifecycle. On
> Day 7, animations need `SingleTickerProviderStateMixin`. That is very likely
> the only mixin you will apply all week.

**The advice:** prefer composition and extensions. Reach for a mixin when several
unrelated classes genuinely need the same **stateful** behaviour, which is rarer
than it sounds.

## `extends`, `implements`, `with`, `extension`: choosing

| Tool | Use when |
|---|---|
| **`extends`** | You want the parent's code and its identity, and it is a genuine is-a. One parent only. In Flutter you extend `StatelessWidget` and `StatefulWidget` and almost nothing else. |
| **`implements`** | You want the shape only, and will write every member yourself. Contracts, and test fakes that match a real class without inheriting from it. |
| **`with`** | You want the same stateful behaviour in several unrelated classes. Powerful, easy to overuse, conflict resolution is by position rather than by error. |
| **`extension`** | You want to add behaviour to a type you do not own, or to make a call site read in the right order. No state, no overriding, must be imported. |
| **None of the above** | Most of the time the answer is a plain function or a small class that takes the thing as a parameter. **Reach for the simple option first.** |

> **The Java instinct is to reach for inheritance. The Dart instinct, and the
> Flutter one, is to compose:** build the thing you want out of small pieces
> rather than deriving it from a base class.
>
> Flutter is composition all the way down — a padded, centred, coloured button is
> four widgets nested, not a subclass with four properties.

---

## LAB 3.3 · Making the code read well · 30 min

**Goal** — three extensions, a generic extension with `groupBy`, and a mixin,
applied to the order model you have been building for two days.

1. Continue in the same pad. Copy the starter from **Appendix C**.
2. **TODO 1:** `extension Money on double`, with `rands` and `withVat`.
3. **TODO 2:** `extension SkuChecks on String`, with `isValidSku` and `shortened`.
4. **TODO 3:** `extension OrderReporting on Order`, with `oneLine` and `isLarge`.
5. **TODO 4:** a generic `ListExtras` extension with a `groupBy` method.
6. **TODO 5–6:** the `Auditable` mixin and a `Basket` class that uses it.
7. **TODO 7–9:** print an order report using your extensions, group the lines,
   and exercise the `Basket`.

> **The regex will trip someone.** `RegExp(r'^SKU-\d{1,6}$')` is a **raw string**
> — the `r` before the quote is what stops the backslash being an escape.

### Stretch

- Add an extension on `OrderStatus` giving a colour name per status, and say why
  that belongs in an extension rather than on the enum. *(A colour is a
  presentation concern; the enum is domain. That is the
  domain-knows-nothing-about-the-UI rule, applied.)*
- Add `sumBy` to `ListExtras` so you can write `lines.sumBy((l) => l.lineTotal)`.
- Call one of your String extensions on a variable declared as `Object` and
  explain the error.

---

# Day 3 recap

- **Dart generics are reified**, so the type survives to runtime and you can test
  it. Bounds work as in Java; there are no wildcards.
- **A record groups values with no class to declare.** Named fields, structural
  equality, and a shape instead of a type name.
- **Destructuring** pulls a record apart — in a declaration, in a loop, or inside
  a switch.
- **A sealed class tells the compiler every subtype**, which makes a switch
  exhaustive and removes every nullable field from your state.
- **A switch expression** returns a value, has no default branch, and refuses to
  compile when you add a case and forget to handle it.
- **Object patterns** match a type and bind its fields in one step. **Guards** add
  a condition with `when`.
- **Extensions** add behaviour to types you do not own. **Mixins** share stateful
  behaviour, and should be used sparingly.
- **Composition over inheritance**, which is also the entire philosophy of Flutter.

**Tomorrow (Day 4 · Errors, Async and Isolates):** errors and exceptions,
`Future`, `async` and `await`, streams, isolates and why there are no threads,
and the order service end to end.

---

## Optional reading tonight · 15 min

The **"Patterns"** page, then **"Pattern types"** —
[dart.dev/language/patterns](https://dart.dev/language/patterns).

1. Find a pattern type we did not use today. What problem does it solve?
2. The docs distinguish **refutable** from **irrefutable** patterns. What is the
   difference, and where does each appear?
3. Find the list pattern with a rest element. Where would you use one in the
   order app?

---

# Appendix A · Lab 3.1

### Starter

```dart
// LAB 3.1 STARTER - dartpad.dev
// Paste your Day 2 Order, OrderLine and OrderStatus above this.

// TODO 1: a generic class Box<T> with a final value and a getter
// TODO 2: a generic function
//           T firstOr<T>(List<T> items, T fallback)
// TODO 3: a generic class Store<T extends Identifiable> that keeps
//         items in a Map<String, T> keyed by id.
//         First declare:  abstract class Identifiable { String get id; }
//         Then make Order implement it (its id field already fits).
// TODO 4: a top-level function returning a NAMED RECORD
//           ({double subtotal, double discount, double vat, double total})
//           calculateTotal(Order order)
//         subtotal = sum of line totals
//         discount = 10% at 50000 or more, 5% at 10000 or more, else 0
//         vat      = 15% of (subtotal - discount)
//         total    = subtotal - discount + vat
// TODO 5: destructure the result with final (:subtotal, :total) = ...
//         and print both
// TODO 6: loop over a list of (String, int) records and print each

void main() {
  // TODO 7: build the order from Day 2, store it in your Store,
  //         read it back by id, and print its totals
}
```

### Solution

```dart
abstract class Identifiable {
  String get id;
}

class Box<T> {
  const Box(this.value);
  final T value;
  T get item => value;
}

T firstOr<T>(List<T> items, T fallback) =>
    items.isEmpty ? fallback : items.first;

class Store<T extends Identifiable> {
  final Map<String, T> _byId = {};
  void save(T item) => _byId[item.id] = item;
  T? find(String id) => _byId[id];
  int get count => _byId.length;
}

({double subtotal, double discount, double vat, double total})
    calculateTotal(Order order) {
  final subtotal = order.lines.fold<double>(0, (s, l) => s + l.lineTotal);
  final rate = subtotal >= 50000
      ? 0.10
      : subtotal >= 10000
          ? 0.05
          : 0.0;
  final discount = subtotal * rate;
  final vat = (subtotal - discount) * 0.15;
  return (
    subtotal: subtotal,
    discount: discount,
    vat: vat,
    total: subtotal - discount + vat,
  );
}

void main() {
  print(Box<String>('SKU-1').item);
  print(firstOr<String>([], 'NONE'));

  final order = Order(
    id: 'ORD-1042',
    customer: 'Acme Ltd',
    lines: const [
      OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
      OrderLine(sku: 'SKU-2', description: 'Gasket', quantity: 10, unitPrice: 120),
      OrderLine(sku: 'SKU-3', description: 'Bracket', quantity: 5, unitPrice: 90),
    ],
  );

  final store = Store<Order>();
  store.save(order);
  final found = store.find('ORD-1042');
  print('Found ${found?.id}, ${found?.itemCount} items');

  final (:subtotal, :discount, :vat, :total) = calculateTotal(order);
  print('Subtotal  ${subtotal.toStringAsFixed(2)}');
  print('Discount  ${discount.toStringAsFixed(2)}');
  print('VAT       ${vat.toStringAsFixed(2)}');
  print('Total     ${total.toStringAsFixed(2)}');

  for (final (sku, qty) in [('SKU-1', 40), ('SKU-2', 10)]) {
    print('$sku x $qty');
  }
}
```

> `Order` must implement `Identifiable`. It already has a `String id` field, so
> `class Order implements Identifiable` needs **no extra code at all**.

### Expected totals

```
Subtotal  11650.00
Discount  582.50
VAT       1660.13
Total     12727.63
```

---

# Appendix B · Lab 3.2

### Starter

```dart
// LAB 3.2 STARTER - continue in the same pad

// TODO 1: a sealed class OrderState with four subtypes:
//           OrderIdle, OrderLoading,
//           OrderLoaded(Order order), OrderFailed(String message)
// TODO 2: String describe(OrderState s) using a switch EXPRESSION
//         with no default branch:
//           Idle     -> 'Start a new order'
//           Loading  -> 'Submitting...'
//           Loaded   -> 'Order ORD-1042 accepted, 55 items'
//           Failed   -> 'Failed: <message>'
// TODO 3: bool canRetry(OrderState s), true only for Failed
// TODO 4: String band(Order o) using a switch with GUARDS:
//           subtotal 50000 or more -> 'platinum'
//           subtotal 10000 or more -> 'gold'
//           otherwise              -> 'standard'
// TODO 5: String size(int qty) using literal, or, and range patterns:
//           0 -> 'none', 1 or 2 -> 'small',
//           3 to 9 -> 'medium', anything else -> 'bulk'

void main() {
  // TODO 6: loop over all four states and print describe and canRetry
  // TODO 7: add a FIFTH state, OrderCancelled, and DO NOT touch
  //         describe. Run it. Read the compile error carefully.
  //         Then handle it. That error is the point of this lab.
}
```

### Solution

*Shown with the fifth state already handled. Add it yourself and see the error
first.*

```dart
sealed class OrderState {
  const OrderState();
}

class OrderIdle extends OrderState {
  const OrderIdle();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  const OrderLoaded(this.order);
  final Order order;
}

class OrderFailed extends OrderState {
  const OrderFailed(this.message);
  final String message;
}

class OrderCancelled extends OrderState {
  const OrderCancelled(this.reason);
  final String reason;
}

String describe(OrderState s) => switch (s) {
      OrderIdle() => 'Start a new order',
      OrderLoading() => 'Submitting...',
      OrderLoaded(:final order) =>
        'Order ${order.id} accepted, ${order.itemCount} items',
      OrderFailed(:final message) => 'Failed: $message',
      OrderCancelled(:final reason) => 'Cancelled: $reason',
    };

bool canRetry(OrderState s) => switch (s) {
      OrderFailed() => true,
      _ => false,
    };

String band(Order o) => switch (o) {
      Order(:final subtotal) when subtotal >= 50000 => 'platinum',
      Order(:final subtotal) when subtotal >= 10000 => 'gold',
      _ => 'standard',
    };

String size(int qty) => switch (qty) {
      0 => 'none',
      1 || 2 => 'small',
      >= 3 && < 10 => 'medium',
      _ => 'bulk',
    };

void main() {
  final order = Order(
    id: 'ORD-1042',
    customer: 'Acme Ltd',
    lines: const [
      OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
      OrderLine(sku: 'SKU-2', description: 'Gasket', quantity: 10, unitPrice: 120),
      OrderLine(sku: 'SKU-3', description: 'Bracket', quantity: 5, unitPrice: 90),
    ],
  );

  final states = <OrderState>[
    const OrderIdle(),
    const OrderLoading(),
    OrderLoaded(order),
    const OrderFailed('stock unavailable'),
    const OrderCancelled('customer withdrew'),
  ];

  for (final s in states) {
    print('${describe(s).padRight(45)} retry: ${canRetry(s)}');
  }

  print('Band ${band(order)}');
  for (final q in [0, 2, 5, 200]) {
    print('$q -> ${size(q)}');
  }
}
```

---

# Appendix C · Lab 3.3

### Starter

```dart
// LAB 3.3 STARTER - continue in the same pad

// TODO 1: extension Money on double
//           String get rands       -> 'R 1250.00'
//           double get withVat     -> times 1.15
// TODO 2: extension SkuChecks on String
//           bool get isValidSku    -> matches SKU- followed by digits
//           String get shortened   -> first 8 chars plus '...' if longer
// TODO 3: extension OrderReporting on Order
//           String get oneLine     -> 'ORD-1042  Acme Ltd  3 lines'
//           bool get isLarge       -> itemCount over 100
// TODO 4: a generic extension ListExtras<T> on List<T> with
//           Map<K, List<T>> groupBy<K>(K Function(T) key)
// TODO 5: mixin Auditable with a private DateTime? field,
//         a touch() method and a sinceChange getter
// TODO 6: a class Basket that uses the mixin and records a
//         touch every time a sku is added

void main() {
  // TODO 7: print a formatted order report using your extensions
  // TODO 8: group the order lines into bulk and standard
  // TODO 9: add three skus to a Basket and print sinceChange
}
```

### Solution

```dart
extension Money on double {
  String get rands => 'R ${toStringAsFixed(2)}';
  double get withVat => this * 1.15;
}

extension SkuChecks on String {
  bool get isValidSku => RegExp(r'^SKU-\d{1,6}$').hasMatch(this);
  String get shortened => length <= 8 ? this : '${substring(0, 8)}...';
}

extension OrderReporting on Order {
  String get oneLine => '$id  $customer  ${lines.length} lines';
  bool get isLarge => itemCount > 100;
}

extension ListExtras<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) key) {
    final out = <K, List<T>>{};
    for (final item in this) {
      out.putIfAbsent(key(item), () => []).add(item);
    }
    return out;
  }
}

mixin Auditable {
  DateTime? _lastChanged;
  void touch() => _lastChanged = DateTime.now();
  Duration? get sinceChange => _lastChanged == null
      ? null
      : DateTime.now().difference(_lastChanged!);
}

class Basket with Auditable {
  final List<String> skus = [];
  void add(String sku) {
    skus.add(sku);
    touch();
  }
}

void main() {
  final order = Order(
    id: 'ORD-1042',
    customer: 'Acme Ltd',
    lines: const [
      OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
      OrderLine(sku: 'SKU-2', description: 'Gasket', quantity: 200, unitPrice: 15),
      OrderLine(sku: 'SKU-3', description: 'Bracket', quantity: 5, unitPrice: 90),
    ],
  );

  print(order.oneLine);
  print('Large order: ${order.isLarge}');
  print('Subtotal ${order.subtotal.rands}');
  print('With VAT ${order.subtotal.withVat.rands}');

  print('SKU-1 valid: ${'SKU-1'.isValidSku}');
  print('BADSKU valid: ${'BADSKU'.isValidSku}');
  print('SKU-123456789 short: ${'SKU-123456789'.shortened}');

  final grouped = order.lines.groupBy((l) => l.quantity >= 100 ? 'bulk' : 'standard');
  grouped.forEach((band, lines) {
    print('$band: ${lines.map((l) => l.sku).join(', ')}');
  });

  final basket = Basket()
    ..add('SKU-1')
    ..add('SKU-2')
    ..add('SKU-3');
  print('${basket.skus.length} items, changed '
      '${basket.sinceChange?.inMicroseconds} microseconds ago');
}
```

---

# Appendix D · Pattern cheat sheet

| Pattern | Looks like | Matches when |
|---|---|---|
| Object | `OrderLoaded(:final order)` | The value is that type. Binds the field |
| Object, renamed | `OrderFailed(message: final why)` | Same, with your own variable name |
| Object, nested | `OrderLoaded(order: Order(:final customer))` | Reaches two levels in one step |
| Record | `(final x, final y)` | The value is a record of that shape |
| Named record | `(:sku, :quantity)` | Binds by field name |
| Literal | `0` | The value equals that literal |
| Or | `1 \|\| 2` | Either branch matches |
| And | `>= 3 && < 10` | Both conditions hold |
| Relational | `>= 50000` | The comparison is true |
| Wildcard | `_` | Anything. **Turns off exhaustiveness** |
| Guard | `Order(:final subtotal) when subtotal > 100` | Shape matches **and** the condition holds |
| Cast | `order as Order` | Asserts the type inside a pattern |
| Null check | `final order?` | The value is not null, and binds it |
| if-case | `if (s case OrderFailed(:final message))` | One shape, without a switch |

---

# Appendix E · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `The type ... is not exhaustively matched` | A sealed subtype has no branch | Add the branch. **This is the feature working** |
| Adding a subtype did not break anything | A `default` branch or a `_` wildcard | Remove it. That is what turned the checking off |
| `Subtypes of a sealed class must be in the same library` | Subtype declared in another file | Move it into the same file |
| `Expected to find ','` | Colon instead of arrow in a switch expression | Branches use `=>` and are separated by commas |
| `A value of type ... can't be returned` | Switch *statement* used where an expression was needed | Use the expression form with `=>` |
| The getter isn't defined on an extension | Extension not imported, or static type too general | Import it. Check the **declared** type |
| Extension never fires | Variable declared as `Object` or `dynamic` | Extensions resolve from the **static** type |
| `... doesn't conform to the bound` | Type argument fails `extends` | Make the type implement the bound |
| Record field not found | Wrong field name in the destructure | Names must match the record exactly |
| `(42)` is not a record | Single positional record needs a comma | Write `(42,)` |
| Unreachable branch warning | General case placed before a specific one | Specific patterns first. **Order matters** |
| Mixin conflict resolved unexpectedly | Two mixins define the same member | The **last** one in `with` wins. Reorder or override |
| `fold` type error, again | No type argument | `fold<double>(0, ...)` |

---

# Appendix F · Links

| Topic | Link |
|---|---|
| Generics | https://dart.dev/language/generics |
| Records | https://dart.dev/language/records |
| Patterns | https://dart.dev/language/patterns |
| Pattern types | https://dart.dev/language/pattern-types |
| Branches: if-case and switch | https://dart.dev/language/branches |
| Class modifiers, including sealed | https://dart.dev/language/class-modifiers |
| Extension methods | https://dart.dev/language/extension-methods |
| Mixins | https://dart.dev/language/mixins |
| Effective Dart, design | https://dart.dev/effective-dart/design |
| DartPad | https://dartpad.dev |
