# Day 4 · Errors, Async and Isolates — Delegate Handbook

**Flutter for Java Developers · 8-Day Programme · Day 4 of 8**

Exceptions · Future and await · Streams · Why Dart has no threads

> **Today is about time.** What happens when something takes a while, what
> happens when it fails, and what happens when your own code is the slow thing.
> Those three questions decide whether an app feels good or feels broken.
>
> This is the last day before we put anything on a screen.

---

## Today's agenda

| | Time | Block |
|---|---|---|
| 1 | 09:00 – 10:30 | **Errors and exceptions** — `throw`, `try`, `on`, `catch`, `finally`, Exception vs Error, custom sealed exceptions |
| 2 | 10:45 – 12:30 | **Future and await** — `Future` is `CompletableFuture`, `async`/`await`, errors, timeouts, `Future.wait`, **Lab 4.1** |
| 3 | 13:15 – 14:45 | **Streams** — many values over time, `async*`, `yield`, `await for`, `listen`, `StreamController`, **Lab 4.2** |
| 4 | 15:00 – 16:00 | **Isolates** — no threads, no locks, no data races, `compute`, the 16 ms budget, **Lab 4.3** |

> **Before you start:** have your Day 3 pad open with the sealed `OrderState` in
> it. All three labs extend it.

---

# Module 1 · Errors and exceptions

**09:15 – 10:30**

By the end of this module you can:

- Throw and catch, with `on`, `catch`, `rethrow` and `finally`
- Explain the difference between an `Exception` and an `Error` in Dart
- Design a sealed exception hierarchy and switch over it
- Know what the absence of checked exceptions costs you

## Throwing, and the absence of checked exceptions

```dart
// Throwing. Dart can throw ANY object, but by convention you
// throw something that implements Exception or Error.
throw Exception('An order needs at least one line');
throw ArgumentError('quantity must be positive');
throw StateError('Order already submitted');
throw FormatException('Not a valid SKU: $sku');
```

**There are no checked exceptions. None.** There is no `throws` clause, nothing
forces you to catch anything, and the compiler will not warn you that a call can
fail.

```java
// Java
public Order submit(Order o) throws StockException
```
```dart
// Dart
Order submit(Order o)
```

**What you lose:** the compiler no longer tells you a call can fail. A method's
signature does not document its failure modes. In a large system that is real
information gone.

**What you gain:** no more wrapping an exception in another exception purely to
get it through a signature. No more catch blocks that do nothing but rethrow as a
`RuntimeException`. No more interface signatures polluted by an implementation's
failure modes.

Most modern languages — Kotlin and C# included — made the same choice, and the
Java community has largely concluded that checked exceptions did not deliver what
was hoped.

> **What to do instead, and this is the practical answer:** document failure in
> the **return type** rather than the signature. That is exactly what the sealed
> `OrderState` does. A function returning `OrderState` makes failure visible in a
> way a `throws` clause never did, because the caller cannot ignore it.

## `try`, `on`, `catch`, `finally`, `rethrow`

```dart
void loadOrder(String id) {
  try {
    final order = fetch(id);
    print(order);
  } on FormatException catch (e) {
    // `on` catches ONE type. This is Java's catch (FormatException e)
    print('Bad format: ${e.message}');
  } on ArgumentError catch (e, stackTrace) {
    // A second parameter gives you the stack trace
    print('Bad argument: $e');
    print(stackTrace);
  } catch (e) {
    // Bare catch takes anything at all
    print('Something else: $e');
  } finally {
    // Always runs, exactly as in Java
    print('done');
  }
}

// RETHROW keeps the original stack trace.
try {
  risky();
} catch (e) {
  log(e);
  rethrow;          // not: throw e;
}
```

- **`on Type catch (e)` is Java's `catch (Type e)`.** The keyword split looks odd
  for a day: `on` names the type, `catch` names the variable. You can use `on`
  with no `catch`, and `catch` with no `on`.
- **The second catch parameter is the stack trace**, and most people miss it.
  There is no exception object carrying it around — the trace is passed
  separately. That surprises Java developers who expect `e.getStackTrace()`.
- **Order matters**, same as Java: specific types first, bare catch last. Unlike
  Java, the analyser will not always warn you about an unreachable catch.
- **`finally` is identical.** Always runs, including after a return.

> **`rethrow` is the one to drill.** Inside a catch block, `rethrow` preserves the
> original stack trace. Writing `throw e` instead **resets** it, and you lose
> where the problem actually came from. Exactly the same mistake as `throw e`
> versus `throw` in Java, and just as common.

**There is no try-with-resources.** Cleanup goes in `finally`, or in a `dispose`
method that something else calls.

## Exception or Error: a line Java does not draw

```dart
// Exception: something went wrong that the program should
// expect and handle. A network failure. A bad input. Out of
// stock. You catch these.
class OutOfStockException implements Exception {
  OutOfStockException(this.sku, this.requested, this.available);
  final String sku;
  final int requested;
  final int available;

  @override
  String toString() =>
      'Only $available of $sku available, $requested requested';
}
```

**Error: a bug.** The programmer made a mistake. You should **not** catch these;
you should fix the code.

