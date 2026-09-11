# Day 5 · Flutter Foundations — Delegate Handbook

**Flutter for Java Developers · 8-Day Programme · Day 5 of 8**

Everything is a widget · Stateless and stateful · The catalogue · Composition

> **Four days of language. Today it goes on a phone.**
>
> There is much less to learn here than you expect. Flutter is Dart arranged in a
> particular shape. The classes you wrote on Day 2, the sealed states from Day 3,
> the async from Day 4 — all of it goes on screen today more or less unchanged.

> ## The one big idea
>
> **The user interface is a function of state.** You do not *update* the screen;
> you *describe* what the screen should look like for the current state, and the
> framework works out the difference.
>
> ## `UI = f(state)`
>
> Write that down. Every confusing Flutter moment this week is explained by it.

---

## Today's agenda

| | Time | Block |
|---|---|---|
| 1 | 09:00 – 10:30 | **The widget model** — declarative vs imperative, everything is a widget, the three trees, why rebuilding is cheap |
| 2 | 10:45 – 12:30 | **Stateless and stateful** — `StatelessWidget`, `StatefulWidget` and `State`, `setState`, the `mounted` check, **Lab 5.1** |
| 3 | 13:15 – 14:45 | **The catalogue** — Scaffold, AppBar, buttons, Text, Icon, Image, Container, SnackBars, dialogs, **Lab 5.2** |
| 4 | 15:00 – 16:00 | **Composition** — Extract Widget, `const`, keys, BuildContext, **Lab 5.3** |

> **What today is not:** layout. Rows, columns and the constraint system are
> **tomorrow**, and today deliberately keeps the layouts simple so the widget
> model can land on its own.

**You need a working device today.** If yours is not ready, `flutter run -d chrome`
— everything today works in a browser.

---

# Module 1 · The widget model

**09:15 – 10:30**

By the end of this module you can:

- Explain the difference between describing a screen and updating one
- Say what a widget is and why there are so many of them
- Describe the widget, element and render trees
- Explain why creating thousands of widgets a second is fine

## Describing a screen, not updating one

```java
// IMPERATIVE, the way Swing, Android Views and the DOM work.
// You build the thing once, keep a reference, and mutate it.
Label total = new Label("R 0.00");
panel.add(total);

// ...later...
total.setText("R 11 500.00");
total.setForeground(Color.RED);
if (isEmpty) { total.setVisible(false); }
```

**How many places in that code set the colour of the total?** In a real screen
the answer is four or five, scattered across different event handlers. And if the
requirement changes to add a third colour, you must find all of them.

**The bug class is stale UI.** The state changed and one of the setters was not
called. Everyone has shipped that bug. It is unreachable by unit tests and it is
found by users.

```dart
// DECLARATIVE, the way Flutter works.
// You describe what the screen looks like FOR THIS STATE.
Widget build(BuildContext context) {
  if (order.isEmpty) return const SizedBox.shrink();
  return Text(
    order.subtotal.rands,
    style: TextStyle(color: order.isLarge ? Colors.red : Colors.black),
  );
}
```

**There is no transition to get wrong, because you never describe a transition.**
When the state changes, the function runs again and returns a new description.

The obvious objection — *"so you redraw the whole screen every time?"* — is
answered by the three trees, two slides below.

## Everything is a widget

```dart
// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const OrderFlowApp());
}

class OrderFlowApp extends StatelessWidget {
  const OrderFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrderFlow',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2A9D8F),
        useMaterial3: true,
      ),
      home: const OrderScreen(),
    );
  }
}

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: const Center(child: Text('No orders yet')),
    );
  }
}
```

**The definition:** a widget is an **immutable description of part of the
screen**. Not the thing on screen — the description of it.

**Why there are so many:** padding is a widget, alignment is a widget, the theme
is a widget, a gesture detector is a widget. That sounds excessive, and it buys
you something specific: **there is exactly one composition mechanism to learn.**
You never wonder whether padding is a property or a wrapper. It is always a
wrapper.

In Swing or Android you would set a padding property on a component. Here you
wrap it. **Composition instead of configuration** — the same argument you heard
on Day 3 about inheritance.

## Three trees, and why rebuilding is cheap

| Tree | What it is |
|---|---|
| **Widget tree** | Immutable configuration, created and discarded constantly. Think of a widget as the **arguments to a builder**, not the object being built. |
| **Element tree** | The live instances. An element knows its position, its parent and children, and **it holds any `State` object. It survives rebuilds.** |
| **Render object tree** | Layout and painting. Expensive, and deliberately the smallest of the three. |

When you rebuild, Flutter walks the new widget tree against the existing element
tree. Same type in the same position means it **updates the existing element**
rather than creating a new one. The render objects mostly do not change at all.

> **The consequence, stated explicitly because the instinct to optimise is
> strong:**
> - creating a widget is close to free
> - rebuilding a whole screen is normal and expected
> - **do not cache widgets, do not avoid rebuilding, do not hold references to
>   widgets**
>
> All three are exactly what an experienced Swing or Android developer will reach
> for, and all three are wrong here.

**The analogy that helps:** it is closer to rendering an HTML page from a
template than to mutating a component tree.

## What this means for how you write code

| Rule | Why |
|---|---|
| **`build()` must be fast and pure** | No network calls, no database writes, no dialogs, no `setState`. It may be called sixty times a second. If it has a side effect, that side effect happens sixty times a second. |
| **Do not hold references to widgets** | They are thrown away constantly. Hold state in a `State` object, or from Day 7 in a state manager. |
| **Never fetch data in `build()`** | That is a side effect, and it will fire on every rebuild. Initial loads go in `initState`. |
| **Long build methods are a smell** | If it does not fit on one screen, extract a widget. That is this afternoon, and it is the single most useful habit in Flutter. |
| **Composition, not configuration** | A padded, centred, coloured box is four widgets nested, not one widget with four properties. |

