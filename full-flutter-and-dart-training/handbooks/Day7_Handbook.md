# Day 7 · Forms, Navigation and State — Delegate Handbook

**Flutter for Java Developers · 8-Day Programme · Day 7 of 8**

Validated forms · More than one screen · When `setState` runs out · Theming

> **Until today you have been building a display.** Today it becomes an
> application: it takes input, it validates it, it has more than one screen, and
> the screens share data with each other.
>
> **For a Spring room the afternoon is the easy part.** A `ChangeNotifier` is a
> service, a `Provider` is the container, and `context.watch` is autowiring with
> an observer.

---

## Today's agenda

| | Time | Block |
|---|---|---|
| 1 | 09:00 – 10:30 | **Forms** — `Form`, `GlobalKey` and `validate`, `TextFormField` and controllers, input formatters, custom `FormField`s |
| 2 | 10:45 – 12:30 | **Navigation** — the Navigator is a stack, passing data forward and back, named routes, **Lab 7.1** |
| 3 | 13:15 – 14:45 | **State management** — where `setState` runs out, lifting state, `ChangeNotifier` and `provider`, **Lab 7.2** |
| 4 | 15:00 – 16:00 | **Theming** — one seed colour, colour roles, dark mode, runtime switching, **Lab 7.3** |

---

# Module 1 · Forms

**09:15 – 10:30**

By the end of this module you can:

- Build a `Form` with a `GlobalKey` and validate it
- Use `TextFormField` with controllers, keyboard types and formatters
- Write validators that return a message or `null`
- Wrap any widget in a `FormField` so it validates with the rest

> This is the same shape as any validation framework you have used: a group, a
> set of per-field rules, and a single call that runs them all and reports.

## `Form`, `GlobalKey`, `validate`

```dart
class CaptureForm extends StatefulWidget {
  const CaptureForm({super.key, required this.onSubmit});
  final void Function(OrderLine) onSubmit;

  @override
  State<CaptureForm> createState() => _CaptureFormState();
}

class _CaptureFormState extends State<CaptureForm> {
  // The handle on the form. This is the one GlobalKey you will
  // use all week.
  final _formKey = GlobalKey<FormState>();

  // One controller per text field. Created here, disposed below.
  final _skuCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  @override
  void dispose() {
    _skuCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    // validate() runs every validator and shows every error.
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(OrderLine(
      sku: _skuCtrl.text.trim(),
      description: 'Added by hand',
      quantity: int.parse(_qtyCtrl.text),
      unitPrice: 250,
    ));
  }

  @override
  Widget build(BuildContext context) =>
      Form(key: _formKey, child: _fields(context));
}
```

- **`GlobalKey<FormState>` is the one global key you will use.** On Day 5, keys
  identified list items. This one is different: **it gives you access to a
  widget's state from outside that widget.**
- **A form must be stateful** — it owns controllers, and controllers must be
  created once and disposed.
- **`validate()` runs every validator, shows every error message, and returns a
  single bool.** One call.
- **The `!` on `currentState` is justified**, and every bang needs a reason: the
  key is attached to a `Form` in this same build method, so it cannot be null
  when a button inside that form is tapped.
- **The callback out** — the form does not know what happens to the line it
  produces. That keeps it reusable and testable. This afternoon that callback
  becomes a call into a model and **nothing inside the form changes**.

> **Write `dispose` before you write the fields** and you will never forget it.

## Fields, keyboards and formatters

```dart
Widget _fields(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _skuCtrl,
          decoration: const InputDecoration(
            labelText: 'SKU',
            hintText: 'SKU-1042',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'SKU is required';
            }
            if (!value.trim().isValidSku) {
              return 'Use the form SKU-1234';
            }
            return null;                 // null means valid
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _qtyCtrl,
          decoration: const InputDecoration(
            labelText: 'Quantity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          validator: (value) {
            final n = int.tryParse(value ?? '');
            if (n == null) return 'Enter a whole number';
            if (n < 1) return 'Quantity must be at least 1';
            if (n > 999) return 'Maximum 999 per line';
            return null;
          },
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add),
          label: const Text('Add line'),
        ),
      ],
    );
```

> **`inputFormatters` live in `services.dart`, not `material.dart`:**
> ```dart
> import 'package:flutter/services.dart';
> ```
> Missing it gives *"Undefined name FilteringTextInputFormatter"*, and it **will**
> happen in the lab.

- **`decoration` is the look** — label, hint, border. `InputDecoration` is where
  almost all field styling lives, and you can set it once in the theme.
- **`keyboardType` changes the keyboard the user gets.** A number field showing a
  full qwerty keyboard is a small daily insult to your users, and it costs one
  line to fix.
- **`inputFormatters` stop bad input before it is typed.** Much better than
  validating afterwards and telling somebody off.
- **`textInputAction: TextInputAction.next`** puts a Next arrow on the keyboard
  instead of a return key. Small, professional, one line.
- **The validator contract:** return `null` when valid, return a `String` when
  not. **The String is the message the user sees** — write it as a sentence a
  person can act on. *"Use the form SKU-1234"* beats *"Invalid format"*.

> Notice the validator uses `isValidSku`, your extension from Day 3, unchanged.
> Four days of work is now paying rent.

## The rules that matter