| Error | Means |
|---|---|
| `ArgumentError` | Caller passed nonsense |
| `StateError` | Called at the wrong time |
| `RangeError` | Index out of bounds |
| `UnimplementedError` | Not written yet |
| `AssertionError` | An `assert` failed |

> **The practical rule:**
> - throw an **Exception** for things the world does to you
> - throw an **Error** for things a programmer did wrong
> - **catch Exceptions; let Errors crash** in development

That last part is uncomfortable for a room used to defensive catching. Server
code often catches everything at the boundary and returns a 500, because a crash
takes down a request rather than a process. On mobile a crash takes down the app
in front of a user, so instinct says catch everything. **The honest answer is
that a swallowed Error becomes a silent wrong result, which is worse** — and Day
8 covers crash reporting properly.

Note `implements Exception`, not `extends`. `Exception` is effectively an empty
interface.

## Sealed exceptions: failures you cannot forget to handle

```dart
// Note: implements Exception, not extends.
sealed class OrderException implements Exception {
  const OrderException(this.message);
  final String message;

  @override
  String toString() => message;
}

class EmptyOrderException extends OrderException {
  const EmptyOrderException() : super('An order needs at least one line');
}

class OutOfStockException extends OrderException {
  const OutOfStockException(this.sku) : super('$sku is out of stock');
  final String sku;
}

class ApprovalRequiredException extends OrderException {
  const ApprovalRequiredException(this.itemCount)
      : super('Orders over 500 units need manual approval');
  final int itemCount;
}

// Because it is SEALED, you can switch over it exhaustively,
// which is how you turn a failure into a message for the user.
String userMessage(OrderException e) => switch (e) {
      EmptyOrderException() => 'Add at least one item before submitting.',
      OutOfStockException(:final sku) => 'Sorry, $sku is out of stock.',
      ApprovalRequiredException() =>
        'This order needs a manager to approve it.',
    };
```

**The problem this solves:** in a normal codebase, mapping an exception to a user
message is a chain of `instanceof` checks ending in a generic "something went
wrong". New exception types get added and the chain does not get updated, so
users see the generic message for a failure you could have explained.

**The solution:** make the exception hierarchy sealed. Now `userMessage` is an
exhaustive switch, and adding a fourth exception type **breaks compilation until
somebody writes a sentence for it**.

> It becomes **structurally impossible to ship a failure mode with no
> user-facing message**. For an enterprise app that is a genuinely valuable
> property, and it costs nothing.

## `assert`: on in debug, gone in release

```dart
void setQuantity(int value) {
  assert(value > 0, 'quantity must be positive, got $value');
  _quantity = value;
}
```

Java's `assert` is effectively dead, because it needs `-ea` at runtime and almost
nobody sets it. **Dart's is on by default in debug and stripped entirely from
release**, which is the behaviour people expected from Java's.

- **Use it for** things that should be impossible if *your own* code is correct.
  Internal invariants.
- **Do not use it for** validating user input or data from a server. Those must
  be checked in release too — where the assert no longer exists.

Always write the second argument. An `AssertionError` with no message is a bad
afternoon.

> Flutter's own source is full of asserts with unusually good messages. When you
> get a long readable error at runtime on Day 5 explaining exactly what you did
> wrong, that is an assert firing.

---

# Module 2 · Future and await

**10:45 – 12:30**

By the end of this module you can:

- Use `Future`, `async` and `await` for work that finishes later
- Handle failure with ordinary `try` and `catch`
- Run several futures at once with `Future.wait`, and know what that does *not* do
- Recognise the sequential-await trap

## `Future`, `async`, `await`

```dart
// Future<T> is CompletableFuture<T>. It represents a value
// that is not here yet.
Future<Order> fetchOrder(String id) async {
  await Future.delayed(const Duration(milliseconds: 800));
  if (id.isEmpty) throw ArgumentError('id is required');
  return Order(id: id, customer: 'Acme Ltd', lines: const []);
}

Future<void> show() async {
  final order = await fetchOrder('ORD-1042');
  print(order.customer);
}

// Making a Future without async
final ready = Future.value(42);
final failed = Future<int>.error(Exception('nope'));
final later = Future.delayed(const Duration(seconds: 1), () => 42);
```

The Java 8 equivalent, and why `await` is worth having:

```java
CompletableFuture<Order> f = fetchOrder("ORD-1042");
f.thenApply(Order::getCustomer)
 .thenAccept(System.out::println);
```

**`async` does two things:** the function now returns a `Future`, and you may use
`await` inside it.

> **The single most important sentence in this module:** `async` does **not** mean
> another thread. It means this function can **pause and let the one thread do
> something else** while it waits.

`await` unwraps the Future. Everything after the `await` runs when the value
arrives — so the code reads top to bottom like synchronous code, which is the
entire point.

**`Future.delayed` is your fake network call** for the rest of the week.

> **The common beginner error:** forgetting `await`, so you print
> `Instance of 'Future'` rather than the value. You will do it at least once today.

## Handling failure