> **Everybody, at least once, calls a service from `build` and watches it fire in
> an infinite loop.** It is a rite of passage. Knowing it now means you recognise
> it in ten seconds rather than twenty minutes.

---

# Module 2 · Stateless and stateful widgets

**10:45 – 12:30**

By the end of this module you can:

- Write a `StatelessWidget` with final fields
- Write a `StatefulWidget` and explain why it is two classes
- Use `setState` correctly, including the `mounted` check after an `await`
- Choose between stateless, stateful, and neither

## `StatelessWidget`

```dart
// lib/features/orders/presentation/order_header.dart
class OrderHeader extends StatelessWidget {
  const OrderHeader({
    super.key,
    required this.orderId,
    required this.customer,
  });

  final String orderId;
  final String customer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(orderId, style: text.titleLarge),
        Text(customer, style: text.bodyMedium),
      ],
    );
  }
}

// Use it in a parent:
const OrderHeader(orderId: 'ORD-1042', customer: 'Acme Ltd')
```

**The whole contract:** extend `StatelessWidget`, take arguments in a `const`
constructor, store them in `final` fields, return a tree from `build`.

- **All fields are `final`**, and the analyser enforces it. A widget is immutable
  configuration. If you want it to change, the parent gives you a new one.
- **`super.key`** — keys are covered this afternoon. For now, include it.
- **Style from the text theme**, never a raw `fontSize`. `titleLarge`,
  `bodyMedium`. Day 7 explains the payoff when the app rebrands in one line.

> **Stateless is the default.** Most widgets in a real app are stateless, and
> beginners reach for stateful far too often.

## `StatefulWidget`: two classes, and why

```dart
class QuantityPicker extends StatefulWidget {
  const QuantityPicker({super.key, required this.sku});

  // The widget holds the immutable configuration
  final String sku;

  @override
  State<QuantityPicker> createState() => _QuantityPickerState();
}

class _QuantityPickerState extends State<QuantityPicker> {
  // The State holds the mutable data, and it SURVIVES rebuilds
  int _quantity = 1;

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // widget.sku reaches the configuration from the State
        Text('${widget.sku}  x$_quantity'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _increment,
        ),
      ],
    );
  }
}
```

**Why two classes, and this is the satisfying part:** the widget is recreated
every time its parent rebuilds, which may be sixty times a second. If the
quantity lived in the widget, **it would be reset sixty times a second**. So it
lives in the `State`, and the `State` is attached to the **element**, which
survives.

- **`widget.sku`** is how you reach the current configuration from inside the
  `State` — and it is always **current**. When the parent gives a new widget,
  Flutter swaps it in and `widget.sku` is the new value automatically.
- **The naming convention:** `_QuantityPickerState`, private, underscore-prefixed
  fields. That is Day 2 file privacy showing up in real code.
- **The cost of stateful:** more ceremony, a lifecycle to respect, and something
  that has to be disposed.

## `setState`, and the `mounted` check

```dart
// setState does ONE thing: it marks this element dirty so that
// Flutter rebuilds it on the next frame.
// It does NOT set anything. You change the field yourself.
void _increment() {
  setState(() {
    _quantity++;          // the actual change
  });                     // setState schedules the rebuild
}

// THE CLASSIC BEGINNER BUG: changing the field OUTSIDE setState.
void _broken() {
  _quantity++;            // the value changes...
}                         // ...and nothing on screen moves

// EQUALLY WRONG, and harder to spot: async work inside setState.
void _alsoBroken() {
  setState(() async {     // never do this
    _order = await service.submit(order);
  });
}

// CORRECT: do the await first, then setState with the result.
Future<void> _submit() async {
  setState(() => _isLoading = true);
  final saved = await service.submit(order);
  if (!mounted) return;   // the user may have left the screen
  setState(() {
    _isLoading = false;
    _order = saved;
  });
}
```

**What it actually does:** marks this element dirty. Flutter rebuilds it on the
next frame. It is a **scheduling call, not an assignment**, and the name is
slightly misleading.

- **Bug one:** changing a field outside `setState`. The value changes, nothing
  moves, and you stare at the screen.
- **Bug two:** an async callback inside `setState`. `setState` is synchronous — it
  takes a `void` callback and runs it immediately. An async callback returns a
  Future nobody awaits.

> **The `mounted` check is not optional.** Between the `await` starting and
> finishing, the user may have pressed back. The `State` is then gone, and calling
> `setState` on it throws. With real network latency this happens constantly.
>
> **After every `await`, before touching `setState` or `context`, check
> `mounted`.** There is a lint for it and Day 8 turns it on.

**Keep `setState` callbacks tiny.** Change the field and nothing else. Work
belongs outside.

## The State lifecycle

```dart
class _OrderScreenState extends State<OrderScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Called ONCE, when the State is created.
    // Set up controllers, start listeners, kick off a first load.
    // You cannot use Theme.of(context) safely here.
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Called after initState and whenever an inherited widget
    // this State depends on changes. Safe to use context here.
  }

  @override
  void didUpdateWidget(OrderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent rebuilt and gave us a new widget.
  }

  @override
  Widget build(BuildContext context) {
    // Called often. Must be fast and must have NO side effects.
    return const SizedBox.shrink();
  }

  @override
  void dispose() {
    // Called ONCE, when the State leaves the tree for good.
    _controller.dispose();
    super.dispose();
  }
}
```