```dart
// THE FORM API, in five lines
//
//   Form                 groups the fields
//   GlobalKey<FormState> your handle on the group
//   validate()           runs every validator, shows errors,
//                        returns true if all passed
//   save()               calls every onSaved
//   reset()              clears values and errors

// AUTOVALIDATION: when do errors appear?
Form(
  key: _formKey,
  // disabled           only when you call validate(). The default.
  // always             on every rebuild, so errors show before typing
  // onUserInteraction  after the user has touched the field
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: fields,
)
```

**`autovalidateMode` is a user experience decision, not a technical one:**

| Mode | Effect |
|---|---|
| `disabled` (default) | Nothing until you submit — the user fills in six fields and then gets told off six times |
| `always` | Errors show before the user has typed anything — hostile |
| `onUserInteraction` | An error once the user has touched that field — **almost always right** |

### The three traps

1. **Every controller must be disposed.** Create in the State, dispose in
   `dispose`. The same pair as every other resource.
2. **Create controllers in the State, never in `build()`.** A controller created
   in `build` is thrown away every frame, and you get *"A TextEditingController
   was used after being disposed"* — or the field clears itself.
3. **Choosing when errors appear**, above.

## Custom fields: anything can join the form

```dart
// Any widget can join the form. Wrap it in FormField<T>.
class UnitPriceField extends StatelessWidget {
  const UnitPriceField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<double>(
      initialValue: value,
      validator: (v) => v == null ? 'Choose a price band' : null,
      builder: (state) => InputDecorator(
        decoration: InputDecoration(
          labelText: 'Unit price',
          errorText: state.errorText,       // wire the error through
          border: const OutlineInputBorder(),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<double>(
            value: state.value,
            isExpanded: true,
            hint: const Text('Choose'),
            items: const [
              DropdownMenuItem(value: 90.0, child: Text('R 90.00')),
              DropdownMenuItem(value: 120.0, child: Text('R 120.00')),
              DropdownMenuItem(value: 250.0, child: Text('R 250.00')),
            ],
            onChanged: (v) {
              state.didChange(v);           // tell the FormField
              onChanged(v);                 // tell the parent
            },
          ),
        ),
      ),
    );
  }
}
```

**The problem:** a dropdown, a date picker or a slider is not a `TextFormField`,
so `validate()` knows nothing about it. Most people end up validating those
separately and by hand.

**The pattern, and it works for anything:**

1. Wrap it in `FormField<T>`
2. Call `state.didChange(value)` when it changes
3. Render it with `InputDecorator` so it matches the others
4. **Pass `state.errorText` into the decoration**

> **Step 4 is the one people miss**, and the symptom is a field that validates
> correctly and shows no error message.

**`state.didChange` versus the parent callback:** `didChange` tells the
`FormField`, the callback tells your own code. You usually need both.

---

# Module 2 · Navigation

**10:45 – 12:30**

By the end of this module you can:

- Push and pop screens, and understand the stack
- Pass data forward with constructor arguments
- Get data back from a screen with an awaited result
- Know when named routes are enough and when to use a router

## The Navigator is a stack

```dart
// GO TO A NEW SCREEN
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LineDetailScreen()),
);

// COME BACK
Navigator.pop(context);

// PASS DATA FORWARD: constructor arguments, like any widget.
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LineDetailScreen(line: line),
  ),
);

// GET DATA BACK: push returns a Future of whatever pop sends.
final result = await Navigator.push<OrderLine>(
  context,
  MaterialPageRoute(builder: (context) => const AddLineScreen()),
);
if (!context.mounted) return;      // after EVERY await
if (result != null) {
  setState(() => _lines.add(result));
}

// On the other screen:
Navigator.pop(context, newLine);   // the second argument is the result
```

- **Push, pop, last in first out.** The Android back button and the iOS swipe
  both call `pop` for you.
- **`MaterialPageRoute`** wraps your screen with the platform's page transition,
  for free.
- **Passing data forward is just constructor arguments.** No `Intent` extras, no
  bundle.
- **Getting data back is the part worth learning properly.** `push` returns a
  `Future`, and `pop`'s second argument completes it.
- **The type parameter matters:** `push<OrderLine>` gives you a **nullable**
  `OrderLine` back — nullable because the user may press back instead of
  submitting. The compiler makes you handle that, which is exactly right.

> **Compared with Android:** this replaces `startActivityForResult` and
> `onActivityResult` — one `await` instead of two methods and a request code.

## Named routes, and when to reach for a router

```dart
// NAMED ROUTES: declare the map once, navigate by name.
MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const OrderScreen(),
    '/add': (context) => const AddLineScreen(),
    '/settings': (context) => const SettingsScreen(),
  },
)

Navigator.pushNamed(context, '/add');

// PASSING ARGUMENTS TO A NAMED ROUTE is clumsy.
Navigator.pushNamed(context, '/detail', arguments: line);
// ...and in the target screen:
final line = ModalRoute.of(context)!.settings.arguments as OrderLine;

// THE OTHER NAVIGATION METHODS
Navigator.pushReplacement(context, route);      // replace the current
Navigator.popUntil(context, (r) => r.isFirst);  // back to the root
Navigator.canPop(context);                      // is there anything below
```

**The problem is arguments.** The builder takes no parameters, so you pass
arguments separately and cast them back with `as`. **That is a runtime cast in a
language that has spent four days teaching you to avoid runtime casts.**

**When to reach for a router** — `go_router` is maintained by the Flutter team
and is the recommended choice. You want one when:

- you need deep links from outside the app
- you need a redirect guard such as *"must be signed in"*
- you want type-safe parameters
- the app has more than about six screens

We are not using it today because the concepts matter more than the package, and
the stack model is what everything is built on.

