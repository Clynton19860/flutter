# Day 2 · Dart Core — Delegate Handbook

**Flutter for Java Developers · 8-Day Programme · Day 2 of 8**

Functions · Classes and objects · Collections · Enums

> **A full day of language, and no Flutter at all.** There is a reason for that.
> Flutter is a library, and a library written in a language you half know is a
> language you will fight for months. Almost everyone who struggles with Flutter
> is really struggling with Dart. So today we finish the language, and when the
> framework arrives it will feel like reading rather than decoding.
>
> Almost all of today is a translation exercise. Classes, constructors,
> inheritance, interfaces, collections, enums — you know every one of these
> ideas. What changes is the spelling and a handful of genuinely better defaults.

---

## Today's agenda

| | Time | Block |
|---|---|---|
| 1 | 09:00 – 10:30 | **Functions** — four kinds of parameter, the fat arrow, functions as values, closures, anonymous functions |
| 2 | 10:45 – 12:30 | **Classes and objects** — fields, constructors and the shorthand, named and factory constructors, getters, privacy, statics, **Lab 2.1** |
| 3 | 13:15 – 14:45 | **Collections** — List, Map and Set, `where`/`map`/`fold`, spread, collection-if, collection-for, **Lab 2.2** |
| 4 | 15:00 – 16:00 | **Enums and modelling** — plain enums, exhaustive switch, enhanced enums, **Lab 2.3** |

## Where we are, and where today ends

- **Yesterday** you learned variables and types, strings and interpolation,
  `final` and `const`, nullable types, `if` and `switch`, loops, lists, and how
  to write a function.
- **Today** you learn how to build things: functions with real signatures,
  classes and objects, inheritance and interfaces, collections that transform
  data, and enums that model states.
- **By 16:00** you will have a complete `Product`, `OrderLine`, `Order` and
  `OrderStatus`, written by you, in a browser, with no Flutter anywhere near it.
- **Tomorrow (Day 3)** the parts of Dart that have no Java equivalent: generics,
  records, sealed classes, pattern matching, extensions and mixins.

> **The rule that keeps paying off:** none of the code you write today knows
> anything about a user interface. That is deliberate, and on **Day 8** it is why
> your business rules can be tested in milliseconds.