> **The rule that matters most, said as a pair:** *anything you create in
> `initState`, you destroy in `dispose`.* Every controller, every stream
> subscription, every timer. It is the Flutter equivalent of closing a JDBC
> connection, and **forgetting it is the most common leak in Flutter code**.

That `StreamController` from Day 4 must be closed in `dispose`. That subscription
must be cancelled. Yesterday's warning, arriving in its real context.

**A rough parallel:** `initState` is a constructor with context, `dispose` is
close or destroy, and `build` is `toString` called by the framework.

## Stateless, stateful, or neither

| Choice | When |
|---|---|
| **Stateless** | Everything it shows comes from its constructor arguments. `OrderHeader`, `LineTile`, `TotalsRow` — most things. **The default.** |
| **Stateful** | It owns a controller, or has local UI state nobody else needs: a toggle, an expanded panel, a slider position, the current tab. Anything needing `initState` or `dispose`. |
| **Neither** | If a second screen needs the value, it is not widget state at all. The order itself, the signed-in user, the saved list. That goes to a state manager on **Day 7**. |

> **The test:** would any other widget ever need to read this value? If yes, it
> does not belong inside either of them. Lift it out.

**A common mistake:** making the whole screen stateful because one small part of
it changes. Make the small part its own stateful widget instead, and keep the
screen stateless. The whole screen then does not rebuild for every keystroke —
that is the Day 8 performance lesson, available for free today.

**Start stateless. Promote to stateful only when you need a controller or a
lifecycle. Lift out to a state manager the moment a second widget cares.**

---

## LAB 5.1 · Your first interactive screen · 40 min

**Goal** — your Day 3 order model inside the real project, and a stateful screen
with buttons that change a quantity and a live total.

1. Create `lib/features/orders/domain/order_model.dart` and paste in your Day 3
   code. **Delete any `main` function from it** — two `main`s gives a confusing
   error.
2. Create `lib/main.dart` with `runApp`, and `lib/app.dart` with `OrderFlowApp`
   as a `StatelessWidget`.
3. Create `order_screen.dart` as a `StatefulWidget` with an `int _quantity`
   starting at 10.
4. Build a `Scaffold` with an `AppBar` titled OrderFlow.
5. In the body, show the quantity, with an add and a remove `IconButton` either
   side that change it with `setState`.
6. Below that, show the quantity times 250, formatted with your `.rands` extension.
7. Add a `FloatingActionButton` that resets the quantity and shows a `SnackBar`.
8. **Run it. Tap the buttons up to twenty. Then change a string and hot reload,
   and confirm the quantity survives.**
9. `flutter analyze` clean, then commit.

> **Step 8 is the actual lesson.** The twenty survives a hot reload. That is the
> element tree from this morning, demonstrated on your own machine.

**The import path catches people** and is case sensitive:
`package:order_flow/features/orders/domain/order_model.dart`

### Stretch

- Clamp the quantity so it cannot go below zero, and disable the remove button at
  zero by passing `null`.
- Add a second unit price and show which discount band the total falls into.
- Extract the quantity row into its own stateful widget and confirm the screen
  still works.

---

# Module 3 · The widget catalogue

**13:15 – 14:45**

By the end of this module you can:

- Use `Scaffold`, `AppBar` and the Material 3 button family
- Display text, icons and images correctly
- Show a `SnackBar`, a dialog and a bottom sheet
- Handle loading and empty states as first-class cases

> **You are not expected to remember these.** You are expected to know what
> exists and where to look. The widget catalogue on docs.flutter.dev is the
> reference, and your editor's autocomplete is faster than your memory.

## `Scaffold`: the standard page frame

```dart
Scaffold(
  appBar: AppBar(
    title: const Text('Orders'),
    actions: [
      IconButton(
        icon: const Icon(Icons.refresh),
        tooltip: 'Refresh',
        onPressed: _reload,
      ),
    ],
  ),
  body: const Center(child: Text('No orders yet')),
  floatingActionButton: FloatingActionButton(
    onPressed: _newOrder,
    child: const Icon(Icons.add),
  ),
  bottomNavigationBar: NavigationBar(
    selectedIndex: _tab,
    onDestinationSelected: (i) => setState(() => _tab = i),
    destinations: const [
      NavigationDestination(icon: Icon(Icons.list), label: 'Orders'),
      NavigationDestination(icon: Icon(Icons.inventory), label: 'Stock'),
    ],
  ),
  drawer: const Drawer(child: Text('Menu')),
)
```

**`Scaffold` is a layout contract, not decoration.** It knows where the app bar
goes, where the keyboard pushes the body, where a `SnackBar` appears, and how the
floating action button avoids the bottom bar.

- **It provides the anchor for SnackBars and bottom sheets**, which is why
  `ScaffoldMessenger` needs one above it in the tree. That is the source of the
  most common `BuildContext` error in Flutter.
- **`NavigationBar` is the Material 3 bottom bar.** If you find
  `BottomNavigationBar` in an older tutorial, that is the Material 2 one.
- **Always set a `tooltip`** on an `IconButton` — it is what a screen reader
  announces.

## Text, icons and images

```dart
// TEXT
Text('ORD-1042')

Text(
  'A very long customer name that will not fit on one line',
  style: Theme.of(context).textTheme.titleMedium,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  textAlign: TextAlign.center,
)

// Mixed styles in one run
Text.rich(TextSpan(children: [
  const TextSpan(text: 'Total '),
  TextSpan(
    text: 'R 11 500.00',
    style: Theme.of(context).textTheme.titleLarge,
  ),
]))

// ICONS
Icon(Icons.inventory_2_outlined, size: 32, color: Colors.teal)

// IMAGES
Image.asset('assets/logo.png', height: 40)

Image.network(
  'https://example.com/product.jpg',
  fit: BoxFit.cover,
  loadingBuilder: (ctx, child, progress) =>
      progress == null ? child : const CircularProgressIndicator(),
  errorBuilder: (ctx, error, stack) => const Icon(Icons.broken_image),
)
```