## Navigation patterns you will use

```dart
// A DETAIL SCREEN, taking an object
class LineDetailScreen extends StatelessWidget {
  const LineDetailScreen({super.key, required this.line});
  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(line.sku)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line.description,
                style: Theme.of(context).textTheme.titleLarge),
            Text('Quantity ${line.quantity}'),
            Text('Line total ${line.lineTotal.rands}'),
            const Spacer(),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

// CONFIRM BEFORE LEAVING, with unsaved changes
final leave = await showDialog<bool>(
  context: context,
  builder: (ctx) => AlertDialog(
    title: const Text('Discard this line?'),
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
if (!context.mounted) return;
if (leave == true) Navigator.pop(context);
```

**Passing whole objects versus passing an id:** passing the object is simpler and
correct for a detail view of something already loaded. Passing an id is better
when the detail screen must show fresher data, or when it can be reached from a
deep link.

> **The common bug is popping twice.** The dialog's own `pop` closes the dialog.
> The second `pop` closes the screen. If you use the wrong context, or pop once
> too often, you close both and the user lands somewhere unexpected.

---

## LAB 7.1 · A second screen with a form · 40 min

**Goal** — an `AddLineScreen` with a validated form that returns a new
`OrderLine` to the order screen through the Navigator result.

1. Create `AddLineScreen` as a `StatefulWidget` with a `Scaffold` titled *Add line*.
2. Add a `Form` with a `GlobalKey` and two `TextFormField`s, SKU and quantity.
   **Controllers in the State, disposed in `dispose`.**
3. SKU validator: required, and must match the SKU-1234 shape. **Reuse your
   `isValidSku` extension from Day 3.**
4. Quantity: digits only, maximum four characters, and a validator for 1–999.
5. An Add button that validates and pops with a new `OrderLine`.
6. On `OrderScreen`, make the FAB push `AddLineScreen` and **await** the result.
7. If the result is not null, add it with `setState` and show a `SnackBar`.
   **Remember the `mounted` check.**
8. Set `autovalidateMode` to `onUserInteraction` and describe the difference.

> **Build in this order:** get the screen pushing and popping with a hard-coded
> line **first**, then add the form. People who build the form first spend twenty
> minutes before they know whether navigation works.

### Common errors

- Missing `import 'package:flutter/services.dart';`
- Creating controllers in `build`.
- Forgetting the `mounted` check after the await.
- Popping with the wrong context inside a dialog.
- **Forgetting that the awaited result is nullable**, because the user can press
  back. The compiler forces you to handle a real user path you would otherwise
  have forgotten.

### Stretch

- Add a confirm dialog when the user presses back with text already typed.
- Add the price dropdown as a `FormField` so it validates with the rest.
- Make the Add button disabled until the form is valid, and decide whether you
  prefer that to showing errors.

> **The question that sets up the afternoon:** what if the app bar also needs the
> item count, and a settings screen needs it too? **The Navigator result only
> reaches the screen that pushed.**

---

# Module 3 · State management

**13:15 – 14:45**

By the end of this module you can:

- Explain what breaks when shared state lives in `setState`
- Describe how `InheritedWidget` shares data down the tree
- Use `ChangeNotifier` and `provider` to share state and inject services
- Know the landscape, and why consistency beats the choice

## Where `setState` runs out

**The wall everybody hits.** The order lives in `OrderScreen`'s State. Now:

- `AddLineScreen` needs to add to it
- `SettingsScreen` needs to know how many lines there are
- The app bar badge needs the item count

**`setState` can only rebuild its own subtree. It cannot reach another screen at
all.**

```dart
// FIRST FIX: LIFT THE STATE UP. Move it to a common ancestor
// and pass it down, along with callbacks to change it.
class _AppState extends State<App> {
  Order _order = const Order(id: 'ORD-1042', customer: 'Acme', lines: []);

  void _addLine(OrderLine line) {
    setState(() => _order = _order.copyWith(
      lines: [..._order.lines, line],
    ));
  }

  @override
  Widget build(BuildContext context) => OrderScreen(
        order: _order,
        onAddLine: _addLine,       // pass a value AND a callback
      );
}
```

**And that is where it goes wrong.** Three screens deep, every widget in between
must forward `order` and `onAddLine` even if it never uses them. **That is prop
drilling.**

**The second problem is performance**, and it is less obvious: `setState` at the
root rebuilds everything below, for a one-line change.

> **For the Spring people:** this is passing a dependency through five
> constructors because there is no container. You solved that with dependency
> injection years ago. **Same problem, same shape of answer.**

## `InheritedWidget`: the mechanism underneath

```dart
// You already use it every day:
//   Theme.of(context)
//   MediaQuery.of(context)
//   Navigator.of(context)
//   ScaffoldMessenger.of(context)

class OrderScope extends InheritedWidget {
  const OrderScope({
    super.key,
    required this.order,
    required super.child,
  });

  final Order order;

  // The lookup. O(1), regardless of tree depth.
  static Order of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<OrderScope>();
    return scope!.order;
  }

  // When this returns true, every widget that called of() rebuilds.
  @override
  bool updateShouldNotify(OrderScope old) => old.order != order;
}

// Provide it once, near the top:
OrderScope(order: _order, child: const OrderScreen())

// Read it anywhere below, with no parameters passed down:
final order = OrderScope.of(context);
```

**`dependOnInheritedWidgetOfExactType` walks up to the nearest ancestor of that
type.** Constant time regardless of depth, because the element keeps a map of the
inherited widgets above it.