```dart
// Ordinary try and catch. No exceptionally, no handle, no
// CompletionException wrapping the real cause.
Future<void> submit(Order order) async {
  try {
    final saved = await service.submit(order);
    print('Saved ${saved.id}');
  } on OutOfStockException catch (e) {
    print('Out of stock: ${e.sku}');
  } on OrderException catch (e) {
    print('Rejected: ${e.message}');
  } catch (e) {
    print('Unexpected: $e');
  } finally {
    print('finished');
  }
}

// catchError is the callback form. Prefer try and catch.
fetchOrder('x')
    .then((order) => print(order.id))
    .catchError((e) => print('failed: $e'))
    .whenComplete(() => print('done'));
```

**The big win:** an exception thrown inside an awaited Future is caught by an
ordinary `try`/`catch` around the `await`. No special API, no wrapper exception,
and **the type you catch is the type that was thrown**.

Compare with `CompletableFuture`: `exceptionally`, `handle`, `whenComplete`, and
the real cause wrapped inside a `CompletionException` you have to unwrap with
`getCause`.

> **The unawaited-future trap.** If you call an async function and do not await
> it, and it throws, the error has nowhere to go — in Flutter that can take the
> app down.
>
> **The fix:** either `await` it, or wrap it in `unawaited()` to say explicitly
> that you meant it:
> ```dart
> unawaited(logAnalytics(order));
> ```
> The analyser has a lint called `unawaited_futures` that catches this, and Day 8
> turns it on.

## Doing several things at once

```dart
// Future.wait is CompletableFuture.allOf, and it returns the
// results in order.
final results = await Future.wait([
  fetchOrder('ORD-1'),
  fetchOrder('ORD-2'),
  fetchOrder('ORD-3'),
]);

// Three 800 ms calls finish in about 800 ms, not 2400 ms. Prove it:
final sw = Stopwatch()..start();
await Future.wait([
  fetchOrder('ORD-1'),
  fetchOrder('ORD-2'),
  fetchOrder('ORD-3'),
]);
print('${sw.elapsedMilliseconds} ms');

// First one to finish wins
final fastest = await Future.any([fetchOrder('a'), fetchOrder('b')]);

// Give up after a while
try {
  final o = await fetchOrder('ORD-1')
      .timeout(const Duration(milliseconds: 300));
} on TimeoutException {
  print('too slow');
}
```

**How, given there is one thread?** Waiting does not use the thread. Each call
hands the thread back while the network is busy, so the three waits overlap.

> **Say the distinction explicitly, because it matters this afternoon:**
> **Concurrency** is several things in progress. **Parallelism** is several things
> executing at the same instant. Dart gives you the first on one thread, and the
> second only with isolates.

- **`Future.wait` fails if any one fails.** The whole wait throws with the first
  error. If you need all results regardless, handle each future individually.
- **`Future.any`** is first-past-the-post — useful for racing a cache against a
  network.
- **`timeout` is the one you will use most in production.** Every network call
  should have one.
- **Results come back in order**, not in completion order.

## The sequential-await trap

```dart
// THE SEQUENTIAL TRAP. This takes 2400 ms:
final a = await fetchOrder('ORD-1');
final b = await fetchOrder('ORD-2');
final c = await fetchOrder('ORD-3');

// This takes 800 ms:
final results = await Future.wait([
  fetchOrder('ORD-1'),
  fetchOrder('ORD-2'),
  fetchOrder('ORD-3'),
]);

// Await in a loop is the same trap, wearing a disguise:
for (final id in ids) {
  await fetchOrder(id);           // one after another
}

// The parallel version:
await Future.wait(ids.map(fetchOrder));
```

**The loop version is the one that actually ships.** With fifty ids and a 200 ms
call, that is ten seconds and a frozen-looking screen.

**When sequential is correct:** when the second call needs the first call's
answer. Fetching an order, then fetching the invoice named by that order, must be
sequential — there is nothing to optimise and trying to would be wrong.

```dart
final order = await fetchOrder(id);
final invoice = await fetchInvoice(order.invoiceId);
```

> **The question to ask:** does call two need anything from call one? If no, they
> should overlap. If yes, they must not.

**One practical warning:** firing fifty parallel requests at a server is its own
problem. Real code batches them.

---

## LAB 4.1 · The order service · 40 min

**Goal** — a sealed exception hierarchy, a user-message switch, an async
`OrderService` with three failure modes, and a measured comparison of parallel
against sequential.

1. Fresh pad. **Paste in your Day 3 code first:** `Order`, `OrderLine`,
   `OrderStatus` and the sealed `OrderState`.
2. **TODO 1–2:** the sealed `OrderException` and its three subclasses.
3. **TODO 3:** `userMessage`, an exhaustive switch turning each exception into a
   friendly sentence.
4. **TODO 4:** `OrderService.submit`, waiting 800 ms then applying the three rules.
5. **TODO 5:** `runFlow`, printing Idle, Loading, then Loaded or Failed.
6. **TODO 6:** run the flow for all four cases: good, empty, out of stock, over
   500 units.
7. **TODO 7:** time three parallel submits with `Future.wait` and a `Stopwatch`.
8. **TODO 8:** time the same three sequentially and compare the two numbers.

> **Step 8 is the point of the lab.** Print both numbers and say them out loud.
> **Parallel about 800 ms, sequential about 2400 ms.** Concurrency is abstract
> until you measure it.