- **`Text` is the most used widget in Flutter.** Style from
  `Theme.of(context).textTheme`, **never a raw `fontSize`**.
- **`maxLines` and `overflow: ellipsis` will not work without a bounded width.**
  If text still overflows today, that is a layout problem and it is tomorrow's
  first topic.
- **Icons are a font**, which surprises people. Sized and coloured like text.
- **`Image.asset` needs a `pubspec` entry** under `flutter: assets:` with exactly
  two spaces of indentation, **and a hot RESTART afterwards**. Assets are bundled
  at build time and are not hot-reloaded.
- **`Image.network` should always have an `errorBuilder`.** A broken URL with no
  error builder throws a red screen at the user. One line, production-quality
  habit.

## `Container`, and when not to use it

```dart
Container(
  width: 200,
  height: 120,
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.symmetric(horizontal: 24),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.primaryContainer,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.black12),
  ),
  child: const Text('R 11 500.00'),
)
```

**Four things to remember, and all four are real bugs:**

1. **`width` and `height` are preferences.** The parent's constraints win. A
   Container will not always be the size you asked for, and that is not a bug.
2. **`color` and `decoration` together throws.** Put the colour inside
   `BoxDecoration`. Everyone hits this once.
3. **`margin` is outside the decoration, `padding` is inside.**
4. **Setting `alignment` makes Container expand to fill** its parent — which
   catches people when a small card suddenly takes the whole screen.

**Prefer the specific widget** when you only need one thing:

```dart
const Padding(padding: EdgeInsets.all(16), child: Text('x'))
const SizedBox(height: 12)
const Align(alignment: Alignment.centerRight, child: Text('x'))
const Card(child: ListTile(title: Text('ORD-1042')))
```

They say what they mean, they are cheaper, and the analyser nags you towards
`SizedBox` anyway.

> **`Card` + `ListTile` gives you a professional-looking row for almost no code**,
> and it is the single fastest way to make a screen look finished.

## Buttons

```dart
FilledButton(onPressed: _submit, child: const Text('Submit order'))

FilledButton.icon(
  onPressed: _submit,
  icon: const Icon(Icons.check),
  label: const Text('Submit order'),
)

OutlinedButton(onPressed: _reset, child: const Text('Reset'))
TextButton(onPressed: _showTerms, child: const Text('Terms'))

IconButton(
  icon: const Icon(Icons.delete),
  tooltip: 'Delete line',        // always set this
  onPressed: _delete,
)

FloatingActionButton(onPressed: _newOrder, child: const Icon(Icons.add))

// DISABLING ANY BUTTON: pass null as onPressed.
FilledButton(
  onPressed: _canSubmit ? _submit : null,
  child: const Text('Submit order'),
)
```

**Pick by emphasis, not by looks:**

- `FilledButton` — the primary action. **One per screen.** If everything is
  emphasised, nothing is.
- `OutlinedButton` — secondary
- `TextButton` — low emphasis, dialog actions, links
- `IconButton` — icon-only
- `FloatingActionButton` — one screen-level action

**`ElevatedButton` still exists** and appears in every older tutorial. In Material
3 the current choice is `FilledButton`.

> **`onPressed: null` disables any button** and greys it out automatically. That
> is the Flutter idiom, and it is much better than hiding the button — a
> disappearing button is confusing, an obviously disabled one is not.

## SnackBars, dialogs and bottom sheets

```dart
// SNACKBAR. Needs a Scaffold somewhere above it.
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Order submitted'),
    behavior: SnackBarBehavior.floating,
  ),
);

// DIALOG. Returns whatever Navigator.pop sends back.
final confirmed = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Discard this order?'),
    content: const Text('Everything you have entered will be lost.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx, false),
        child: const Text('Keep editing'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(ctx, true),
        child: const Text('Discard'),
      ),
    ],
  ),
);

if (!context.mounted) return;      // after EVERY await
if (confirmed == true) _clear();

// BOTTOM SHEET. Same shape.
showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (ctx) => const Text('Line options'),
);
```

- **`showDialog` returns whatever `Navigator.pop` sends back**, typed by the
  generic parameter. The dialog's result comes back as an awaited value rather
  than through a callback.
- **The `ctx` versus `context` trap:** inside the builder you get a **new**
  context, and you must pop with **that** one. Popping with the outer context
  closes the wrong route, and the symptom is bizarre.
- **`mounted` again** — after awaiting a dialog, the user may have navigated away.
  The lint is `use_build_context_synchronously`.

> **Never show a dialog from `build()`.** It is a side effect and `build` may run
> sixty times a second. The symptom is an infinite stack of dialogs, and it is
> genuinely alarming the first time.

## Loading and empty states

```dart
const CircularProgressIndicator()
const LinearProgressIndicator()
const CircularProgressIndicator(value: 0.4)      // determinate

// Showing one instead of content, driven by state
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  return OrderList(orders: _orders);
}

// Inside a button while it works
FilledButton.icon(
  onPressed: _isLoading ? null : _submit,
  icon: _isLoading
      ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Icon(Icons.check),
  label: Text(_isLoading ? 'Submitting...' : 'Submit order'),
)

// An empty state is a real state. Always handle it.
if (_orders.isEmpty) {
  return const Center(child: Text('No orders yet'));
}
```