**It also registers a dependency** — the widget that called `of()` is now
subscribed, and when `updateShouldNotify` returns true, it rebuilds. **That is how
changing the theme recolours the whole app.**

> **Now the gap:** how does a button three levels down **change** the order? It
> cannot. An `InheritedWidget` is read-only from below. There is no setter.

**What it does not give you:**

- a way to change the value from below
- any lifecycle
- dependency injection
- a way to test the logic without building a widget tree

**Every state management package fills exactly those four gaps.**

## `ChangeNotifier`: a service that announces changes

```dart
// lib/features/orders/state/order_model.dart
class OrderModel extends ChangeNotifier {
  Order _order = const Order(
    id: 'ORD-1042',
    customer: 'Acme Ltd',
    lines: [],
  );

  // Read-only from outside
  Order get order => _order;
  int get itemCount => _order.itemCount;
  double get subtotal => _order.subtotal;

  void addLine(OrderLine line) {
    _order = _order.copyWith(lines: [..._order.lines, line]);
    notifyListeners();          // forget this and nothing rebuilds
  }

  void removeLine(OrderLine line) {
    _order = _order.copyWith(
      lines: _order.lines.where((l) => l != line).toList(),
    );
    notifyListeners();
  }

  void submit() {
    _order = _order.copyWith(status: OrderStatus.submitted);
    notifyListeners();
  }
}
```

> **For the Spring people: this is a service.** It holds state, it exposes methods
> that change it, and it announces the change. What is missing is the container
> that hands it to whoever needs it.

- **It imports nothing from the UI.** No `material.dart`, no widgets, no
  `BuildContext`. That is the same domain rule from Day 1 — and it means this
  class can be **unit tested in milliseconds with no widget tree**.
- **`notifyListeners` is the one thing you can forget**, and forgetting it is a
  **silent** bug: the state changes and the screen does not move, with no error.
- **Immutable updates:** every method replaces the order with `copyWith` rather
  than mutating it. That is Day 2's `copyWith` doing real work.
- **Name methods for the business action** — `addLine`, `removeLine`, `submit`.
  Not `setOrder`. The method names are your domain vocabulary.

## `provider`: watch, read, select

```dart
// pubspec.yaml
//   dependencies:
//     provider: ^6.1.0
//
// flutter pub add provider

// 1. PROVIDE IT, once, above everything that needs it.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => OrderModel(),
      child: const OrderFlowApp(),
    ),
  );
}

// 2. READ IT AND REBUILD WHEN IT CHANGES
Widget build(BuildContext context) {
  final model = context.watch<OrderModel>();
  return Text('${model.itemCount} items');
}

// 3. READ IT ONCE, WITHOUT SUBSCRIBING. For callbacks.
onPressed: () => context.read<OrderModel>().addLine(line),

// 4. REBUILD ONLY WHEN ONE FIELD CHANGES
final count = context.select<OrderModel, int>((m) => m.itemCount);
```

> ## The rules
>
> - **`watch`** in `build()`. Subscribes, so the widget updates.
> - **`read`** in callbacks. **Never in `build`** — it does not subscribe and the
>   widget **silently** stops updating.
> - **`select`** in `build`, when you only care about one value.

**For the Spring people, precisely:**

| Provider | Spring |
|---|---|
| `ChangeNotifierProvider` | the bean definition |
| `context.watch<T>()` | `@Autowired` plus an observer |
| `context.read<T>()` | `@Autowired` with no observer |

**The failure mode to know:** if nothing above you provides the type, you get a
`ProviderNotFoundException` at **runtime**, not at compile time. It is a clear
message with a good explanation, and it is still a runtime failure — worth naming
honestly, since Dart has spent four days catching things at compile time.

## The screen after the refactor

```dart
// The screen no longer owns the order, and no longer takes
// it as a parameter. It asks for it.
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});          // takes nothing

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OrderModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text('${model.itemCount} items'),
      ),
      body: model.order.lines.isEmpty
          ? const EmptyState(message: 'No lines yet')
          : ListView.builder(
              itemCount: model.order.lines.length,
              itemBuilder: (context, i) {
                final line = model.order.lines[i];
                return LineTile(key: ValueKey(line.sku), line: line);
              },
            ),
      floatingActionButton: FloatingActionButton(
        // read, not watch, because this is a callback
        onPressed: () async {
          final line = await Navigator.push<OrderLine>(
            context,
            MaterialPageRoute(builder: (_) => const AddLineScreen()),
          );
          if (line != null && context.mounted) {
            context.read<OrderModel>().addLine(line);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

- **`OrderScreen` now takes no constructor parameters.** Nothing above it passes
  anything down.
- **`AddLineScreen` can now call `context.read<OrderModel>().addLine(line)`
  directly.** No callback threaded down through three widgets. The Navigator
  result still works and is still fine — it is simply no longer the only option.
- **`watch` in build and `read` in the callback, in the same widget.** That is the
  rule in practice.
- **The screen went from stateful to stateless**, because the state left it. Less
  code, fewer lifecycle concerns, easier to test.
- **The `mounted` check is still there.** Providers do not remove that requirement.

> **Connect to tomorrow:** this model is where the API call will go. **The screen
> will not change at all** when the data starts coming from a server, because the
> screen already only talks to the model.

## Providers are your DI container

```dart
// An interface, exactly as you would in Java
abstract class OrderService {
  Future<Order> submit(Order order);
}