**Before you start:** `main` must be `async`, and forgetting `await` on `runFlow`
means the program ends before anything prints.

### Common errors

- `main` not marked `async`.
- Missing `await`, so `Instance of 'Future'` prints.
- Catching `Exception` instead of `OrderException`, so the exhaustive switch
  cannot be used.
- **Putting a `default` in `userMessage`**, which quietly removes the
  exhaustiveness the whole design depends on.

### Stretch

- Add a timeout of 300 ms to one submit and catch `TimeoutException`.
- Add a retry that attempts submit twice before giving up. *(Retrying an
  out-of-stock error is pointless; retrying a timeout is sensible. **Failure type
  should decide retry policy.**)*
- Make `submit` take an optional delay parameter so tests can run fast.

---

# Module 3 · Streams

**13:15 – 14:45**

By the end of this module you can:

- Explain the difference between a `Future` and a `Stream`
- Create a stream with `async*` and `yield`
- Consume a stream with `await for` and with `listen`
- Use a `StreamController`, and know why you must close it

> **A Future is one value later. A Stream is many values over time.** That is the
> whole distinction and everything else follows.

Java 8 has nothing quite like it in the standard library. Reactor's `Flux` and
RxJava's `Observable` are the closest, and a Dart `Stream` is considerably
simpler than either.

## Making and consuming a stream

```dart
// Making one with async* and yield
Stream<int> countdown(int from) async* {
  for (var i = from; i > 0; i--) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield i;
  }
}

// Consuming one with await for
Future<void> run() async {
  await for (final tick in countdown(3)) {
    print(tick);
  }
  print('liftoff');
}

// Or with listen, which does not block
final sub = countdown(3).listen(
  (value) => print('got $value'),
  onError: (e) => print('error $e'),
  onDone: () => print('finished'),
);

// ALWAYS CANCEL a subscription you no longer need, or it leaks.
await sub.cancel();
```

**The three stars matter:** `async` gives you a `Future`, **`async*` gives you a
`Stream`**. The star means many. `yield` emits one value and keeps going;
`return` ends the stream.

- **`await for` is the easy form.** It looks like a for loop and suspends until
  each value arrives. Use it when you genuinely want to process values in order.
- **`listen` does not block.** You hand it callbacks and carry on — `onData` as
  the positional argument, then `onError` and `onDone`.

> **The cancel rule is not optional.** A subscription you never cancel keeps the
> stream alive and keeps your object alive with it. On Day 7 that is a widget
> that has left the screen and is still receiving updates — the classic Flutter
> memory leak.

## Transforming streams, and broadcast

```dart
// The same operations you know from Iterable, but async.
final stream = countdown(10);
stream
    .where((i) => i.isEven)
    .map((i) => 'tick $i')
    .take(3)
    .listen(print);

// Collecting a whole stream into a list, which waits for it to finish
final all = await countdown(3).toList();

await countdown(3).first;
await countdown(3).length;
final total = await countdown(3).fold<int>(0, (s, i) => s + i);
final anyBig = await countdown(3).any((i) => i > 2);

// SINGLE SUBSCRIPTION versus BROADCAST.
final broadcast = countdown(3).asBroadcastStream();
broadcast.listen((v) => print('a: $v'));
broadcast.listen((v) => print('b: $v'));
```

The vocabulary is yesterday's — `where`, `map`, `take`, `fold`, `any`, `first`,
`length`. The difference is that **terminal operations return a `Future`**,
because the answer cannot be known until the stream finishes.

`toList()` on a stream waits for it to finish. On an infinite stream it never
returns.

> **Single subscription versus broadcast is the important half of this slide.**
> A normal stream permits **one** listener, and a second `listen` throws a
> `StateError`. That seems restrictive until you realise the alternative is
> silently splitting a network response between two consumers.
>
> **A broadcast stream permits many listeners, but it does not replay** — a
> listener that arrives late misses everything already emitted. That is the source
> of the classic "my stream is not working" bug.

**Which to use:** single subscription for a one-off, like a file read or a single
request. Broadcast for events several parts of the app care about.

## `StreamController`: making a stream from anything

```dart
// A StreamController is how you create a stream from events
// that are not already a stream: a button, a socket, a queue.
class OrderEvents {
  final _controller = StreamController<Order>.broadcast();

  // The read side, handed out to anyone who wants to listen
  Stream<Order> get stream => _controller.stream;

  // The write side, kept private
  void submitted(Order order) => _controller.add(order);
  void failed(Object error) => _controller.addError(error);
  Future<void> dispose() => _controller.close();
}

final events = OrderEvents();
events.stream.listen((o) => print('order ${o.id} submitted'));
events.submitted(order);
```

**Why it exists:** `async*` works when you already have a loop producing values. A
`StreamController` is for when values arrive from somewhere you do not control.

**The pattern is the important part, not the API.** The controller is private.
The class exposes `stream` for reading, and named methods for writing. Nobody
outside can add to the stream directly.

Compare it to a Java listener list: a private `List<Listener>`, an `addListener`
method, and a `fire` method. Same design, with the plumbing supplied.