**The syntax is trivial. The professional point is not.** In most applications at
least one screen shows nothing at all while loading, and at least one shows a
blank area when a list is empty. Both look broken to a user and neither is caught
by a test.

**The in-button spinner** is worth having in your pocket: disable the button,
swap the icon for a small spinner, change the label. It prevents double submits
and tells the user something is happening. Three lines.

> **The payoff is on Day 7.** The sealed `OrderState` from Day 3 has an explicit
> loading case and an explicit failure case. When you wire this up properly, the
> compiler will not let you forget either one. Four days ago you modelled exactly
> these states in DartPad, and you were right to.

---

## LAB 5.2 · The order summary screen · 40 min

**Goal** — a real screen showing a real order: header, a card per line, a
subtotal, a working submit button with a confirmation dialog, and a proper empty
state.

1. In `_OrderScreenState`, create a `const Order` with three `OrderLine`s from
   your Day 3 model.
2. Replace the body with a `Column` showing the order id and customer, styled
   from the theme.
3. For each line, a `Card` containing a `ListTile`: the description as the title,
   sku and quantity as the subtitle, the line total as the trailing text.
4. A `Divider`, then a row with the word Subtotal and `order.subtotal.rands`.
5. An `IconButton` in the AppBar actions showing a `SnackBar` with the item count.
6. A `FilledButton` at the bottom that shows a confirmation `AlertDialog`, then a
   `SnackBar` with the result.
7. **Disable the submit button when the order has no lines**, by passing `null`.
8. **Handle the empty case:** show an icon and the words *No lines yet*.
9. **Test the empty case** by temporarily emptying the lines list, then put it back.

> **Steps 7–9 are the professional habits.** The empty state and the disabled
> button are what separate a demo from an application.

**The collection-for from Day 2 arrives here.** Building one `Card` per line
inside a `Column` with a `for` loop is exactly what you learned, now in its
natural home.

### Common errors

- Forgetting the `mounted` check after the dialog await — the analyser flags it.
- Popping with the outer context.
- Text overflowing — that is a layout problem and belongs to tomorrow. Shorten
  the string for today.
- Nesting Cards inside Cards by accident.

> **If you ask why the list is not scrolling:** a `Column` does not scroll. That
> is tomorrow.

### Stretch

- Add a trailing `IconButton` to each line that shows a `SnackBar` naming the sku.
- Show the item count as a badge in the AppBar instead of behind a button.
- Add the discount band from Day 3 under the subtotal, using your guarded switch.

---

# Module 4 · Composition, `const` and keys

**15:00 – 16:00**

By the end of this module you can:

- Break a long build method into named widgets
- Explain why a widget class beats a helper method
- Use `const` deliberately, and know why it matters here
- Say when a key is needed and what to put in it

## Extract Widget — the most useful habit in Flutter

```dart
// BEFORE: one build method doing everything
Widget build(BuildContext context) {
  return Column(
    children: [
      Container(/* forty lines of header */),
      Container(/* thirty lines of totals */),
      Row(/* twenty lines of buttons */),
    ],
  );
}

// AFTER: three widgets, each with one job
Widget build(BuildContext context) {
  return Column(
    children: const [
      OrderHeader(orderId: 'ORD-1042', customer: 'Acme Ltd'),
      TotalsCard(subtotal: 11650, vat: 1660.13),
      OrderActions(),
    ],
  );
}
```

**The mechanic:** cursor on a subtree, `Ctrl+.` (`Cmd+.` on a Mac), **Extract
Widget**, give it a name. The editor writes the class, moves the code, and passes
the parameters. Five seconds.

### Prefer a class over a helper method

```dart
Widget _buildHeader() { ... }     // works, but:
//   rebuilds whenever the parent rebuilds
//   cannot be const
//   gets no element of its own
//   cannot be tested in isolation

class OrderHeader extends StatelessWidget { ... }
//   gets its own element
//   can be const
//   can skip its own rebuild
//   is testable on its own
```

> **Helper methods that return widgets are the one Flutter habit worth actively
> unlearning.** They are everywhere in tutorials and they are a quiet performance
> tax.

**The readability argument is the one that wins people over.** A build method
that reads as five named widgets tells you what the screen is. A build method of
a hundred and twenty lines tells you nothing.

**Where to put them:** a small private widget in the same file is idiomatic —
Day 2 file privacy again. Anything reused across screens goes into its own file.

## `const`, and why it matters here

```dart
const Text('No orders yet')                  // created once, ever
Text('No orders yet')                        // created every rebuild

// It works down a whole subtree, as long as everything is const
const Column(
  children: [
    Icon(Icons.inventory_2_outlined, size: 48),
    SizedBox(height: 12),
    Text('No orders yet'),
  ],
)

// You cannot make it const if any value is computed at runtime
Text(order.id)                               // not const, correctly
```

**A `const` widget is created once, at compile time, and reused.** When Flutter
rebuilds and finds the identical instance, **it skips that subtree entirely** —
no rebuild, no layout, no paint.

Remember Day 1: two `const` lists with the same contents are literally the same
object. You ran `identical()` and saw `true`. **This is that fact, doing real
work.**

> **In Flutter, `const` is not a style preference. It is a performance mechanism,
> and it is the cheapest one available, because the compiler does the work.**

Apply them all at once:

```bash
dart fix --dry-run
dart fix --apply
```

**The habit to form:** type `const` first and let the compiler correct you. It is
faster than deciding.

## Keys

```dart
ListView(
  children: [
    for (final line in order.lines)
      LineTile(key: ValueKey(line.sku), line: line),
  ],
)

// USE ValueKey with something that identifies the ITEM
ValueKey(line.sku)
ObjectKey(line)

// NEVER USE THE INDEX.
// ValueKey(i)     <-- wrong, and a very common bug
```