class FakeOrderService implements OrderService {
  @override
  Future<Order> submit(Order order) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (order.lines.isEmpty) throw const EmptyOrderException();
    return order.copyWith(status: OrderStatus.submitted);
  }
}

// Register it
MultiProvider(
  providers: [
    Provider<OrderService>(create: (_) => FakeOrderService()),
    ChangeNotifierProvider(
      create: (context) => OrderModel(context.read<OrderService>()),
    ),
  ],
  child: const OrderFlowApp(),
)
```

**The pattern is exactly Spring.** An interface, an implementation, one
registration, and everything else asks for the interface. A provider can depend
on another with `context.read` inside its `create` — that is constructor
injection, with the dependency graph built for you.

**The payoff is one line.** Swapping `FakeOrderService` for a real HTTP
implementation changes exactly one line in `main`. No screen changes, no model
changes. **Tomorrow you do precisely that.**

**Why start with a fake at all:** it lets you build the entire UI against a
service that is fast, deterministic and offline. When the real API arrives, the
app is already finished.

## The landscape, honestly

| | |
|---|---|
| **`setState`** | Built in, no package, and **correct** for local widget state: a toggle, a text field, an expanded panel. It cannot reach another screen, and that is the only thing wrong with it. |
| **`provider`** | What we are using, and what the official documentation teaches. A tiny API. **Sharp edges:** a mutable model, a silent bug if you forget `notifyListeners`, and a runtime failure if you forget to provide something. |
| **`riverpod`** | By the same author, written to remove those sharp edges. No `BuildContext` needed, so logic is testable on its own, and a missing provider is impossible rather than a runtime error. More concepts to learn first. |
| **`bloc`** | Events in, states out. More ceremony, and structure the pattern **enforces** rather than suggests. Its observer gives you an event-level audit trail, which regulated domains often want. |

> **The advice: pick one and be consistent.** A codebase with three state
> management approaches is worse than a codebase with the wrong one used
> everywhere.
>
> All three packages are production grade. **The choice matters far less than the
> consistency, and far less than keeping your business logic out of your
> widgets.**

*Why Provider rather than Riverpod?* It is what the official documentation
teaches, it has the smallest API, and it maps exactly onto dependency injection.
Riverpod is an excellent next step and the concepts transfer almost completely.

---

## LAB 7.2 · Lift the order into a model · 40 min

**Goal** — the order lives in a `ChangeNotifier`, provided above the app. The
screen takes no parameters, and both screens change the same order.

1. `flutter pub add provider`
2. Create `OrderModel extends ChangeNotifier` with the order, getters, `addLine`,
   `removeLine` and `clear`. **Remember `notifyListeners` in every method that
   changes something.**
3. Wrap `runApp` in a `ChangeNotifierProvider` that creates it.
4. Make `OrderScreen` a `StatelessWidget` with **no constructor parameters**,
   reading the model with `context.watch`.
5. The app bar title shows the item count from the model.
6. The FAB adds the result with `context.read`, **not** `watch`.
7. The `Dismissible` calls `removeLine` through `context.read`.
8. Add a Clear action to the app bar.
9. **BREAK IT:** change one `context.watch` to `context.read`, see what stops
   working, then change it back.

> **Step 9 is not optional.** It is silent, it has no error, and it is the single
> most common Provider bug. Seeing it deliberately is worth an hour of confusion
> later.

### Common errors

- Forgetting `notifyListeners`, so nothing updates.
- Using `watch` in a callback.
- Providing the model **below** the widget that needs it — a
  `ProviderNotFoundException` with a long and genuinely helpful message.
- **Mutating the lines list in place** instead of using `copyWith`. This is
  subtle: `notifyListeners` still fires and the screen *does* update, so it looks
  fine. **It will bite you tomorrow when tests compare states.**

### Stretch

- Register a `FakeOrderService` with `Provider` and give `OrderModel` a `submit`
  method that calls it.
- Use `context.select` so the app bar only rebuilds when the item count changes.
- Make `AddLineScreen` call `context.read().addLine` directly instead of popping
  with a result, and decide which you prefer.

---

# Module 4 · Theming

**15:00 – 16:00**

By the end of this module you can:

- Generate a whole palette from one seed colour
- Read colours and text styles from the theme, never hard-coded
- Support dark mode with no extra design work
- Change the theme at runtime, which is just more state

## One seed colour, a whole palette

```dart
MaterialApp(
  theme: ThemeData(
    // ONE colour generates the whole palette
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2A9D8F),
    ),
    useMaterial3: true,

    // Component themes: set once, applied everywhere
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
      ),
    ),
    cardTheme: const CardThemeData(margin: EdgeInsets.zero),
  ),

  // Dark mode for free, from the same seed
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2A9D8F),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  ),

  themeMode: ThemeMode.system,     // follow the device
  home: const OrderScreen(),
)
```

**`ColorScheme.fromSeed` takes one colour and generates the full set** — primary,
onPrimary, primaryContainer, secondary, surface, error and the rest, **with
correct contrast between each pair**.

**The contrast guarantee is the underrated part.** `onPrimary` is always readable
on `primary`, by construction. Most hand-rolled palettes get that wrong somewhere.

**Dark mode is the same seed** with `brightness: Brightness.dark`. Two lines.

**Component themes set a rule once and apply it everywhere.** `filledButtonTheme`
making every filled button 48 high means no per-button sizing anywhere.

> **The enterprise angle:** this is how white-labelling works. One seed per
> client, no widget changes.

## Colour roles and text styles

```dart
// READ FROM THE THEME. Never hard-code a colour or a size.
final colors = Theme.of(context).colorScheme;
final text = Theme.of(context).textTheme;