**`addError` puts an error into the stream** rather than throwing. Listeners get
it in their `onError` callback.

> **Closing is not optional.** An open controller with listeners keeps everything
> alive. On Day 7 every controller gets closed in a widget's `dispose` method, and
> forgetting is the most common leak in Flutter code.

Use `.broadcast()` for events. The default single-subscription controller throws
on the second listener.

---

## LAB 4.2 · An order event stream · 35 min

**Goal** — a stream of `OrderState` values, consumed two ways, plus a broadcast
`StreamController` with two listeners and a transformation chain.

1. Continue in the same pad. **Add `import 'dart:async';` at the top** — this is
   the first thing people forget.
2. **TODO 1:** `submitStream`, an `async*` function yielding Loading, then Loaded
   or Failed.
3. **TODO 2:** consume it with `await for` and print `describe` for each state.
4. **TODO 3:** consume it again with `listen`, using all three callbacks.
5. **TODO 4:** the `OrderEvents` class wrapping a broadcast `StreamController`.
6. **TODO 5:** attach two listeners, push two orders through, then dispose.
7. **TODO 6:** a chain over a ten-tick stream: keep the even ones, map to text,
   take three.
8. **TODO 7:** run each in turn and check against Appendix B.

> `asFuture` appears in the solution and is slightly obscure: it turns a
> subscription into a `Future` that completes when the stream is done, which is
> how you wait for a `listen`-based consumer.

### Stretch — the first two are the real lesson

- Remove `.broadcast()` from the controller and see what the second listener
  does. *(A `StateError` — the error you would otherwise meet for the first time
  in a Flutter widget at an inconvenient moment.)*
- Attach a listener **after** pushing the first order and confirm it misses it.
- Add an error to the stream with `addError` and handle it in the listener.

---

# Module 4 · Isolates, and the frame budget

**15:00 – 16:00**

By the end of this module you can:

- Explain why Dart has no shared-memory threads
- Say what `async` and `await` do and do **not** give you
- Use `compute` to move CPU work off the UI thread
- State the frame budget and what exceeding it looks like

## No threads: one isolate, one thread, no shared memory

**Dart has no threads in the Java sense.** An isolate has its own memory and its
own single thread. Isolates cannot see each other's memory at all. They talk by
sending messages, and **messages are copied**.

Consequences:

- no `synchronized`
- no `volatile`
- no locks, no deadlocks
- no data races
- no happens-before reasoning

**An entire category of Java bug simply does not exist.** Every concurrency bug
you have ever debugged comes from two threads touching the same memory. Remove
shared memory and the whole category is gone.

**The cost, honestly:** you cannot hand a large object graph to another isolate
cheaply, because it is copied. For most app work that is irrelevant. For
genuinely large data it is a real design constraint.

> **The misconception to kill, and it is the most important point of the hour:**
>
> `async` and `await` do **not** give you another thread. They yield the **one**
> thread while waiting on IO. **If your Dart code is busy computing, nothing else
> runs** — including the user interface.
>
> Awaiting a network call frees the thread. Awaiting a busy loop does not,
> because there is nothing to wait for.

**Can Dart use multiple cores?** Yes — with several isolates. Flutter apps rarely
need to, because the work is IO-bound. When you do need it, `compute` is the
one-line version and `Isolate.spawn` is the manual one.

This model is closer to Node's than to Java's, with the important addition that
you can spawn real isolates for CPU work.

## `compute`: the one-line escape hatch

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';

// A top-level or static function. It must be, because it has
// to be sendable to another isolate.
List<Order> parseOrders(String body) {
  final list = jsonDecode(body) as List<dynamic>;
  return list
      .map((e) => Order.fromJson(e as Map<String, dynamic>))
      .toList();
}