**The mechanism, and this is the morning's three trees paying off:** when
rebuilding, Flutter matches new widgets to existing elements by **type and
position**.

**Now the problem.** Remove the first item from a list of ten. Every remaining
widget moves up one position. Flutter matches by position, so the element that
held item two's state now hosts item one's widget. **If those widgets have state,
the state stays behind** — you tick a checkbox, delete a row above it, and a
different row is now ticked. It looks like witchcraft when you first meet it.

**The fix:** a key that identifies the **item** rather than the position.

> **Never use the index.** The index *is* the position, and the position is
> exactly what changed. `ValueKey(i)` looks like it is doing something and does
> nothing at all.

**When you do not need a key:** the list never reorders, the children have no
state, or the children are different types. Most static lists need no keys and
adding them everywhere is noise.

**`GlobalKey` is a different animal.** It identifies a widget across the whole app
and lets you reach its state from outside. You will use exactly one all week, on
a `Form` on Day 7.

## `BuildContext`

```dart
Widget build(BuildContext context) {
  // Looking UP the tree for the nearest ancestor of a type
  final theme = Theme.of(context);
  final media = MediaQuery.of(context);
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  return Text('x', style: theme.textTheme.bodyLarge);
}
```

**What it is:** a reference to this widget's **element** — its position in the
tree. **Not** a service locator, not the widget itself, not a container of
dependencies.

**What the `of()` methods do:** walk **up** the tree from that position, looking
for the nearest ancestor of a particular type.

**The consequence that matters:** if the thing you are looking for is **below**
your context, the lookup fails.

```dart
// THE CLASSIC ERROR: Scaffold is created INSIDE this build method,
// so `context` here is above it, and ScaffoldMessenger.of(context) fails.
//
// THE FIX: use a Builder, or split the widget in two.
Scaffold(
  body: Builder(
    builder: (innerContext) => FilledButton(
      onPressed: () => ScaffoldMessenger.of(innerContext)
          .showSnackBar(const SnackBar(content: Text('hello'))),
      child: const Text('Show'),
    ),
  ),
)
```

Splitting the widget in two is usually cleaner — **another argument for
extracting widgets**.

And for the fourth time today: after an `await`, the widget may be gone.
`if (!context.mounted) return;`

---

## LAB 5.3 · Break it into widgets · 30 min

**Goal** — the same screen, refactored into four named widgets, with keys on the
list items and `const` applied everywhere the compiler allows.

1. Extract the id and customer block into `OrderHeader`, taking the order.
2. Extract the line `Card` into `LineTile`, taking a single `OrderLine`.
3. Extract the subtotal row into `TotalsRow`, taking the order.
4. Extract the empty state into `EmptyState`, taking a message `String`.
5. Put a `ValueKey` on each `LineTile`, keyed by the sku.
6. Run `dart fix --dry-run` and read what it suggests. Then `dart fix --apply`.
7. **Count the `const` keywords in your file and compare with your neighbour.**
8. Run the app and confirm it looks and behaves **exactly** as before. *A refactor
   that changes behaviour is not a refactor.*

**Use the editor refactor** rather than cutting and pasting.

### Common errors

- Forgetting `super.key` on an extracted widget — the editor usually adds it.
- Passing the whole order to a widget that only needs one line. It works; keep
  parameters narrow.
- Leaving a widget stateful when it no longer needs to be.

### Stretch

- Move `LineTile` into its own file under `presentation` and fix the imports.
- Make `EmptyState` take an optional action button.
- **Replace a `LineTile` key with `ValueKey` of the index, then reorder the list,
  and explain what you see.** This is the best demonstration of keys available in
  thirty seconds.

---

# Day 5 recap

- **You describe the screen for the current state. You never update it.
  `UI = f(state)`.**
- Everything is a widget: padding, alignment, the theme, a gesture. One
  composition mechanism to learn.
- You build the widget tree; **Flutter maintains the element and render trees**
  and updates only what differs.
- **Creating widgets is cheap.** Do not cache them, do not avoid rebuilding, do
  not hold references.
- **`build()` must be fast and pure.** No network, no dialogs, no side effects.
- **`StatelessWidget` is the default.** `StatefulWidget` is two classes because
  the `State` must outlive the widget.
- **`setState` marks the element dirty.** Change the field inside the callback,
  and **check `mounted` after every `await`**.
- **Extract widgets rather than writing helper methods.** Use `const` everywhere
  the compiler allows.
- **Keys identify items when siblings move.** Key by identity, never by index.

**Tomorrow (Day 6 · Layout):** constraints go down, sizes go up, the parent sets
position. Row, Column, Expanded and Flexible. The four layout errors and how to
read them. Stack, responsive layouts, scrolling lists and grids.

---

## Homework tonight · 20 min