Container(
  color: colors.primaryContainer,
  child: Text(
    'Subtotal',
    style: text.titleMedium?.copyWith(color: colors.onPrimaryContainer),
  ),
)
```

### The colour roles you will use

| Role | For |
|---|---|
| `primary` / `onPrimary` | the brand colour for key components, and what goes on it |
| `primaryContainer` / `onPrimaryContainer` | a softer standout fill: headers, chips, highlighted cards |
| `surface` / `onSurface` | page and card backgrounds, and ordinary text |
| `error` / `onError` | validation messages and destructive actions |
| `outline` | borders and dividers |

**The `on` prefix is the pattern:** whatever goes **on top of** a role uses the
matching `on` colour. That is the contrast guarantee, made usable.

### The text styles

| Family | For |
|---|---|
| `displayLarge` … `displaySmall` | big numbers, hero text |
| `headlineLarge` … `headlineSmall` | screen titles |
| `titleLarge` … `titleSmall` | card and section titles |
| `bodyLarge` … `bodySmall` | ordinary text |
| `labelLarge` … `labelSmall` | buttons, captions |

> ## The rule for this course
>
> **If you type `Colors.blue` or `fontSize: 18` inside a widget, you have broken
> theming.** Use a role and a named style.

The one acceptable exception is a deliberately translucent overlay such as
`Colors.white24` on a watermark, because it is not a brand colour.

**`copyWith` on a text style** is how you take a named style and change one thing.
Setting a whole style by hand is not the way.

## Changing the theme at runtime

```dart
class ThemeModel extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  Color _seed = const Color(0xFF2A9D8F);

  ThemeMode get mode => _mode;
  Color get seed => _seed;

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setSeed(Color seed) {
    _seed = seed;
    notifyListeners();
  }
}

class OrderFlowApp extends StatelessWidget {
  const OrderFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeModel>();
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: theme.seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: theme.mode,
      home: const OrderScreen(),
    );
  }
}
```

**This is not a new technique.** It is the afternoon's state management pattern
applied to the theme.

**Why it must be watched by the app:** `MaterialApp` is what holds the theme, so
`MaterialApp` is what must rebuild. Providing below it would not work.

> **Persisting the choice is tomorrow.** Right now the theme resets when the app
> restarts; storing it in shared preferences is a five-line change.

---

## LAB 7.3 · Theme the whole app · 35 min

**Goal** — a seeded colour scheme, dark mode, every hard-coded colour and font
size removed, and a runtime theme switcher.

1. Give `ThemeData` a `colorScheme` from `ColorScheme.fromSeed`.
2. Add a `darkTheme` from the same seed with `brightness: Brightness.dark`, and
   `themeMode: ThemeMode.system`.
3. **Search your project for `Colors.` and `fontSize:` and replace every one**
   with a role or a named style.
4. Add a `filledButtonTheme` making every filled button 48 high, and delete any
   per-button sizing.
5. Create `ThemeModel extends ChangeNotifier` holding a `ThemeMode` and a seed
   `Color`.
6. Provide it with `MultiProvider` alongside `OrderModel`.
7. Watch it in `OrderFlowApp` so the whole app rebuilds when it changes.
8. Add three colour buttons to the app bar and confirm the entire app recolours.
9. **Switch the device to dark mode and check every screen is still readable.**

> **Step 3 is the discipline and the real lesson.** Count how many you find —
> numbers between five and fifteen are typical.
>
> **Step 9 is where the bugs surface.** Any surviving hard-coded colour shows up
> as unreadable text in dark mode.

### Common errors

- Setting `colorSchemeSeed` and `colorScheme` at the same time.
- Providing `ThemeModel` **below** `MaterialApp`, so nothing changes when you tap.
- Forgetting `copyWith` on a text style and replacing the whole style instead.

### Stretch

- Add an `inputDecorationTheme` so every text field is outlined, and remove the
  per-field borders.
- Add a fourth button that cycles `ThemeMode` between light, dark and system.
- Find any text that becomes unreadable in dark mode and work out which
  hard-coded colour caused it.

---

# Day 7 recap

- A `Form` groups fields, a `GlobalKey` is your handle, and `validate` runs
  everything in one call.
- **Validators return `null` for valid or a message for invalid.** Controllers
  are created in the State and disposed.
- Keyboard types and input formatters stop bad input before validation has to.
- **The Navigator is a stack.** `push` returns a `Future` of whatever `pop` sends
  back.
- **`setState` cannot reach another screen.** Lifting state works, and leads to
  prop drilling.
- `InheritedWidget` is the mechanism under `Theme.of` and the rest. It shares
  down, and gives you no way to write.
- **`ChangeNotifier` is a service that announces changes. `provider` is the
  container that hands it out.**
- **`watch` in build, `read` in callbacks.** `read` in build is a silent bug.
- Providers inject services too — the same DI argument you already accept.
- **One seed colour generates a whole palette**, light and dark. Use roles, never
  raw colours.

**Tomorrow (Day 8 · Data, Testing and Shipping):** calling a real HTTP API, JSON
to objects, storing data on the device, testing (unit, widget and what deserves
which), debugging, performance, accessibility and building a release.

---

# Appendix A · Lab 7.1

### Starter

```dart
// LAB 7.1 - a form and a second screen