// compute() runs it on a background isolate and gives you a
// Future for the answer. One line.
final orders = await compute(parseOrders, responseBody);
```

**`compute` takes a function and one argument and returns a Future.** That is the
whole API — Flutter handles spawning, messaging and teardown.

- **The function must be top-level or static.** It cannot be a closure or an
  instance method, because the function itself has to be sendable. The error
  message when you get this wrong is not obvious.
- **One argument only.** If you need several values, pass a record or a small
  class — a nice callback to Day 3.

**When to reach for it:** JSON over roughly 100 KB, image processing, encryption
or hashing, any loop that runs for more than a few milliseconds.

**When not to:** network calls. Those are already IO-bound, so `await` is enough
and `compute` would only add copying overhead.

**The copying cost is real.** For a small result it is nothing. For a huge list it
can cost more than the work saved. Measure rather than assume.

> `compute` comes from `package:flutter/foundation.dart`, so it is **not
> available in a plain DartPad**. Lab 4.3 measures the problem rather than calling
> the API; you use the real thing on Day 8.

## The sixteen millisecond budget

```
60 frames per second  =  16.7 ms per frame
120 Hz display        =   8.3 ms per frame
```

That budget covers **building your widgets, laying them out, and painting them**.
Your own code shares it.

A 200 ms JSON parse on the UI thread is **12 dropped frames**, and the user sees a
visible stutter.

> On a server, a slow method costs one request out of a pool of two hundred, and
> the pool absorbs it. Here there is no pool. **There is one thread, and it is
> also drawing the screen.**
>
> Ask yourself what your p99 latency target is. If the answer is 200 ms and you
> are quietly proud of it — that is twelve dropped frames here.

**The three answers, in order of preference:**

1. **Do less work**
2. **Do it when the user is not watching**
3. **Move it to another isolate with `compute()`**

Most people reach for the third first. The first is usually the right answer.

Most current phones are 120 Hz, which halves the budget to 8.3 ms — the target is
tighter than people assume.

---

## LAB 4.3 · Measuring what blocking costs · 20 min

**Goal** — a deliberately slow calculation, timed, converted into dropped frames,
and reasoned about out loud.

1. Continue in the same pad. Copy the starter from **Appendix C**.
2. **TODO 1:** `sumOfSquares`, a plain loop from one to fifty million.
3. **TODO 2:** time it with a `Stopwatch` and print the milliseconds.
4. **TODO 3:** divide by 16.7 and print how many frames that is.
5. **TODO 4:** say to the person next to you what the screen would be doing
   during that time.
6. **TODO 5:** write a comment saying which of the three answers applies, and why.

> **TODO 4 is not filler.** Saying *"the screen would be completely frozen — no
> scrolling, no taps, no animation"* out loud is what converts a number into an
> instinct.

### Stretch — the first one is the most valuable thing in the lab

- **Wrap the call in an `async` function and `await` it. Confirm the timing does
  not change at all, and explain why.** *(There is no IO to wait for. This
  demonstration kills the async-equals-threading misconception permanently.)*
- Reduce `n` until the result is under 16 milliseconds. That is your budget, in
  units of work.
- Write down one thing in your own systems that would need `compute` if you moved
  it here.

---

# Day 4 recap

- **There are no checked exceptions.** Document failure in the return type
  instead, which is what a sealed state does.
- `on` catches a type, `catch` takes anything, the second catch parameter is the
  stack trace, and **`rethrow` preserves it**.
- **An Exception is something the world did to you. An Error is a bug.** Catch the
  first, fix the second.
- **A sealed exception hierarchy makes it impossible to ship a failure mode with
  no user-facing message.**
- `Future` is `CompletableFuture`, and `await` replaces every `thenApply` chain
  with straight-line code and ordinary `try`/`catch`.
- **`Future.wait` overlaps waiting.** Three 800 ms calls take 800 ms. Awaiting in
  a loop does not.
- **A Stream is many values over time.** `async*` and `yield` produce one;
  `await for` and `listen` consume one. **Cancel and close, always.**
- **One isolate, one thread, no shared memory, no locks.** `async` yields the
  thread; only `compute` moves work off it.
- **16.7 milliseconds per frame** is the budget for everything.

**Tomorrow (Day 5 · Flutter Foundations):** everything is a widget, the widget /
element / render trees, stateless and stateful widgets and `setState`, the widget
catalogue, and your order model finally on a screen.

---

## Homework tonight · 20 min — compulsory

[dart.dev/libraries/async/async-await](https://dart.dev/libraries/async/async-await)
— the whole page, then "Creating streams".

1. The page describes what happens when an async function runs **before it hits
   its first `await`**. What is it, and why might that matter?
2. Find the section on handling errors in async functions. What does it say about
   an error thrown **before** the first `await`?
3. In the streams page, find the difference between `async*` and a
   `StreamController`. When would you choose each?
4. **Come with one question** about anything from the last four days that is
   still unclear.

> Question 4 is the real one. Tomorrow morning is the last clean moment to clear
> up four days of language before new material starts landing on top.

---

# Appendix A · Lab 4.1

### Starter

```dart
// LAB 4.1 STARTER - dartpad.dev
// Paste in your Day 3 Order, OrderLine, OrderStatus and the
// sealed OrderState first.

// TODO 1: a sealed class OrderException implements Exception
//         with a final String message and toString
// TODO 2: three subclasses
//           EmptyOrderException       'An order needs at least one line'
//           OutOfStockException(sku)  '<sku> is out of stock'
//           ApprovalRequiredException 'Orders over 500 units need approval'
// TODO 3: String userMessage(OrderException e) using an
//         exhaustive switch, returning a friendly sentence
// TODO 4: a class OrderService with
//           Future<Order> submit(Order order)
//         that waits 800 ms, then
//           throws EmptyOrderException if there are no lines
//           throws ApprovalRequiredException if itemCount > 500
//           throws OutOfStockException('SKU-9') if any line uses SKU-9
//           otherwise returns a copy with status submitted
// TODO 5: Future<void> runFlow(Order order) that prints the
//         Idle and Loading descriptions, awaits submit, then
//         prints Loaded or Failed using your userMessage

void main() async {
  // TODO 6: run the flow for a good order, an empty order,
  //         an order with SKU-9, and an order of 600 units
  // TODO 7: time three parallel submits with Future.wait and
  //         a Stopwatch, and print the milliseconds
  // TODO 8: time the same three sequentially and compare
}
```

### Solution

```dart
sealed class OrderException implements Exception {
  const OrderException(this.message);
  final String message;

  @override
  String toString() => message;
}