**Read ["Understanding constraints"](https://docs.flutter.dev/ui/layout/constraints)
once, slowly.** Run at least the first four numbered examples yourself.

1. State the rule in one sentence, in your own words.
2. A `Container` with no child and no size: what does it do inside a `Center`, and
   what does it do inside a `Column`? Why are the answers different?
3. What does "unbounded" mean, and name two widgets that give their children
   unbounded constraints.
4. Find the example that surprised you most and be ready to run it.

> Tomorrow morning somebody will get an error saying *a RenderFlex overflowed by
> forty-two pixels*. Everybody does. The people who read this tonight will fix it
> in ten seconds. The people who did not will spend twenty minutes finding an
> answer that says "wrap it in Expanded" without saying why.

---

# Appendix A · Lab 5.1

### Starter

```dart
// LAB 5.1 - in your project, not DartPad

// 1. Create lib/features/orders/domain/order_model.dart and paste
//    your Day 3 code into it: Order, OrderLine, OrderStatus,
//    the sealed OrderState, and the Money extension.
//    Delete any main() function from it.

// 2. lib/main.dart
import 'package:flutter/material.dart';
import 'package:order_flow/app.dart';

void main() => runApp(const OrderFlowApp());

// 3. lib/app.dart
//    TODO: a StatelessWidget OrderFlowApp returning MaterialApp
//    with a title, a theme using colorSchemeSeed, and
//    home: const OrderScreen()

// 4. lib/features/orders/presentation/order_screen.dart
//    TODO: a StatefulWidget OrderScreen with
//      an int _quantity field starting at 10
//      a Scaffold with an AppBar titled 'OrderFlow'
//      a body with a Text showing the quantity
//      two IconButtons, add and remove, changing it with setState
//      a Text showing quantity times 250, formatted with .rands

// 5. TODO: add a FloatingActionButton that resets the quantity
//    to 10 and shows a SnackBar saying 'Reset'
```

### Solution

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:order_flow/features/orders/presentation/order_screen.dart';

class OrderFlowApp extends StatelessWidget {
  const OrderFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrderFlow',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2A9D8F),
        useMaterial3: true,
      ),
      home: const OrderScreen(),
    );
  }
}
```

```dart
// lib/features/orders/presentation/order_screen.dart
import 'package:flutter/material.dart';
import 'package:order_flow/features/orders/domain/order_model.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  static const _unitPrice = 250.0;
  int _quantity = 10;

  void _change(int by) {
    setState(() {
      _quantity = (_quantity + by).clamp(0, 999);
    });
  }

  void _reset() {
    setState(() => _quantity = 10);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reset')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('OrderFlow')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quantity', style: text.labelLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: 'Fewer',
                  onPressed: () => _change(-1),
                ),
                Text('$_quantity', style: text.displaySmall),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'More',
                  onPressed: () => _change(1),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Line total', style: text.labelLarge),
            Text(
              (_quantity * _unitPrice).rands,
              style: text.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _reset,
        tooltip: 'Reset',
        child: const Icon(Icons.restart_alt),
      ),
    );
  }
}
```

---

# Appendix B · Lab 5.2

### Starter

```dart
// LAB 5.2 - build a real order summary screen

// TODO 1: at the top of _OrderScreenState, create a const Order
//         using your Day 3 model, with three OrderLines
// TODO 2: replace the body with a Column showing
//           the order id and customer, styled from the theme
//           a Card for each line: sku, description, x quantity,
//             and the line total using .rands
//           a divider
//           the subtotal, in a larger style
// TODO 3: add an IconButton in the AppBar actions that shows a
//         SnackBar with the item count
// TODO 4: add a FilledButton at the bottom saying 'Submit order'
//         that shows an AlertDialog asking for confirmation,
//         and a SnackBar with the result
// TODO 5: disable the Submit button when the order has no lines,
//         by passing null to onPressed
// TODO 6: handle the empty case: if the order has no lines, show
//         an icon and the words 'No lines yet' instead of the list
```

### Solution

```dart
class _OrderScreenState extends State<OrderScreen> {
  static const _order = Order(
    id: 'ORD-1042',
    customer: 'Acme Ltd',
    lines: [
      OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
      OrderLine(sku: 'SKU-2', description: 'Gasket', quantity: 10, unitPrice: 120),
      OrderLine(sku: 'SKU-3', description: 'Bracket', quantity: 5, unitPrice: 90),
    ],
  );

  Future<void> _submit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit this order?'),
        content: Text('${_order.itemCount} items, ${_order.subtotal.rands}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(confirmed == true ? 'Order submitted' : 'Cancelled'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OrderFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Item count',
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${_order.itemCount} items')),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_order.id, style: text.titleLarge),
            Text(_order.customer, style: text.bodyMedium),
            const SizedBox(height: 16),
            if (_order.lines.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48),
                      SizedBox(height: 12),
                      Text('No lines yet'),
                    ],
                  ),
                ),
              )
            else
              for (final line in _order.lines)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2_outlined),
                    title: Text(line.description),
                    subtitle: Text('${line.sku}  x${line.quantity}'),
                    trailing: Text(
                      line.lineTotal.rands,
                      style: text.titleMedium,
                    ),
                  ),
                ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: text.titleMedium),
                Text(
                  _order.subtotal.rands,
                  style: text.headlineSmall?.copyWith(color: colors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _order.lines.isEmpty ? null : _submit,
              icon: const Icon(Icons.check),
              label: const Text('Submit order'),
            ),
          ],
        ),
      ),
    );
  }
}
```

> Note the `mounted` check after the dialog await, and `onPressed: null` to
> disable the button.

---

# Appendix C · Lab 5.3

### Starter

```dart
// LAB 5.3 - break the screen into widgets

// TODO 1: extract the order id and customer block into a
//         StatelessWidget called OrderHeader, taking the order
// TODO 2: extract the Card for one line into a StatelessWidget
//         called LineTile, taking a single OrderLine
// TODO 3: extract the subtotal row into TotalsRow, taking the order
// TODO 4: extract the empty state into EmptyState, taking a
//         message String. Make it const where you can
// TODO 5: put a ValueKey on each LineTile using the sku
// TODO 6: run dart fix --dry-run, read what it suggests, then
//         run dart fix --apply
// TODO 7: count how many const keywords ended up in your file
// TODO 8: confirm the screen still looks and behaves exactly
//         as it did before
```

### Solution

```dart
class OrderHeader extends StatelessWidget {
  const OrderHeader({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(order.id, style: text.titleLarge),
        Text(order.customer, style: text.bodyMedium),
      ],
    );
  }
}