// TODO 1: create AddLineScreen, a StatefulWidget with a
//         Scaffold titled 'Add line'
// TODO 2: inside it, a Form with a GlobalKey<FormState> and
//         two TextFormFields: SKU and quantity
//         Create the controllers in the State and dispose them
// TODO 3: SKU validator: required, and must match SKU-1234
//         Quantity validator: a whole number from 1 to 999
//         Use inputFormatters so the quantity field only
//         accepts digits, maximum four
// TODO 4: an Add button that validates and, if valid, calls
//         Navigator.pop(context, newLine) with a new OrderLine
// TODO 5: on OrderScreen, make the FloatingActionButton push
//         AddLineScreen and await the result
// TODO 6: if the result is not null, add it to your list with
//         setState, and show a SnackBar
// TODO 7: remember the mounted check after the await
// TODO 8: set autovalidateMode to onUserInteraction
```

### Solution

```dart
class AddLineScreen extends StatefulWidget {
  const AddLineScreen({super.key});

  @override
  State<AddLineScreen> createState() => _AddLineScreenState();
}

class _AddLineScreenState extends State<AddLineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _skuCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();

  @override
  void dispose() {
    _skuCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _add() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      OrderLine(
        sku: _skuCtrl.text.trim().toUpperCase(),
        description: 'Added by hand',
        quantity: int.parse(_qtyCtrl.text),
        unitPrice: 250,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add line')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _skuCtrl,
                decoration: const InputDecoration(
                  labelText: 'SKU',
                  hintText: 'SKU-1042',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final s = v?.trim() ?? '';
                  if (s.isEmpty) return 'SKU is required';
                  if (!s.isValidSku) return 'Use the form SKU-1234';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qtyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null) return 'Enter a whole number';
                  if (n < 1) return 'At least 1';
                  if (n > 999) return 'Maximum 999';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('Add line'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

```dart
// On OrderScreen:
floatingActionButton: FloatingActionButton(
  onPressed: () async {
    final line = await Navigator.push<OrderLine>(
      context,
      MaterialPageRoute(builder: (_) => const AddLineScreen()),
    );
    if (!context.mounted || line == null) return;
    setState(() => _lines.add(line));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${line.sku}')),
    );
  },
  child: const Icon(Icons.add),
),

// Needs: import 'package:flutter/services.dart';
```

---

# Appendix B · Lab 7.2

### Starter

```dart
// LAB 7.2 - lift the order into a model
// flutter pub add provider

// TODO 1: create lib/features/orders/state/order_model.dart
//         with class OrderModel extends ChangeNotifier
//         holding a private Order, with
//           Order get order
//           int get itemCount
//           double get subtotal
//           void addLine(OrderLine)
//           void removeLine(OrderLine)
//           void clear()
//         Remember notifyListeners() in every method that changes
// TODO 2: wrap runApp in a ChangeNotifierProvider
// TODO 3: make OrderScreen a StatelessWidget that takes NO
//         parameters, and read the model with context.watch
// TODO 4: the app bar title shows the item count from the model
// TODO 5: the FloatingActionButton pushes AddLineScreen and
//         adds the result with context.read, not watch
// TODO 6: the Dismissible calls context.read().removeLine
// TODO 7: add a Clear action to the app bar that calls clear()
// TODO 8: BREAK IT. Change one context.watch to context.read
//         and observe what stops working. Then change it back
```

### Solution

```dart
// lib/features/orders/state/order_model.dart
import 'package:flutter/foundation.dart';

class OrderModel extends ChangeNotifier {
  Order _order = const Order(
    id: 'ORD-1042',
    customer: 'Acme Ltd',
    lines: [],
  );

  Order get order => _order;
  int get itemCount => _order.itemCount;
  double get subtotal => _order.subtotal;
  bool get isEmpty => _order.lines.isEmpty;

  void addLine(OrderLine line) {
    _order = _order.copyWith(lines: [..._order.lines, line]);
    notifyListeners();
  }

  void removeLine(OrderLine line) {
    _order = _order.copyWith(
      lines: _order.lines.where((l) => l != line).toList(),
    );
    notifyListeners();
  }

  void clear() {
    _order = _order.copyWith(lines: const []);
    notifyListeners();
  }
}
```

```dart
// lib/main.dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => OrderModel(),
      child: const OrderFlowApp(),
    ),
  );
}
```

```dart
// lib/features/orders/presentation/order_screen.dart
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OrderModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('OrderFlow  ${model.itemCount} items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear',
            onPressed: () => context.read<OrderModel>().clear(),
          ),
        ],
      ),
      body: SafeArea(
        child: model.isEmpty
            ? const EmptyState(message: 'No lines yet')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: model.order.lines.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final line = model.order.lines[i];
                  return Dismissible(
                    key: ValueKey(line.sku),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Theme.of(context).colorScheme.error,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) =>
                        context.read<OrderModel>().removeLine(line),
                    child: LineTile(line: line),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final line = await Navigator.push<OrderLine>(
            context,
            MaterialPageRoute(builder: (_) => const AddLineScreen()),
          );
          if (!context.mounted || line == null) return;
          context.read<OrderModel>().addLine(line);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Answer to TODO 8

Changing the app bar's `watch` to `read` means the widget **no longer
subscribes**, so the item count never updates when a line is added. **Nothing
errors. It just silently stops working** — which is why the rule matters.

---

# Appendix C · Lab 7.3

### Starter

```dart
// LAB 7.3 - theme the whole app from one colour

// TODO 1: give ThemeData a colorScheme built with
//         ColorScheme.fromSeed and a seed colour of your choice
// TODO 2: add a darkTheme from the same seed with
//         brightness: Brightness.dark, and themeMode: ThemeMode.system
// TODO 3: search your widget files for Colors. and fontSize:
//         and replace every one with a colour role or a named style
// TODO 4: add a filledButtonTheme so every filled button is
//         48 logical pixels tall
// TODO 5: create ThemeModel extends ChangeNotifier holding a
//         ThemeMode and a seed Color
// TODO 6: provide it with MultiProvider alongside OrderModel
// TODO 7: watch it in OrderFlowApp
// TODO 8: add three buttons to the app bar that set the seed
//         to three different colours
// TODO 9: switch the device to dark mode and confirm every
//         screen is still readable
```

### Solution

```dart
class ThemeModel extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;
  Color _seed = const Color(0xFF2A9D8F);

  ThemeMode get mode => _mode;
  Color get seed => _seed;

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setSeed(Color seed) {
    _seed = seed;
    notifyListeners();
  }
}
```

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderModel()),
        ChangeNotifierProvider(create: (_) => ThemeModel()),
      ],
      child: const OrderFlowApp(),
    ),
  );
}

class OrderFlowApp extends StatelessWidget {
  const OrderFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeModel>();

    ThemeData build(Brightness brightness) => ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: theme.seed,
            brightness: brightness,
          ),
          useMaterial3: true,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        );

    return MaterialApp(
      title: 'OrderFlow',
      theme: build(Brightness.light),
      darkTheme: build(Brightness.dark),
      themeMode: theme.mode,
      home: const OrderScreen(),
    );
  }
}
```

```dart
// The three colour buttons, in the app bar actions:
actions: [
  for (final c in const [
    Color(0xFF2A9D8F),
    Color(0xFF8B1E3F),
    Color(0xFF264653),
  ])
    IconButton(
      icon: Icon(Icons.circle, color: c),
      tooltip: 'Theme',
      onPressed: () => context.read<ThemeModel>().setSeed(c),
    ),
],
```

---

# Appendix D · Where does this value live?

> **The test is always the same: would a second widget ever read this?**

| The value | Where it lives | Why |
|---|---|---|
| Text currently typed in a field | Widget `State` | Only that field cares, and it owns the controller |
| Whether a panel is expanded | Widget `State` | Purely local UI |
| The currently selected tab | Widget `State` | Nobody else reads it |
| A scroll position | Widget `State` | It owns the `ScrollController` |
| **The order being built** | A `ChangeNotifier` | Two screens change it |
| The item count in the app bar | **Derived** from the model | Never store what you can compute |
| The signed-in user | A `ChangeNotifier` | The whole app reads it |
| The chosen theme | A `ChangeNotifier` | `MaterialApp` reads it |
| The HTTP client | A plain `Provider` | A service, not state |
| A repository or API service | A plain `Provider` | Injected, swappable, faked in tests |
| Data fetched from a server | A `ChangeNotifier` | Shared, and it changes over time |
| A validation error message | The `Form` | The framework already manages it |

---

# Appendix E · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Nothing updates when the model changes | `read` used in `build` | Use `context.watch` in `build` |
| Nothing updates, and `watch` is correct | Missing `notifyListeners()` | Call it in every method that changes state |
| `ProviderNotFoundException` | Provider is below the consumer | Move it above, usually into `main` |
| `Undefined name FilteringTextInputFormatter` | Missing import | `import 'package:flutter/services.dart';` |
| `A TextEditingController was used after being disposed` | Controller created in `build` | Create it as a field on the `State` |
| Fields clear themselves on every keystroke | Same cause | Same fix |
| `validate()` always returns true | Validators return nothing on the invalid path | Every path must return a `String` or `null` |
| Errors never appear | `autovalidateMode` left at the default | Use `onUserInteraction`, or call `validate()` |
| The awaited push result is always null | The screen was popped without a value | Pass the value as the second argument to `pop` |
| Two screens close at once | Popped with the wrong context | Inside a dialog builder, pop with `ctx` |
| `setState() called after dispose()` | No `mounted` check after an await | `if (!context.mounted) return;` |
| State changes but the list does not | List mutated in place | Replace with `copyWith` and a new list |
| Text is unreadable in dark mode | A hard-coded colour | Use `colorScheme` roles |
| Theme switch does nothing | `ThemeModel` provided below `MaterialApp` | Provide it above, in `main` |

---

# Appendix F · Links

| Topic | Link |
|---|---|
| Forms and validation | https://docs.flutter.dev/cookbook/forms/validation |
| Retrieve text field input | https://docs.flutter.dev/cookbook/forms/retrieve-input |
| Text input formatters | https://api.flutter.dev/flutter/services/TextInputFormatter-class.html |
| Navigate to a new screen | https://docs.flutter.dev/cookbook/navigation/navigation-basics |
| Return data from a screen | https://docs.flutter.dev/cookbook/navigation/returning-data |
| Named routes | https://docs.flutter.dev/cookbook/navigation/named-routes |
| `go_router`, for later | https://pub.dev/packages/go_router |
| State management overview | https://docs.flutter.dev/data-and-backend/state-mgmt/intro |
| Simple app state management | https://docs.flutter.dev/data-and-backend/state-mgmt/simple |
| `provider` package | https://pub.dev/packages/provider |
| Riverpod, for later | https://riverpod.dev |
| Themes | https://docs.flutter.dev/cookbook/design/themes |
| Material 3 colour roles | https://m3.material.io/styles/color/roles |