class EmptyOrderException extends OrderException {
  const EmptyOrderException() : super('An order needs at least one line');
}

class OutOfStockException extends OrderException {
  const OutOfStockException(this.sku) : super('out of stock');
  final String sku;
}

class ApprovalRequiredException extends OrderException {
  const ApprovalRequiredException()
      : super('Orders over 500 units need manual approval');
}

String userMessage(OrderException e) => switch (e) {
      EmptyOrderException() => 'Add at least one item before submitting.',
      OutOfStockException(:final sku) => 'Sorry, $sku is out of stock.',
      ApprovalRequiredException() =>
        'This order needs a manager to approve it.',
    };

class OrderService {
  Future<Order> submit(Order order) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (order.lines.isEmpty) throw const EmptyOrderException();
    if (order.itemCount > 500) throw const ApprovalRequiredException();
    if (order.lines.any((l) => l.sku == 'SKU-9')) {
      throw const OutOfStockException('SKU-9');
    }
    return order.copyWith(status: OrderStatus.submitted);
  }
}

Future<void> runFlow(Order order) async {
  print(describe(const OrderIdle()));
  print(describe(const OrderLoading()));
  try {
    final saved = await OrderService().submit(order);
    print(describe(OrderLoaded(saved)));
  } on OrderException catch (e) {
    print(describe(OrderFailed(userMessage(e))));
  }
  print('---');
}

void main() async {
  const good = Order(
    id: 'ORD-1042',
    customer: 'Acme Ltd',
    lines: [
      OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
    ],
  );
  const empty = Order(id: 'ORD-1043', customer: 'Beta Co', lines: []);
  const missing = Order(
    id: 'ORD-1044',
    customer: 'Gamma',
    lines: [
      OrderLine(sku: 'SKU-9', description: 'Ghost', quantity: 1, unitPrice: 10),
    ],
  );
  const huge = Order(
    id: 'ORD-1045',
    customer: 'Delta',
    lines: [
      OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 600, unitPrice: 250),
    ],
  );

  await runFlow(good);
  await runFlow(empty);
  await runFlow(missing);
  await runFlow(huge);

  final parallel = Stopwatch()..start();
  await Future.wait([
    OrderService().submit(good),
    OrderService().submit(good),
    OrderService().submit(good),
  ]);
  print('parallel   ${parallel.elapsedMilliseconds} ms');

  final serial = Stopwatch()..start();
  await OrderService().submit(good);
  await OrderService().submit(good);
  await OrderService().submit(good);
  print('sequential ${serial.elapsedMilliseconds} ms');
}
```

### Expected

```
parallel   about 800 ms
sequential about 2400 ms
```

**Those two numbers are the lesson.**

---

# Appendix B · Lab 4.2

### Starter

```dart
// LAB 4.2 STARTER - continue in the same pad
import 'dart:async';

// TODO 1: a Stream<OrderState> function using async* that
//         yields OrderLoading, waits 800 ms, then yields
//         OrderLoaded or OrderFailed. Call it submitStream.
// TODO 2: consume it with await for and print describe() for
//         each state that arrives
// TODO 3: consume it again with listen, printing on data,
//         on error and on done
// TODO 4: a class OrderEvents wrapping a
//         StreamController<Order>.broadcast() with
//           Stream<Order> get stream
//           void submitted(Order order)
//           Future<void> dispose()
// TODO 5: attach TWO listeners to the broadcast stream, push
//         two orders through it, then dispose
// TODO 6: take a stream of ten ticks, keep only the even ones,
//         map them to text, take the first three, and print

void main() async {
  // TODO 7: run each of the above in turn
}
```

### Solution

```dart
import 'dart:async';

Stream<OrderState> submitStream(Order order) async* {
  yield const OrderLoading();
  await Future.delayed(const Duration(milliseconds: 800));
  try {
    final saved = await OrderService().submit(order);
    yield OrderLoaded(saved);
  } on OrderException catch (e) {
    yield OrderFailed(userMessage(e));
  }
}

Stream<int> ticks(int count) async* {
  for (var i = 1; i <= count; i++) {
    await Future.delayed(const Duration(milliseconds: 50));
    yield i;
  }
}

class OrderEvents {
  final _controller = StreamController<Order>.broadcast();
  Stream<Order> get stream => _controller.stream;
  void submitted(Order order) => _controller.add(order);
  Future<void> dispose() => _controller.close();
}

void main() async {
  const good = Order(
    id: 'ORD-1042',
    customer: 'Acme Ltd',
    lines: [
      OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
    ],
  );

  await for (final state in submitStream(good)) {
    print('await for: ${describe(state)}');
  }

  final sub = submitStream(good).listen(
    (state) => print('listen: ${describe(state)}'),
    onError: (e) => print('listen error: $e'),
    onDone: () => print('listen done'),
  );
  await sub.asFuture<void>();

  final events = OrderEvents();
  events.stream.listen((o) => print('listener A: ${o.id}'));
  events.stream.listen((o) => print('listener B: ${o.id}'));
  events.submitted(good);
  events.submitted(good.copyWith(id: 'ORD-1043'));
  await Future.delayed(const Duration(milliseconds: 50));
  await events.dispose();

  final labels = await ticks(10)
      .where((i) => i.isEven)
      .map((i) => 'tick $i')
      .take(3)
      .toList();
  print(labels);
}
```

### Expected tail

```
[tick 2, tick 4, tick 6]
```

---

# Appendix C · Lab 4.3

### Starter

```dart
// LAB 4.3 STARTER - continue in the same pad