class LineTile extends StatelessWidget {
  const LineTile({super.key, required this.line});
  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(line.description),
        subtitle: Text('${line.sku}  x${line.quantity}'),
        trailing: Text(
          line.lineTotal.rands,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class TotalsRow extends StatelessWidget {
  const TotalsRow({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Subtotal', style: text.titleMedium),
        Text(
          order.subtotal.rands,
          style: text.headlineSmall?.copyWith(color: colors.primary),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
```

**The build method becomes readable at a glance — that is the goal:**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    OrderHeader(order: _order),
    const SizedBox(height: 16),
    if (_order.lines.isEmpty)
      const Expanded(child: EmptyState(message: 'No lines yet'))
    else
      for (final line in _order.lines)
        LineTile(key: ValueKey(line.sku), line: line),
    const Divider(height: 32),
    TotalsRow(order: _order),
    const SizedBox(height: 16),
    FilledButton.icon(...),
  ],
)
```

---

# Appendix D · Hot reload keys and widget quick reference

### Hot reload keys — in the `flutter run` terminal

| Key | Does |
|---|---|
| `r` | hot reload — load changed code, **keep** what is on screen |
| `R` | hot restart — start over, **lose** what is on screen |
| `p` | show layout guides |
| `o` | switch between Android and iPhone appearance |
| `v` | open DevTools in a browser |
| `q` | quit |

**Needs a hot RESTART, not a reload:** changes to `main()` or anything outside a
class; changes to an enum or a class hierarchy; a new asset or any edit to
`pubspec.yaml`; changes to `initState` if you want them to run again.

> If nothing changes at all, **look at the terminal, not the phone.** There is
> almost certainly a compile error.

### Widget quick reference

| You want | Use | Note |
|---|---|---|
| A page | `Scaffold` | App bar, body, FAB, bottom bar, drawer |
| A title bar | `AppBar` | `actions` takes a list of IconButtons |
| Words | `Text` | Style from `Theme.of(context).textTheme` |
| Mixed styles in a line | `Text.rich` + `TextSpan` | |
| A symbol | `Icon` | Icons are a font. Thousands available |
| A picture | `Image.asset` / `Image.network` | Declare assets in pubspec, then hot **restart** |
| Space around something | `Padding` | Not a `Container` |
| A fixed gap | `SizedBox(height: 12)` | The idiom for spacing |
| A box with a background | `Container` or `Card` | `Card` for anything list-like |
| A list row | `ListTile` inside a `Card` | leading, title, subtitle, trailing, onTap |
| The main action | `FilledButton` | One per screen |
| A secondary action | `OutlinedButton` | |
| A quiet action | `TextButton` | Dialog actions, links |
| An icon action | `IconButton` | Always set `tooltip` |
| To disable a button | `onPressed: null` | Greys out automatically |
| A brief message | `ScaffoldMessenger` + `SnackBar` | Needs a `Scaffold` above |
| A question | `showDialog` + `AlertDialog` | Returns the popped value |
| A spinner | `CircularProgressIndicator` | Pass `value` for determinate |
| Centre one thing | `Center` | |
| Stack things vertically | `Column` | **Does not scroll.** Day 6 |

---

# Appendix E · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Tapping the button changes nothing | Field changed outside `setState` | Wrap the change in `setState` |
| `setState() called after dispose()` | `setState` after an await, screen gone | `if (!mounted) return;` before `setState` |
| `No ScaffoldMessenger widget found` | Context is **above** the Scaffold | Use a `Builder`, or extract an inner widget |
| Dialogs appear endlessly | `showDialog` called from `build` | Trigger it from a callback, never from `build` |
| Network call fires repeatedly | Called from `build` | Move it to `initState` |
| `A RenderFlex overflowed by ... pixels` | Content too big for the space | Layout. **Day 6.** Shorten the text for now |
| Hot reload changes nothing | Changed `main`, or a compile error | Press `R`. Read the terminal, not the phone |
| `Unable to load asset` | pubspec indentation, or no restart | Two spaces under `flutter:`, then hot **restart** |
| `Cannot provide both a color and a decoration` | `Container` with both | Put the colour inside `BoxDecoration` |
| A ticked checkbox moves to the wrong row | No keys, or keyed by index | `ValueKey(item.id)` |
| `The instance member ... cannot be accessed in an initializer` | Using `widget.x` in a field initialiser | Move it into `initState` |
| `setState` callback marked `async` | Async work inside `setState` | Await first, then `setState` with the result |
| State resets on every keystroke | State held in the widget, not the `State` class | Mutable fields belong in the `State` |

---

# Appendix F · Links

| Topic | Link |
|---|---|
| Introduction to widgets | https://docs.flutter.dev/ui/widgets-intro |
| The widget catalogue | https://docs.flutter.dev/ui/widgets |
| Widget index, A to Z | https://docs.flutter.dev/reference/widgets |
| StatefulWidget lifecycle | https://api.flutter.dev/flutter/widgets/State-class.html |
| `setState` | https://api.flutter.dev/flutter/widgets/State/setState.html |
| Keys | https://api.flutter.dev/flutter/foundation/Key-class.html |
| BuildContext | https://api.flutter.dev/flutter/widgets/BuildContext-class.html |
| Material 3 components | https://m3.material.io/components |
| Hot reload | https://docs.flutter.dev/tools/hot-reload |
| **Homework** | https://docs.flutter.dev/ui/layout/constraints |