Everything today runs at [dartpad.dev](https://dartpad.dev). If your install is
still not right, it does not matter today — but do fix it before Day 5.

---

# Module 1 · Functions

**09:15 – 10:30**

By the end of this module you can:

- Choose between positional, optional and named parameters
- Use the fat arrow for single-expression bodies
- Pass a function as a value and store one in a variable
- Recognise a closure and know how Dart differs from Java

## Four kinds of parameter

```dart
// 1. POSITIONAL, required. Exactly like Java.
double lineTotal(int quantity, double unitPrice) {
  return quantity * unitPrice;
}
lineTotal(40, 250.0);

// 2. POSITIONAL, optional. Square brackets. Must have a default
//    or be nullable, because the caller may leave them out.
String label(String sku, [String suffix = '']) {
  return suffix.isEmpty ? sku : '$sku-$suffix';
}
label('SKU-1');
label('SKU-1', 'B');

// 3. NAMED. Curly brackets. Caller writes the name.
double discounted({required double amount, double rate = 0.0}) {
  return amount * (1 - rate);
}
discounted(amount: 1000, rate: 0.05);
discounted(rate: 0.05, amount: 1000);   // order does not matter
discounted(amount: 1000);               // rate falls back to 0.0

// 4. MIXED. Positional first, then named.
double charge(double amount, {double rate = 0.0, String? note}) {
  return amount * (1 + rate);
}
charge(1000, rate: 0.15, note: 'standard');
```

- **Positional optional** replaces the Java overload. One implementation instead
  of three.
- **Named** uses curly brackets and the caller writes the name. Order does not
  matter. `required` is a **keyword**, not an annotation, and leaving out a
  required named parameter is a compile error.
- **You cannot mix optional positional and named** in the same function. Pick
  one. On this course we pick named, every time.

> **The readability argument:** put `discounted(1000, 0.05)` next to
> `discounted(amount: 1000, rate: 0.05)`. In the first, somebody has to open the
> signature to know what `0.05` is. That is a code review cost, every time.
>
> A Flutter widget commonly takes eight or nine parameters. Named parameters are
> why that is readable rather than unbearable, and why Flutter needs no builder
> pattern.

## The fat arrow

```dart
// These two functions are identical.
double lineTotalLong(int quantity, double unitPrice) {
  return quantity * unitPrice;
}

double lineTotalShort(int quantity, double unitPrice) =>
    quantity * unitPrice;

// It works on getters and on methods too:
class OrderLine {
  const OrderLine(this.quantity, this.unitPrice);
  final int quantity;
  final double unitPrice;

  double get lineTotal => quantity * unitPrice;
  String describe() => 'x$quantity at $unitPrice';
}
```

The arrow means **"return this one expression"**. It only works when the body
*is* a single expression — no `if` statement, no loop, no two statements.

You *can* use a conditional expression, which catches people out in a good way:
`suffix.isEmpty ? sku : '$sku-$suffix'` is a single expression, so it is fine
after an arrow.

> **Getters with arrows are the idiom you will write most:**
> `double get lineTotal => quantity * unitPrice`. That exact line appears in
> Lab 2.1.

Both forms are correct. Use the arrow when the whole thing fits comfortably on
one line, and braces when it does not.

## Functions are values

```dart
// A function is a value. You can store it, pass it, and return it.
// Java 8 needs a functional interface: Function<Double, Double>,
// Supplier<T>, Consumer<T>, BiFunction and so on. Dart needs none.

// Store one in a variable
double Function(double) addVat = (amount) => amount * 1.15;
print(addVat(1000));                  // 1150.0

// Take one as a parameter
double applyTo(double amount, double Function(double) rule) {
  return rule(amount);
}
print(applyTo(1000, addVat));
print(applyTo(1000, (a) => a * 0.9)); // an inline anonymous function

// Return one
double Function(double) percentageOff(double percent) {
  return (amount) => amount * (1 - percent / 100);
}
final tenOff = percentageOff(10);
print(tenOff(1000));                  // 900.0
```

The Java 8 equivalent of the first line:

```java
Function<Double, Double> addVat = amount -> amount * 1.15;
addVat.apply(1000.0);
```

Java needs a functional interface for every shape — `Function`, `BiFunction`,
`Supplier`, `Consumer`, `Predicate`, `UnaryOperator`, plus primitive
specialisations. You have to know which to import and call `.apply` on it.

**In Dart the type is just the signature:** `double Function(double)`. You call
it with brackets, like any other function. Nothing to import.

> **Why it matters for Flutter:** half of what you pass to a widget is a
> function. What happens when this is tapped. How to build each row of this list.
> `void Function()` is the type of a button's `onPressed`.

## Closures, and one real difference from Java

```dart
// A closure is a function that remembers the variables around it.
Function makeCounter() {
  var count = 0;            // lives on after makeCounter returns
  return () {
    count++;
    return count;
  };
}

final next = makeCounter();
print(next());   // 1
print(next());   // 2
print(next());   // 3
```

> **The difference that matters:** a Java lambda can only capture a variable that
> is `final` or effectively final, and the compiler enforces it — which is why
> Java developers wrap things in an `AtomicInteger` or a one-element array to get
> around it.
>
> **Dart has no such rule.** The closure captures the variable *itself*, not a
> copy, and can modify it. That removes the `AtomicInteger` workaround entirely.

**The cost, stated honestly:** if two closures capture the same variable, they
share it, and changes made by one are visible to the other. That is occasionally
exactly what you want and occasionally a bug that is hard to see. Java's
restriction exists to prevent that class of confusion.

## Anonymous functions

```dart
var skus = ['SKU-3', 'SKU-1', 'SKU-2'];

// Long form
skus.sort((a, b) {
  return a.compareTo(b);
});

// Short form with the fat arrow
skus.sort((a, b) => a.compareTo(b));

// With one parameter, in a forEach
skus.forEach((sku) => print(sku));
```

The Java 8 equivalent:

```java
skus.sort((a, b) -> a.compareTo(b));
skus.forEach(sku -> System.out.println(sku));
```

**The only real difference is the arrow.** Java writes `a -> b`, Dart writes
`a => b`.

**No method reference syntax.** Java has `String::compareTo`. Dart has no
double-colon form, but you can pass a function by name directly:
`skus.forEach(print)` works, because `print` takes one argument. That trick
appears in the labs.

---

# Module 2 · Classes and objects

**10:45 – 12:30**

By the end of this module you can:

- Write a class with final fields and a `const` constructor
- Use named and factory constructors in place of static factory methods
- Use getters, understand file-level privacy, and know when to use `static`
- Override `toString`, `==` and `hashCode`, and use `extends` and `implements`

> Everything here has a Java equivalent and most of it is shorter. **Two things
> work differently enough to catch you out:** privacy is by file rather than by
> class, and every class automatically defines an interface.

## A class, three ways

```dart
class Product {
  // Fields. final means set once, in the constructor.
  final String sku;
  final String name;
  final double unitPrice;

  // Constructor, the long way. This works and nobody writes it.
  Product(String sku, String name, double unitPrice)
      : this.sku = sku,
        this.name = name,
        this.unitPrice = unitPrice;
}

// The way everybody actually writes it. `this.sku` in the parameter
// list assigns the field directly. No body needed at all.
class Product2 {
  Product2(this.sku, this.name, this.unitPrice);
  final String sku;
  final String name;
  final double unitPrice;
}

// With named parameters, which is what you will use in practice
class Product3 {
  const Product3({
    required this.sku,
    required this.name,
    required this.unitPrice,
    this.stockOnHand = 0,
  });
  final String sku;
  final String name;
  final double unitPrice;
  final int stockOnHand;
}

// Creating one. There is no `new` keyword.
final p = Product3(sku: 'SKU-1', name: 'Widget', unitPrice: 250);
```

- **`this.sku` in the parameter list is the whole trick.** It declares the
  parameter and assigns the field in one move. There is no body left to write.
- **`const` on a constructor** means instances can be compile-time constants,
  which requires every field to be `final`. This matters enormously once we reach
  widgets — a `const` widget is skipped during rebuilds.
- **There is no `new` keyword.** It is optional and the style guide says leave it
  out. The analyser will grey it out if you type it.
- **Fields come *after* the constructor** by Dart convention. It looks wrong to
  Java eyes for about a day.

## Named and factory constructors

```dart
class Product {
  // 1. The main constructor
  const Product({
    required this.sku,
    required this.name,
    required this.unitPrice,
    this.stockOnHand = 0,
  });

  // 2. NAMED CONSTRUCTOR. In Java you would write a
  //    public static Product placeholder(). Here it is a real
  //    constructor, so it can be const.
  const Product.placeholder()
      : sku = 'UNKNOWN',
        name = 'Unknown product',
        unitPrice = 0,
        stockOnHand = 0;

  // 3. FACTORY CONSTRUCTOR. It does not have to create a new
  //    object. It may return a cached one, or a subclass, and
  //    it can run logic first.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      sku: json['sku'] as String,
      name: json['name'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      stockOnHand: json['stockOnHand'] as int? ?? 0,
    );
  }

  final String sku;
  final String name;
  final double unitPrice;
  final int stockOnHand;
}

final a = Product(sku: 'SKU-1', name: 'Widget', unitPrice: 250);
final b = const Product.placeholder();
final c = Product.fromJson({'sku': 'SKU-2', 'name': 'Gasket', 'unitPrice': 120});
```

- **Named constructors** replace the Java static factory method. The difference
  that matters: a named constructor **can be `const`**, and a static method never
  can.
- **The colon and the initialiser list** — the part after the colon assigns final
  fields before the body runs. It is the only place you can assign a final field
  other than the parameter list.
- **`factory` means "this does not have to create a new instance"**. It can
  return an existing object from a cache, return a subclass, or do work first and
  then decide. It is the Java static factory pattern, promoted into the language
  so the caller cannot tell the difference.

**`fromJson` is the one you will write most** — every model class gets one.

**The casts deserve a moment:** `json['sku'] as String`, and
`(json['unitPrice'] as num).toDouble()`. JSON gives you dynamic values, so you
assert the type. The `num` cast is there because a JSON number could arrive as
either an `int` or a `double`.

## Getters, setters, and the difference from methods

```dart
class OrderLine {
  const OrderLine({
    required this.sku,
    required this.quantity,
    required this.unitPrice,
  });
  final String sku;
  final int quantity;
  final double unitPrice;

  // A GETTER. Called like a field, with no brackets.
  // Java: public double getLineTotal() { return ...; }
  double get lineTotal => quantity * unitPrice;
  bool get isBulk => quantity >= 100;

  // A METHOD. Called with brackets, because it does work.
  String describe() => '$sku x$quantity = $lineTotal';
}

final line = OrderLine(sku: 'SKU-1', quantity: 40, unitPrice: 250);
print(line.lineTotal);      // no brackets - it is a getter
print(line.describe());     // brackets - it is a method

// A SETTER, for completeness. You will rarely write one.
class Basket {
  int _count = 0;
  int get count => _count;
  set count(int value) {
    if (value < 0) throw ArgumentError('count cannot be negative');
    _count = value;
  }
}
```

**Against Java beans:** Java has a naming convention and a lot of IDE-generated
boilerplate. Dart has a language feature. A field can become a getter later
without any caller changing — the encapsulation argument Java beans were invented
for, delivered properly.

> **The guidance:** use a getter when it is cheap and has no side effects. Use a
> method when it does real work or needs arguments. **Reading a getter should
> never surprise anyone.**

A getter computes every time it is read; it is not a stored field. For arithmetic
on two numbers that does not matter.

Almost every class on this course is immutable with final fields, and changes are
made with `copyWith`, which you meet in Lab 2.3.

## Privacy is by file, not by class

```dart
// Dart has no public, private, protected or package keywords.
// There is ONE rule: a name starting with an underscore is
// private to its FILE, not to its class.

class Basket {
  final List<String> _items = [];      // private to this file
  int _total = 0;                      // private to this file

  void add(String sku) {               // public
    _items.add(sku);
    _total++;
  }

  int get count => _total;             // public
}
```

Three consequences that surprise Java developers:

1. **Two classes in the same file can see each other's underscore members.** That
   is deliberate, and it is why a small helper class living beside its owner is
   idiomatic Dart rather than a smell.
2. **There is no `protected`.** A subclass in another file cannot see an
   underscore member of its parent. If a subclass needs it, it is not private.
3. **There is no package-private**, because there are no packages in the Java
   sense. The unit of privacy is the file.

An underscore is not a hint — it is compiled behaviour. Touching another file's
underscore member is a compile error.

## Static members, and when not to use a class at all

```dart
class VatRules {
  static const double standardRate = 0.15;
  static double vatOn(double amount) => amount * standardRate;
}

print(VatRules.standardRate);
print(VatRules.vatOn(1000));

// A top-level constant or function does the same job with
// less ceremony, and in Dart that is often the better choice:
const double standardVatRate = 0.15;
double vatOn(double amount) => amount * standardVatRate;
```

`static` works as it does in Java. **The real point is the second half:** Java
forces every function and constant into a class, which is why every Java codebase
has a `StringUtils` and a `Constants`. Dart has top-level functions and
variables, so that pressure does not exist.

> **The question to ask:** is this class adding anything, or is it just a
> namespace? If it is only a namespace, a top-level function in a well-named file
> does the same job.

A class of statics is still right when the grouping genuinely helps at the call
site — `VatRules.standardRate` reads better than a bare constant floating in a
file.

## `toString`, `==` and `hashCode`

```dart
class OrderLine {
  const OrderLine({required this.sku, required this.quantity});
  final String sku;
  final int quantity;

  @override
  String toString() => 'OrderLine($sku, x$quantity)';

  // Value equality. By default, two objects are equal only if
  // they are the SAME object, exactly like Java's Object.equals.
  @override
  bool operator ==(Object other) =>
      other is OrderLine &&
      other.sku == sku &&
      other.quantity == quantity;

  // If you override ==, you MUST override hashCode.
  @override
  int get hashCode => Object.hash(sku, quantity);
}

final a = OrderLine(sku: 'SKU-1', quantity: 40);
final b = OrderLine(sku: 'SKU-1', quantity: 40);
print(a == b);              // true, because we overrode ==
print(identical(a, b));     // false, they are different objects
```

- **`==` is an operator**, not a method named `equals`. The signature is
  `bool operator ==(Object other)` — it takes `Object`, not the specific type,
  exactly as Java's `equals` does and for the same reason.
- **The `is` check does two jobs at once:** it tests the type and, if it passes,
  promotes `other` to that type for the rest of the expression. No cast needed.
  That is yesterday's null flow analysis, working on types.
- **`Object.hash(a, b)`** is Dart's `Objects.hash` from Java 7. For many fields
  there is `Object.hashAll`, which takes a list.

> **Value equality matters more in Flutter than in most Java code**, because the
> framework compares old and new state to decide what to redraw. Get equality
> wrong and the screen either does not update, or updates too much.

This is boilerplate, and Java teams use Lombok or IDE generation for exactly
this. Tomorrow you meet **records**, which give structural equality for free.

## Inheritance and abstract classes

```dart
// extends works exactly as it does in Java.
class Item {
  const Item(this.sku);
  final String sku;
  String describe() => 'Item $sku';
}

class StockItem extends Item {
  const StockItem(super.sku, this.quantity);   // super.sku forwards it
  final int quantity;

  @override
  String describe() => 'Stock $sku x$quantity';
}

// ABSTRACT: cannot be instantiated, may have abstract members.
abstract class Discount {
  const Discount();

  // No body, so subclasses must provide one.
  double apply(double amount);

  // A concrete method every subclass inherits.
  String get label => runtimeType.toString();
}

class PercentageDiscount extends Discount {
  const PercentageDiscount(this.percent);
  final double percent;

  @override
  double apply(double amount) => amount * (1 - percent / 100);
}
```

- **`super.sku` in the constructor parameter list** declares a parameter and
  forwards it to the parent in one move, so you do not write a body just to call
  `super`. You will see this constantly in Flutter as `super.key`.
- **`@override` is optional but always write it.** The analyser wants it, and it
  catches the classic typo where you meant to override something and actually
  declared a new method.
- **`runtimeType`** is Dart's `getClass()`. Useful for logging, and a poor basis
  for logic.

**Prefer composition.** Deep inheritance hierarchies age badly in any language,
and in Flutter you will almost never subclass anything except the two or three
base classes the framework gives you.

## Interfaces: every class already is one

```dart
// Dart has no `interface` keyword for ordinary use.
// EVERY class automatically defines an interface: its public
// members, with no implementations.
class Discount {
  double apply(double amount) => amount;
}

// `implements` takes only the shape. You inherit NOTHING,
// so you must write every member yourself.
class NoDiscount implements Discount {
  @override
  double apply(double amount) => amount;
}

// `extends` takes the shape AND the implementations.
class HalfPrice extends Discount {
  @override
  double apply(double amount) => amount / 2;
}

// You can implement many, and extend only one. Same as Java.
class Everything implements Discount, Comparable<Everything> {
  @override
  double apply(double amount) => amount;
  @override
  int compareTo(Everything other) => 0;
}

// An abstract class with no implementations is the closest thing
// to a Java interface, and it is the usual way to declare one:
abstract class Repository {
  Product? findBySku(String sku);
  void save(Product product);
}
```

> **The distinction to drill:** `extends` takes the shape **and the code**.
> `implements` takes **only the shape**.

**Why this is useful:** you can implement a concrete class purely to match its
shape, which is how test fakes are often written in Dart without needing an
interface to have been extracted first. Java requires the interface to exist up
front.

**Why it surprises people:** implementing a class with useful methods gives you
none of them. If your file suddenly has twelve red underlines after you typed
`implements`, that is why.

Dart 3 also added `interface`, `base`, `final` and `sealed` as **class
modifiers** for library authors who want to restrict how their classes are used.
`sealed` is tomorrow; the rest are not needed for application code.

---

## LAB 2.1 · Product and OrderLine · 35 min

**Goal** — two immutable classes with `const` constructors, a named constructor,
getters, `toString`, and value equality. All in DartPad.

1. Open a fresh DartPad and copy the Lab 2.1 starter from **Appendix A**.
2. **TODO 1–2:** `Product` with four final fields, a `const` constructor with
   required named parameters, and an `inStock` getter.
3. **TODO 3–4:** override `toString`, then add a named constructor
   `Product.unknown()`.
4. **TODO 5–6:** `OrderLine` with four final fields and a `lineTotal` getter.
5. **TODO 7:** override `==` and `hashCode` on `OrderLine`, comparing `sku` and
   `quantity` only.
6. **TODO 8–10:** build two `Product`s and two identical `OrderLine`s, and prove
   the two lines are equal.
7. Check your output against Appendix A.
8. **Then experiment:** change `const` to `final` on the two `OrderLine`s and see
   what `identical()` prints now.

> **Step 8 is the real lesson.** With `const`, `identical` prints `true`, because
> the compiler made one object and reused it. With `final`, it prints `false`.
> That is yesterday's `const` slide and today's equality slide meeting each other.

### Common errors

- Forgetting `required` on a named parameter, and getting a confusing message
  about a nullable type.
- Overriding `==` without `hashCode` — the analyser flags it.
- **Writing `bool operator ==(OrderLine other)` instead of `(Object other)`.**
  This one **fails silently**: the code compiles, but `==` never runs and
  equality quietly stays broken. Exactly the same trap as Java's
  `equals(MyType)` instead of `equals(Object)`.

### Stretch

- Add a factory constructor `Product.fromJson` and call it with a hand-written map.
- Add a `discountedPrice` getter taking ten percent off, and decide whether it
  should be a getter or a method.
- Try to give `Product` a non-final field and see what the compiler says about
  the `const` constructor.

---

# Module 3 · Collections

**13:15 – 14:45**

By the end of this module you can:

- Use `List`, `Map` and `Set` fluently, including their literal syntax
- Transform data with `where`, `map`, `fold` and the rest of the Iterable API
- Use spread, collection-if and collection-for to build collections inline
- Recognise the cascade operator

> You already know this. The names are shorter, the ceremony is gone, and there
> are three things at the end that Java simply does not have.

## Lists

```dart
void main() {
  var skus = <String>['SKU-1', 'SKU-2', 'SKU-3'];

  // Reading
  print(skus[0]);                  // square brackets, not get(0)
  print(skus.first);               // throws if empty
  print(skus.last);
  print(skus.length);
  print(skus.isEmpty);
  print(skus.isNotEmpty);
  print(skus.contains('SKU-2'));
  print(skus.indexOf('SKU-2'));    // 1, or -1 if absent

  // Changing
  skus.add('SKU-4');
  skus.addAll(['SKU-5', 'SKU-6']);
  skus.insert(0, 'SKU-0');
  skus.remove('SKU-0');
  skus.removeAt(0);
  skus.removeWhere((s) => s.endsWith('6'));
  skus.clear();

  // A fixed-length list, closest to a Java array
  var fixed = List<String>.filled(3, '');
  fixed[0] = 'SKU-1';

  // An unmodifiable view, like Collections.unmodifiableList
  final frozen = List<String>.unmodifiable(['SKU-1']);
  // frozen.add('x');   // throws at runtime

  // Sorting
  var quantities = <int>[5, 40, 10];
  quantities.sort();                              // ascending
  quantities.sort((a, b) => b.compareTo(a));      // descending
  print(quantities);
}
```

- **`removeWhere` is the one Java people miss.** It is `removeIf` — the safe way
  to remove during iteration, and what you reach for instead of an iterator.
- **`first` and `last` are properties**, and both throw on an empty list.
  `firstOrNull` and `lastOrNull` are the safe versions.
- **`sort` mutates in place and returns nothing**, so you cannot chain it.
  `final sorted = list.sort()` gives you `void` and a confusing error. The idiom
  is `toList()..sort()`, using the cascade below.

## Maps and Sets

```dart
void main() {
  // A Map is Java's HashMap. Insertion order is preserved,
  // so it behaves like a LinkedHashMap.
  var stock = <String, int>{
    'SKU-1': 12,
    'SKU-2': 0,
  };

  print(stock['SKU-1']);          // 12
  print(stock['SKU-9']);          // null, and the type is int?
  stock['SKU-3'] = 7;             // add or replace
  stock.remove('SKU-2');
  print(stock.containsKey('SKU-1'));
  print(stock.keys);              // an Iterable of keys
  print(stock.values);
  print(stock.length);

  stock.putIfAbsent('SKU-4', () => 0);
  stock.update('SKU-1', (v) => v - 1, ifAbsent: () => 0);

  // Iterating a map
  for (final entry in stock.entries) {
    print('${entry.key} has ${entry.value}');
  }
  stock.forEach((sku, qty) => print('$sku has $qty'));

  // A Set is Java's HashSet. No duplicates.
  var seen = <String>{'SKU-1', 'SKU-1', 'SKU-2'};
  print(seen.length);             // 2
  seen.add('SKU-3');

  // WATCH OUT: {} on its own is an empty MAP, not an empty set.
  var emptyMap = {};              // Map<dynamic, dynamic>
  var emptySet = <String>{};      // Set<String>
}
```

**A missing key returns `null` rather than throwing**, the same as Java. What is
new is that the type of `stock['SKU-9']` is `int?`, not `int`, so the compiler
forces you to deal with it. In Java a map lookup returning null is where
`NullPointerException`s come from and nothing warns you. Here it is a compile
error.

> **The trap that catches everyone once:** an empty pair of curly brackets is an
> empty **Map**, not an empty Set, because maps came first. An empty set needs
> its type: `<String>{}`.

## Iteration: the Stream API without the ceremony

```dart
final lines = <OrderLine>[
  OrderLine(sku: 'SKU-1', quantity: 40, unitPrice: 250),
  OrderLine(sku: 'SKU-2', quantity: 10, unitPrice: 120),
  OrderLine(sku: 'SKU-3', quantity: 5, unitPrice: 90),
];

// where  -> Java's filter
final bulk = lines.where((l) => l.quantity >= 10);

// map    -> Java's map
final skus = lines.map((l) => l.sku);

// toList -> Java's collect(Collectors.toList())
final skuList = lines.map((l) => l.sku).toList();

// fold   -> Java's reduce with an identity value
final total = lines.fold<double>(0, (sum, l) => sum + l.lineTotal);

// reduce -> Java's reduce with no identity. Throws if empty.
final biggest = lines.map((l) => l.quantity).reduce((a, b) => a > b ? a : b);

// any / every -> anyMatch / allMatch
final hasBulk = lines.any((l) => l.quantity >= 100);
final allPriced = lines.every((l) => l.unitPrice > 0);

// firstWhere -> findFirst, but it THROWS if nothing matches
final found = lines.firstWhere((l) => l.sku == 'SKU-2');
final safe = lines.where((l) => l.sku == 'SKU-9').firstOrNull;

// take / skip -> limit / skip
final firstTwo = lines.take(2).toList();
final afterFirst = lines.skip(1).toList();

// expand -> flatMap
final letters = ['ab', 'cd'].expand((s) => s.split('')).toList();

// join -> Collectors.joining
print(lines.map((l) => l.sku).join(', '));
```

### The translation

| Java | Dart |
|---|---|
| `filter` | `where` |
| `map` | `map` |
| `collect(toList())` | `toList()` |
| `anyMatch` | `any` |
| `allMatch` | `every` |
| `limit` | `take` |
| `flatMap` | `expand` |
| `Collectors.joining` | `join` |

### Three gotchas

1. **Always write the type argument on `fold`.** `fold<double>(0, ...)`. Without
   it Dart can infer `num` instead of `double` and you get a confusing error
   about assigning `num` to `double`. This will bite somebody in Lab 2.2.
2. **`fold` takes an initial value and always returns something. `reduce` takes
   no initial value and throws on an empty collection.** Prefer `fold`.
3. **`firstWhere` throws if nothing matches.** The safe form is
   `where(...).firstOrNull`, which gives you a nullable the compiler makes you
   handle. There is also an `orElse` parameter.

**Lazy, exactly like Java streams:** `where` and `map` do no work until you
iterate or call `toList`.

**No parallel streams.** There is no `parallelStream` equivalent, because Dart
has one thread per isolate — that is a Day 4 conversation.

## Spread, collection-if and collection-for

```dart
// Three things Java has no equivalent for, and you will
// use all three constantly once you reach the Flutter days.
final base = ['SKU-1', 'SKU-2'];
final extra = ['SKU-3'];

// 1. SPREAD: unpack one list into another
final all = [...base, ...extra];
print(all);                       // [SKU-1, SKU-2, SKU-3]

// Null-aware spread, when the source might be null
List<String>? maybe;
final safe = [...base, ...?maybe];

// 2. COLLECTION-IF: include an element conditionally
final isUrgent = true;
final flags = [
  'standard',
  if (isUrgent) 'urgent',
];

// 3. COLLECTION-FOR: build elements from a loop, inline
final labels = [
  for (final sku in all) sku.toLowerCase(),
];

// All three combine:
final report = [
  'ORDER REPORT',
  if (isUrgent) '** URGENT **',
  for (final sku in all) '  $sku',
  ...extra,
];
report.forEach(print);
```

In Java that last one is: declare an `ArrayList`, add the title, write an `if`
and add conditionally, write a `for` loop and add inside it, then `addAll`. Six
statements and a mutable variable, against one expression.

> **Why this matters enormously from Day 5:** a Flutter screen is a list of
> children. **Collection-if** is how you show a widget only when something is
> true. **Collection-for** is how you turn a list of orders into a list of rows.
> You will write both several times on every screen.
>
> Today this looks like syntactic sugar. On Day 5 it is the difference between
> readable UI code and a mess of temporary variables.

The map version exists too, and appears in Lab 2.2 — a `for` inside a map
literal, producing key and value pairs.

## The cascade operator

```dart
// Two dots let you call several members on the same object
// without it returning itself each time.
final buffer = StringBuffer()
  ..write('Order ')
  ..write('SKU-1')
  ..write(' confirmed');
print(buffer.toString());

// It also works on setters and on collections:
final skus = <String>[]
  ..add('SKU-1')
  ..add('SKU-2')
  ..sort();
```

**The problem it solves:** methods returning `void` cannot be chained. In Java
the answer is the builder pattern, where every method returns `this` — and that
has to be designed in by whoever wrote the class. The cascade gives you the same
reading experience on any object, without the class cooperating.

> **The idiom you will actually use is `toList()..sort()`.** Because `sort`
> returns `void`, `final sorted = list.sort()` does not work. With a cascade it
> does: `final sorted = list.toList()..sort()`.

Do not overuse it — a cascade of eight calls is harder to read than eight
statements. There is a null-aware version, `?..`, for when the target might be
null.

---

## LAB 2.2 · Order line calculations · 35 min

**Goal** — take a list of `OrderLine`s and produce totals, filters, a sorted
list, a map, and a formatted report, using only the Iterable API and collection
literals.

1. Continue in the same pad, below your Lab 2.1 classes. Copy the starter from
   **Appendix B**.
2. **TODO 1–2:** print every SKU with `map` and `forEach`, then the bulk lines
   with `where`.
3. **TODO 3–4:** total the line values and the quantities with `fold`. Remember
   `fold<double>` and `fold<int>`.
4. **TODO 5:** `any` and `every`.
5. **TODO 6:** a sorted list of descriptions. You will need `toList()..sort()`.
6. **TODO 7:** a `Map` of sku to `lineTotal`, built with a `for` inside a map
   literal.
7. **TODO 8:** a report list using collection-if and collection-for, then print
   each line.
8. Check every number against Appendix B.

> **The two things people get stuck on**, both covered above: `fold` without a
> type argument, and trying to assign the result of `sort`.

### Stretch

- Find the single most valuable line using `reduce`, and say what happens if the
  list is empty.
- Group the lines into a `Map` of bulk and standard using `fold` with a map as
  the accumulator.
- Rewrite TODO 8 **without** collection-if and collection-for, and compare the
  two versions. This is the most valuable stretch goal — it is what makes the
  feature stick.

---

# Module 4 · Enums and modelling

**15:00 – 16:00**

By the end of this module you can:

- Use a plain enum and switch over it exhaustively
- Write an enhanced enum with fields, a constructor and methods
- Decide what belongs on an enum and what belongs elsewhere
- Assemble the complete `Order` class

## Plain enums

```dart
enum OrderStatus { draft, submitted, picking, shipped, cancelled }

void main() {
  final status = OrderStatus.submitted;

  print(status);              // OrderStatus.submitted
  print(status.name);         // submitted
  print(status.index);        // 1
  print(OrderStatus.values);  // the full list, in order
  print(OrderStatus.values.length);

  // Parsing back from text
  final parsed = OrderStatus.values.byName('picking');
  print(parsed);

  // Switching over one. The compiler checks you handled
  // every value, so adding a sixth breaks this until you do.
  switch (status) {
    case OrderStatus.draft:
      print('Still being edited');
    case OrderStatus.submitted:
      print('Waiting to be picked');
    case OrderStatus.picking:
      print('Being picked');
    case OrderStatus.shipped:
      print('On its way');
    case OrderStatus.cancelled:
      print('Cancelled');
  }
}
```

- **`name` and `index` are properties**, not methods. Java has `name()` and
  `ordinal()`.
- **`values` is a `List`** in declaration order, exactly as in Java.
- **`byName` parses from text** and throws if there is no match.
- **The exhaustive switch is the important part.** Because the compiler knows
  every value, it checks you handled all of them. Add a sixth value and the
  switch turns red until you handle it.

## Enhanced enums

```dart
// Fields, a constructor, getters and methods.
// The same capability Java enums have had since 1.5.
enum OrderStatus {
  draft('Draft', true),
  submitted('Submitted', false),
  picking('Picking', false),
  shipped('Shipped', false),
  cancelled('Cancelled', false);

  // The constructor must be const, and it comes AFTER the
  // values, separated by a semicolon.
  const OrderStatus(this.label, this.isEditable);

  final String label;
  final bool isEditable;

  // A getter, available on every value
  bool get isFinished =>
      this == OrderStatus.shipped || this == OrderStatus.cancelled;

  // A method
  bool canMoveTo(OrderStatus next) {
    if (isFinished) return false;
    return index < next.index || next == OrderStatus.cancelled;
  }
}

void main() {
  print(OrderStatus.picking.label);          // Picking
  print(OrderStatus.draft.isEditable);       // true
  print(OrderStatus.shipped.isFinished);     // true
  print(OrderStatus.draft.canMoveTo(OrderStatus.shipped));  // true

  // A display list for a dropdown, built with collection-for
  final options = [
    for (final s in OrderStatus.values) '${s.name}: ${s.label}',
  ];
  options.forEach(print);
}
```

> **The layout rule that trips people:** the values come first, then a
> **semicolon**, then everything else. That semicolon after the last value is
> easy to miss and the error message is unhelpful.

The constructor **must be `const`**, because enum values are compile-time
constants. Every field must therefore be `final`.

**The modelling argument, which is the real point:** the label lives on the
value. That means no screen, no report and no email template ever has to
translate an enum into words. Ask yourself where that translation usually lives
in your systems — the answer is usually a switch in a service, or worse, a map in
the UI layer, duplicated in three places.

**What does not belong on an enum:** anything that needs a database, a network
call, or knowledge of the user interface. Enums should stay pure.

> **The payoff on Day 5:** a dropdown of statuses is built directly from `values`
> with a collection-for, using `label`. That is two lines.

---

## LAB 2.3 · The Order class · 35 min

**Goal** — an enhanced `OrderStatus` enum and an immutable `Order` class that
totals itself and can be copied with changes. **The capstone of the day.**

1. Continue in the same pad. Copy the starter from **Appendix C**.
2. **TODO 1–2:** `OrderStatus` as an enhanced enum with `label`, `isEditable` and
   an `isFinished` getter.
3. **TODO 3:** the `Order` class with four final fields and a `const`
   constructor, status defaulting to `draft`.
4. **TODO 4–6:** getters for `itemCount`, `subtotal` and `isEmpty`.
5. **TODO 7:** `copyWith`, taking every field as an optional named parameter.
6. **TODO 8:** `toString` producing `Order(ORD-1042, Acme Ltd, 4 lines, Draft)`.
7. **TODO 9–11:** build the order, print its totals, then `copyWith` it to
   submitted and prove the original is unchanged.

> **`copyWith` is the piece you have not written before.** Every parameter is
> nullable and optional. Inside, each falls back to the current value with `??`.
> It is verbose and mechanical — there are packages that generate it.

**The point of step 11 is immutability.** The original order is untouched by
`copyWith`. On Day 5, Flutter decides what to redraw by comparing old state to
new state, and that only works if the old state still exists to compare against.
Mutating in place breaks that.

### Common errors

- Forgetting the semicolon after the last enum value.
- Writing the constructor before the values.
- `fold` without a type argument, again.
- Making `copyWith` parameters `required` by habit, which defeats the purpose.

### Stretch

- Add a `validate` getter returning a `List<String>` of problems, built with
  collection-if.
- Add a `canSubmit` getter, true only when the order has lines and the status is
  editable.
- Try to add a line to an existing order and discover why `copyWith` with a new
  list is the only way. *(You cannot: `lines` is final and the object is
  immutable. Lists are references, so the copy is cheap, and the correctness is
  worth far more than the allocation.)*

---

# Day 2 recap

- Parameters come in four shapes. **Named parameters** are what make long
  argument lists readable, and Flutter uses them everywhere.
- A function is a value. No functional interface, no import, and the type is
  written as the signature.
- `this.field` in a constructor assigns the field, so most classes need no
  constructor body.
- **Named constructors** replace static factory methods, and **factory
  constructors** can return something other than a fresh object.
- **Privacy is by file** and marked with an underscore. There is no `protected`
  and no package-private.
- Every class defines an interface. `extends` takes the code, `implements` takes
  only the shape.
- `Iterable` is the Stream API without the ceremony. **Always write the type
  argument on `fold`.**
- Spread, collection-if and collection-for build collections in one expression,
  and you will use all three on every screen from Day 5.
- An **enhanced enum carries its own display label**, so no screen has to
  translate it.

**Tomorrow (Day 3 · Dart Advanced):** generics and why `List<String>` is not
`List<Object>`, records, sealed classes and switch expressions, extensions and
mixins.

---

## Optional reading tonight · 15 min

The **"Classes"** page, then **"Collections"** —
[dart.dev/language/classes](https://dart.dev/language/classes). Skip
constructors; we covered what you need.

1. Find one thing about classes we did not cover today, and be ready to say what
   it might be for.
2. The collections page mentions an unmodifiable list. When would you reach for
   one in the order app?
3. Find where the docs describe what happens if you override `==` but not
   `hashCode`. Does it match what you were told?

---

# Appendix A · Lab 2.1

### Starter

```dart
// LAB 2.1 STARTER - dartpad.dev

// TODO 1: a class Product with final fields
//           sku (String), name (String), unitPrice (double),
//           stockOnHand (int, default 0)
//         Use a const constructor with required named parameters.
// TODO 2: a getter `inStock` returning true when stockOnHand > 0
// TODO 3: override toString to return  Product(SKU-1, Widget)
// TODO 4: a named constructor Product.unknown() that makes a
//         placeholder with sku 'UNKNOWN', name 'Unknown', price 0

// TODO 5: a class OrderLine with final fields
//           sku, description, quantity (int), unitPrice (double)
//         and a const constructor with required named parameters
// TODO 6: a getter `lineTotal` returning quantity * unitPrice
// TODO 7: override == and hashCode on OrderLine, comparing
//         sku and quantity only

void main() {
  // TODO 8: make two Products and print them
  // TODO 9: make two identical OrderLines and prove they are equal
  // TODO 10: print the line total of one of them
}
```

### Solution

```dart
class Product {
  const Product({
    required this.sku,
    required this.name,
    required this.unitPrice,
    this.stockOnHand = 0,
  });

  const Product.unknown()
      : sku = 'UNKNOWN',
        name = 'Unknown',
        unitPrice = 0,
        stockOnHand = 0;

  final String sku;
  final String name;
  final double unitPrice;
  final int stockOnHand;

  bool get inStock => stockOnHand > 0;

  @override
  String toString() => 'Product($sku, $name)';
}

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

  double get lineTotal => quantity * unitPrice;

  @override
  bool operator ==(Object other) =>
      other is OrderLine && other.sku == sku && other.quantity == quantity;

  @override
  int get hashCode => Object.hash(sku, quantity);

  @override
  String toString() => 'OrderLine($sku x$quantity)';
}

void main() {
  const widget = Product(sku: 'SKU-1', name: 'Widget', unitPrice: 250, stockOnHand: 12);
  const unknown = Product.unknown();
  print(widget);
  print(unknown);
  print('In stock: ${widget.inStock}');

  const a = OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250);
  const b = OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250);
  print('a == b        ${a == b}');
  print('identical     ${identical(a, b)}');
  print('Line total    ${a.lineTotal}');
}
```

### Expected output

```
Product(SKU-1, Widget)
Product(UNKNOWN, Unknown)
In stock: true
a == b        true
identical     true
Line total    10000.0
```

> `identical` is **true** here because both are `const`, so the compiler created
> one object and reused it. Change `const` to `final` on `a` and `b` and it
> prints `false`.

---

# Appendix B · Lab 2.2

### Starter

```dart
// LAB 2.2 STARTER - continue in the same pad, below Lab 2.1
void main() {
  final lines = <OrderLine>[
    OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
    OrderLine(sku: 'SKU-2', description: 'Gasket', quantity: 10, unitPrice: 120),
    OrderLine(sku: 'SKU-3', description: 'Bracket', quantity: 5, unitPrice: 90),
    OrderLine(sku: 'SKU-4', description: 'Seal', quantity: 200, unitPrice: 15),
  ];

  // TODO 1: print every SKU, one per line, using map and forEach
  // TODO 2: print only the lines with quantity of 100 or more, using where
  // TODO 3: total up every lineTotal using fold. Remember the
  //         type argument: fold<double>(0, ...)
  // TODO 4: total up the quantities using fold
  // TODO 5: print true or false for "is any line 100 or more"
  //         and for "is every unit price above zero"
  // TODO 6: build a List<String> of descriptions, sorted alphabetically
  // TODO 7: build a Map<String, double> of sku to lineTotal
  // TODO 8: build a report list using collection-if and collection-for:
  //           a title line
  //           the word BULK ORDER, only if any line is 100 or more
  //           one indented line per SKU
  //         then print each element
}
```

### Solution

```dart
void main() {
  final lines = <OrderLine>[
    OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
    OrderLine(sku: 'SKU-2', description: 'Gasket', quantity: 10, unitPrice: 120),
    OrderLine(sku: 'SKU-3', description: 'Bracket', quantity: 5, unitPrice: 90),
    OrderLine(sku: 'SKU-4', description: 'Seal', quantity: 200, unitPrice: 15),
  ];

  lines.map((l) => l.sku).forEach(print);

  final bulk = lines.where((l) => l.quantity >= 100);
  bulk.forEach((l) => print('BULK ${l.sku} x${l.quantity}'));

  final totalValue = lines.fold<double>(0, (sum, l) => sum + l.lineTotal);
  final totalUnits = lines.fold<int>(0, (sum, l) => sum + l.quantity);
  print('Total value  $totalValue');
  print('Total units  $totalUnits');

  print('Any bulk     ${lines.any((l) => l.quantity >= 100)}');
  print('All priced   ${lines.every((l) => l.unitPrice > 0)}');

  final descriptions = lines.map((l) => l.description).toList()..sort();
  print(descriptions);

  final byS = <String, double>{
    for (final l in lines) l.sku: l.lineTotal,
  };
  print(byS);

  final report = [
    'ORDER REPORT',
    if (lines.any((l) => l.quantity >= 100)) 'BULK ORDER',
    for (final l in lines) '  ${l.sku} x${l.quantity} = ${l.lineTotal}',
  ];
  report.forEach(print);
}
```

### Expected output

```
SKU-1
SKU-2
SKU-3
SKU-4
BULK SKU-4 x200
Total value  14650.0
Total units  255
Any bulk     true
All priced   true
[Bracket, Gasket, Seal, Widget]
{SKU-1: 10000.0, SKU-2: 1200.0, SKU-3: 450.0, SKU-4: 3000.0}
ORDER REPORT
BULK ORDER
  SKU-1 x40 = 10000.0
  SKU-2 x10 = 1200.0
  SKU-3 x5 = 450.0
  SKU-4 x200 = 3000.0
```

---

# Appendix C · Lab 2.3

### Starter

```dart
// LAB 2.3 STARTER - continue in the same pad

// TODO 1: an enhanced enum OrderStatus with values
//           draft, submitted, picking, shipped, cancelled
//         each carrying a String label and a bool isEditable
// TODO 2: a getter isFinished, true for shipped and cancelled

// TODO 3: a class Order with final fields
//           id (String), customer (String),
//           lines (List<OrderLine>), status (OrderStatus,
//           defaulting to draft)
// TODO 4: a getter itemCount, the sum of the quantities
// TODO 5: a getter subtotal, the sum of the line totals
// TODO 6: a getter isEmpty, true when there are no lines
// TODO 7: a method copyWith that can change any field
// TODO 8: override toString to print
//           Order(ORD-1042, Acme Ltd, 4 lines, Draft)

void main() {
  // TODO 9: build an order with the four lines from Lab 2.2
  // TODO 10: print it, its item count and its subtotal
  // TODO 11: use copyWith to move it to submitted, and print both
  //          the original and the copy to prove the original
  //          did not change
}
```

### Solution

```dart
enum OrderStatus {
  draft('Draft', true),
  submitted('Submitted', false),
  picking('Picking', false),
  shipped('Shipped', false),
  cancelled('Cancelled', false);

  const OrderStatus(this.label, this.isEditable);

  final String label;
  final bool isEditable;

  bool get isFinished =>
      this == OrderStatus.shipped || this == OrderStatus.cancelled;
}

class Order {
  const Order({
    required this.id,
    required this.customer,
    required this.lines,
    this.status = OrderStatus.draft,
  });

  final String id;
  final String customer;
  final List<OrderLine> lines;
  final OrderStatus status;

  int get itemCount => lines.fold<int>(0, (sum, l) => sum + l.quantity);
  double get subtotal => lines.fold<double>(0, (sum, l) => sum + l.lineTotal);
  bool get isEmpty => lines.isEmpty;

  Order copyWith({
    String? id,
    String? customer,
    List<OrderLine>? lines,
    OrderStatus? status,
  }) =>
      Order(
        id: id ?? this.id,
        customer: customer ?? this.customer,
        lines: lines ?? this.lines,
        status: status ?? this.status,
      );

  @override
  String toString() =>
      'Order($id, $customer, ${lines.length} lines, ${status.label})';
}

void main() {
  final lines = <OrderLine>[
    OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
    OrderLine(sku: 'SKU-2', description: 'Gasket', quantity: 10, unitPrice: 120),
    OrderLine(sku: 'SKU-3', description: 'Bracket', quantity: 5, unitPrice: 90),
    OrderLine(sku: 'SKU-4', description: 'Seal', quantity: 200, unitPrice: 15),
  ];

  final order = Order(id: 'ORD-1042', customer: 'Acme Ltd', lines: lines);
  print(order);
  print('Items    ${order.itemCount}');
  print('Subtotal ${order.subtotal}');
  print('Editable ${order.status.isEditable}');

  final submitted = order.copyWith(status: OrderStatus.submitted);
  print(order);
  print(submitted);
  print('Original still editable: ${order.status.isEditable}');
}
```

### Expected output

```
Order(ORD-1042, Acme Ltd, 4 lines, Draft)
Items    255
Subtotal 14650.0
Editable true
Order(ORD-1042, Acme Ltd, 4 lines, Draft)
Order(ORD-1042, Acme Ltd, 4 lines, Submitted)
Original still editable: true
```

> **This is the model that Day 5 puts on a screen.** Keep the pad open, or paste
> it somewhere you can find it again.

---

# Appendix D · Java to Dart, today's vocabulary

| Java | Dart | Note |
|---|---|---|
| `public static void main` | `void main()` | No class needed |
| `new Product(...)` | `Product(...)` | `new` is optional and omitted |
| constructor body assigning fields | `Product(this.sku)` | Assigns the field directly |
| `public static Product of(...)` | `Product.named(...)` | A real constructor, so it can be `const` |
| static factory that may cache | `factory Product(...)` | Caller cannot tell the difference |
| `getLineTotal()` | `get lineTotal` | Called with no brackets |
| `private` | `_name` | Private to the **file**, not the class |
| `protected` | no equivalent | If a subclass needs it, it is not private |
| `@Override` | `@override` | Optional, but always write it |
| `equals(Object)` | `operator ==(Object)` | An operator, not a method |
| `Objects.hash(a, b)` | `Object.hash(a, b)` | Same contract with `==` |
| `interface Foo` | `abstract class Foo` | Every class also defines an interface |
| `ArrayList<String>` | `<String>[]` | Literal syntax |
| `HashMap<String,int>` | `<String,int>{}` | Keeps insertion order |
| `stream().filter(...)` | `.where(...)` | No `stream()` to open |
| `collect(toList())` | `.toList()` | No collector |
| `reduce(0, ...)` | `.fold<T>(0, ...)` | Always write the type argument |
| `removeIf` | `removeWhere` | Same thing |
| `Function<A,B>` | `B Function(A)` | Nothing to import |
| builder pattern | `..` cascade | Works on any class |

---

# Appendix E · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `A value of type num can't be assigned to double` | `fold` without a type argument | Write `fold<double>(0, ...)` |
| `The argument type ... can't be assigned` | Named parameter passed positionally | Write the name: `amount: 1000` |
| `Missing concrete implementation` | Used `implements` instead of `extends` | `implements` gives you no code at all |
| `==` is not overridden but equality fails | Signature is `(MyType other)` | It must be `(Object other)` to override |
| Analyser warns about `hashCode` | Overrode `==` only | Override both, always |
| `Invalid constant value` in a const constructor | A field is not final | Every field must be final for `const` |
| `Expected an identifier` in an enum | Missing semicolon after the last value | Values, then `;`, then everything else |
| The setter isn't defined on a final field | Trying to mutate an immutable object | Use `copyWith` to make a changed copy |
| `This expression has a type of void` | Assigning the result of `sort()` | Use `list.toList()..sort()` |
| `Bad state: No element` | `first` or `reduce` on an empty collection | Use `firstOrNull`, or `fold` with an initial value |
| Undefined name on a private member | Underscore member in another file | Privacy is by file. Remove the underscore or move the code |
| `{}` behaves like a Map when you wanted a Set | Empty braces default to Map | Write `<String>{}` |
| `firstWhere` throws | Nothing matched | Use `.where(...).firstOrNull` or pass `orElse` |

---

# Appendix F · Links

| Topic | Link |
|---|---|
| Functions | https://dart.dev/language/functions |
| Classes | https://dart.dev/language/classes |
| Constructors | https://dart.dev/language/constructors |
| Methods, getters and setters | https://dart.dev/language/methods |
| Extend a class | https://dart.dev/language/extend |
| Implicit interfaces | https://dart.dev/language/classes#implicit-interfaces |
| Collections | https://dart.dev/language/collections |
| Iterable API | https://api.dart.dev/dart-core/Iterable-class.html |
| Enums | https://dart.dev/language/enums |
| Effective Dart, design | https://dart.dev/effective-dart/design |
| DartPad | https://dartpad.dev |