// TODO 1: a top-level function
//           int sumOfSquares(int n)
//         that loops from 1 to n adding i*i. Make n large
//         enough to take a noticeable moment, around 50 million.
// TODO 2: time it with a Stopwatch and print the milliseconds
// TODO 3: explain to your neighbour, out loud, what would be
//         happening to the user interface during that time if
//         this were running in a Flutter app
// TODO 4: write a comment saying which of the three answers
//         applies here: do less work, do it later, or move it
//         to another isolate

// NOTE: compute() lives in package:flutter/foundation.dart, so
// it is not available in a plain DartPad. On Day 8 you will
// call the real thing. Today the point is the measurement and
// the reasoning, not the API.

void main() {
  // TODO 5: run it and read the number out loud
}
```

### Solution

```dart
int sumOfSquares(int n) {
  var total = 0;
  for (var i = 1; i <= n; i++) {
    total += i * i;
  }
  return total;
}

void main() {
  final sw = Stopwatch()..start();
  final result = sumOfSquares(50000000);
  sw.stop();
  print('result $result');
  print('took   ${sw.elapsedMilliseconds} ms');
  print('frames dropped at 60fps: ${(sw.elapsedMilliseconds / 16.7).round()}');

  // Answer to TODO 4: this is pure computation with no IO, so
  // await would not help at all. The right answer is to move it
  // to another isolate with compute(). On a real screen the
  // interface would be completely frozen for the whole duration:
  // no scrolling, no taps, no animation.
}
```

> A typical result is several hundred milliseconds, which is tens of dropped
> frames.

---

# Appendix D · Async cheat sheet: Java to Dart

| Java 8 | Dart | Note |
|---|---|---|
| `CompletableFuture<T>` | `Future<T>` | Same idea |
| `completedFuture(v)` | `Future.value(v)` | |
| `failedFuture(e)` | `Future.error(e)` | |
| `thenApply(f)` | `await` then use it | Straight-line code |
| `thenCompose(f)` | `await` twice | No flattening needed |
| `allOf(...)` | `Future.wait([...])` | Returns results in order |
| `anyOf(...)` | `Future.any([...])` | First to finish |
| `exceptionally(f)` | `try` / `catch` | No wrapper exception |
| `whenComplete(f)` | `finally` | |
| `orTimeout(...)` | `.timeout(...)` | Throws `TimeoutException` |
| `get()` / `join()` | `await` | Never blocks a thread |
| Reactor `Flux` | `Stream<T>` | Much simpler |
| `Flux.create` | `StreamController` | Close it, always |
| `subscribe(...)` | `.listen(...)` | Cancel it, always |
| Thread / executor | isolate / `compute` | No shared memory |
| `synchronized` | *nothing* | Not needed. No shared memory |
| `throws IOException` | *nothing* | No checked exceptions |
| `throw e` in a catch | `rethrow` | Preserves the stack trace |

---

# Appendix E · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Prints `Instance of 'Future'` | Missing `await` | Add `await`, and make the caller `async` |
| `await is only allowed in async functions` | Function not marked `async` | Add `async` before the body |
| Nothing prints and the program exits | `main` not awaited or not async | `void main() async` and await your calls |
| Unhandled exception after everything else | A Future nobody awaited threw | Await it, or wrap in `unawaited()` |
| Parallel code is as slow as sequential | `await` inside the list literal | Put the **calls** in the list, await the wait |
| `Bad state: Stream has already been listened to` | Second listener on a single-subscription stream | Use `.broadcast()` or `asBroadcastStream()` |
| A listener receives nothing | Attached after the events were emitted | Broadcast streams do not replay. Listen first |
| `StreamController` never finishes | Never closed | Call `close()`, usually in `dispose` |
| `TimeoutException` in a lab | The timeout is shorter than the fake delay | That is the point. Catch it |
| `compute` will not accept the function | Closure or instance method | It must be top-level or static |
| Stack trace is short and useless | `throw e` inside a catch | Use `rethrow` |
| Async code blocks the UI anyway | CPU work, not IO | `await` does not help. Use `compute` |
| `Undefined class StreamController` | Missing import | `import 'dart:async';` |

---

# Appendix F · Links

| Topic | Link |
|---|---|
| Error handling | https://dart.dev/language/error-handling |
| Exception class | https://api.dart.dev/dart-core/Exception-class.html |
| Asynchronous programming | https://dart.dev/libraries/async/async-await |
| Futures, error handling | https://dart.dev/libraries/async/futures-error-handling |
| Streams | https://dart.dev/libraries/async/using-streams |
| Creating streams | https://dart.dev/libraries/async/creating-streams |
| Concurrency and isolates | https://dart.dev/language/concurrency |
| `compute` | https://api.flutter.dev/flutter/foundation/compute.html |
| Effective Dart, usage | https://dart.dev/effective-dart/usage |
