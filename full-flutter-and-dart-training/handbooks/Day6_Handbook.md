# Day 6 · Layout — Delegate Handbook

**Flutter for Java Developers · 8-Day Programme · Day 6 of 8**

Constraints · Row, Column and Expanded · Stack · Responsive · Lists and grids

> **Layout is where every Flutter beginner loses time.** Not because it is hard,
> but because it works differently from every layout system you have used, and
> until you have the rule it looks arbitrary.
>
> **There is one rule. It takes three sentences.** By this afternoon layout errors
> will be obvious rather than mysterious.

---

## Today's agenda

| | Time | Block |
|---|---|---|
| 1 | 09:00 – 10:30 | **Constraints** — constraints down, sizes up, parent positions; tight, loose and unbounded; the diagnostic question |
| 2 | 10:45 – 12:30 | **Row, Column, Expanded** — main and cross axis, Expanded/Flexible/Spacer, **the four errors**, **Lab 6.1** |
| 3 | 13:15 – 14:45 | **Stack and responsive** — Stack and Positioned, MediaQuery and LayoutBuilder, SafeArea, text scaling, **Lab 6.2** |
| 4 | 15:00 – 16:00 | **Lists and grids** — ListView and ListView.builder, swipe to delete, pull to refresh, GridView, **Lab 6.3** |

> **Every lab today includes breaking something on purpose and reading the
> error.** That is not filler. The fastest way to stop fearing layout errors is
> to cause four of them deliberately, in a safe setting, with the answer already
> in front of you.

---

# Module 1 · Constraints

**09:20 – 10:30**

By the end of this module you can:

- State the layout rule in one sentence
- Tell tight, loose and unbounded constraints apart
- Predict what a widget will do given its parent
- Ask the diagnostic question when a layout goes wrong

## The rule, in three sentences

> ### 1. Constraints go **down**
> A parent tells its child *"you may be this wide and this tall"* — a **range**,
> not a size.
>
> ### 2. Sizes go **up**
> The child picks a size inside that range and reports it back. **The child
> chooses; the parent constrains.**
>
> ### 3. The parent sets the **position**

**The consequence people find surprising:** a widget cannot know its own
position, and it cannot be bigger than its parent allows no matter what you ask
for. Setting `width: 500` inside something 200 wide gets you 200.

### The three kinds of constraint

```dart
// TIGHT: minimum equals maximum. You get exactly this size.
const SizedBox(width: 100, height: 40, child: ColoredBox(color: Colors.teal))

// LOOSE: minimum is zero, maximum is something real.
// "Be whatever you like, up to this."
const Center(child: Text('OrderFlow'))

// UNBOUNDED: maximum is infinity. "Be as big as you like."
// Nothing can be as big as infinity, so a widget that wants
// to fill its parent has no answer and fails.
```

> **Unbounded is the one that causes trouble.** Nothing can be infinitely big. A
> widget whose strategy is *"fill my parent"* has no answer when the parent says
> *"be as big as you like"* — it either collapses to zero or throws.
>
> **The four sources of unbounded constraints:** `ListView`,
> `SingleChildScrollView`, and **the main axis of `Row` and `Column`**. Almost
> every layout error traces back to one of those four.

**Compared with HTML and CSS:** those let a child escape its parent, with
absolute positioning, negative margins and overflow. Flutter does not. A child is
always inside its parent's constraints — more restrictive, and far more
predictable.

## One widget, three parents, three results

```dart
// 1. Inside Center: loose but BOUNDED, so "as big as allowed"
//    means the whole screen. The box fills it.
Center(
  child: Container(color: Colors.teal),
)

// 2. Inside a Column: the vertical axis is UNBOUNDED, so
//    "as big as allowed" has no answer and it collapses to
//    zero height. The box disappears entirely.
Column(
  children: [
    Container(color: Colors.teal),
  ],
)

// 3. Given a size: TIGHT constraints. Exactly 100 by 40,
//    anywhere in the tree.
const SizedBox(
  width: 100,
  height: 40,
  child: ColoredBox(color: Colors.teal),
)
```

**Case two is worth sitting with.** The box has disappeared and nothing is wrong.
This is the single most common *"my widget is not showing"* problem in Flutter,
and having seen it deliberately is worth an hour of debugging later.

> ## The diagnostic question
>
> ### **Who gave this widget its constraints, and what were they?**
>
> For the rest of today, when you have a layout problem, that is the question to
> ask — not *what is wrong*, but *who gave that widget its constraints*. It is
> the habit rather than the knowledge that matters.

## Reading a layout error

```
======== Exception caught by rendering library ========
A RenderFlex overflowed by 42 pixels on the right.

The relevant error-causing widget was:
  Row  Row:file:///.../line_tile.dart:24:18

The specific RenderFlex in question is:
  RenderFlex#a1b2c relayoutBoundary=up3 OVERFLOWING
```

**Engineers learn to ignore long error messages. Flutter's are long and they are
good** — the people who read them debug layout in seconds while everyone else
guesses.

**Three things to look for, in this order:**

| | | |
|---|---|---|
| **WHAT** | `RenderFlex` | means a `Row` or a `Column` |
| **WHICH AXIS** | *"on the right"* | horizontal, so a `Row`. *"on the bottom"* means a `Column` |
| **WHERE** | the relevant widget section | the file and line number |

**That is already enough to fix most of them.** Then ask the diagnostic question.

In debug, an overflow also paints **yellow and black stripes** on the device, so
you often see it before you read anything.

> **The error does not tell you the fix, and it cannot**, because the fix depends
> on what you meant. `Expanded`, `ellipsis`, a smaller font and a scroll view are
> all legitimate answers to the same error.

---

# Module 2 · Row, Column and Expanded

**10:45 – 12:30**

By the end of this module you can:

- Use main axis and cross axis alignment correctly
- Choose between `Expanded`, `Flexible`, `Spacer` and `SizedBox`
- Recognise the four layout errors on sight and fix each one
- Read the DevTools Layout Explorer

## Main axis, cross axis

```dart
Column(
  // MAIN AXIS for a Column is vertical
  mainAxisAlignment: MainAxisAlignment.start,
  // CROSS AXIS is the other one, so horizontal
  crossAxisAlignment: CrossAxisAlignment.stretch,
  // max fills the parent (default), min shrink-wraps
  mainAxisSize: MainAxisSize.max,
  children: [
    Row(
      children: [
        const Icon(Icons.inventory_2_outlined),
        const SizedBox(width: 8),
        // Expanded takes ALL the leftover width
        Expanded(
          child: Text(
            'A very long product description',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text('R 10 000.00',
            style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
    const SizedBox(height: 12),
    Row(
      children: [
        // flex splits the leftover space in a ratio
        Expanded(flex: 2, child: FilledButton(onPressed: () {}, child: const Text('Submit'))),
        const SizedBox(width: 8),
        Expanded(flex: 1, child: OutlinedButton(onPressed: () {}, child: const Text('Reset'))),
      ],
    ),
  ],
)
```

- **Main axis** is the direction the widget lays out — horizontal for a `Row`,
  vertical for a `Column`. `mainAxisAlignment` distributes the free space along it.
- **Cross axis** is the other one.
- **The one people mix up: a `Column`'s cross axis is horizontal.** Reasoning
  about the wrong axis is the source of a lot of confused fiddling.
- **`mainAxisSize: max`** fills the parent and is the default. `min` shrink-wraps
  — which matters inside a `Card` or a dialog.
- **`CrossAxisAlignment.stretch`** is the practical one. In a `Column` it makes
  children full width — that is how every full-width button is made.

**If you know CSS flexbox:** `Row` is `flex-direction: row`, `mainAxisAlignment`
is `justify-content`, `crossAxisAlignment` is `align-items`, `Expanded` is
`flex: 1`.

> **The difference from flexbox that matters:** a `Row` child with no `Expanded`
> gets **unbounded** width, so long text does not wrap — it overflows. In CSS it
> would wrap by default. That single difference explains most layout errors.

## Expanded, Flexible, Spacer, SizedBox

```dart
// EXPANDED: the child MUST take exactly its share of the
// leftover space. It is forced to that size.
Expanded(child: Text('fills the rest'))

// FLEXIBLE: the child MAY take UP TO its share. If it wants
// less, it gets less.
Flexible(child: Text('takes what it needs, up to its share'))

// SPACER: a flexible empty gap. Expanded with nothing in it.
Row(children: [Text('left'), Spacer(), Text('right')])

// SIZEDBOX: a fixed gap. Prefer this over Padding for spacing.
const SizedBox(width: 8)
const SizedBox(height: 16)
```

- **`Expanded` forces the size.** The child gets exactly its share of whatever is
  left after the fixed-size children have taken theirs. **It is the answer to
  most overflow errors.**
- **`Flexible` allows it.** The child may take up to its share and may take less.
  The difference matters when the child would naturally be small: with `Expanded`
  it is stretched, with `Flexible` it is not.
- **`flex` is a ratio, not a size.** Two `Expanded` children with flex 2 and flex
  1 split the leftover space two to one.
- **`SizedBox` is the idiom for spacing** between children. It says what it means
  and it is cheaper than `Padding`.

### Alignment options

| `mainAxisAlignment` | |
|---|---|
| `start` `end` `center` | |
| `spaceBetween` | first and last at the edges |
| `spaceAround` | equal space around each child |
| `spaceEvenly` | equal space between and at the edges |

| `crossAxisAlignment` | |
|---|---|
| `start` `end` `center` | |
| `stretch` | children fill the cross axis — full-width buttons in a Column |
| `baseline` | align text baselines |

## The four errors you will meet

### 1. `A RenderFlex overflowed by 42 pixels on the right`

```dart
// BROKEN
Row(children: [
  Text('A very long product description that will not fit'),
])
// WHY: the Row gave the Text unbounded width, so the Text
// asked for all the width it needed, which was too much.

// FIX: bound it.
Row(children: [
  Expanded(child: Text('A very long...', overflow: TextOverflow.ellipsis)),
])
```

### 2. `Vertical viewport was given unbounded height`

```dart
// BROKEN
Column(children: [
  ListView(children: const [Text('a')]),
])
// WHY: the Column's main axis is unbounded, and a ListView
// needs a bound to know how much to show.

// FIX: give it one.
Column(children: [
  Expanded(child: ListView(children: const [Text('a')])),
])
```

> There is also `ListView(shrinkWrap: true, physics: NeverScrollableScrollPhysics())`
> — **for a short list only.** It lays out every child, which defeats the purpose
> of a lazy list.

### 3. `Incorrect use of ParentDataWidget`

```dart
// BROKEN
Container(child: Expanded(child: Text('x')))
// WHY: Expanded only means something inside a Flex.

// FIX: put it directly inside a Row or Column.
Column(children: [Expanded(child: Text('x'))])
```

### 4. `BoxConstraints forces an infinite width`

```dart
// BROKEN
Row(children: [TextField()])
// WHY: TextField wants to fill the width; the Row offers infinity.

// FIX:
Row(children: [Expanded(child: TextField())])
```

> **These four cover the overwhelming majority of layout errors you will ever
> see.** You now have all four, with the fixes.

**Then open DevTools** — Flutter Inspector → Layout Explorer → select the Row. It
shows the flex factors and the overflow visually.

---

## LAB 6.1 · Build it, break it, fix it · 40 min

**Goal** — a properly laid out `LineTile` using `Row`, `Expanded` and `Column`
together, a two-thirds / one-third button row, and two errors caused
deliberately and fixed.

1. Rework `LineTile`: an `Icon`, a gap, then the description and sku stacked
   vertically in an `Expanded`, then the line total on the right.
2. Make the description ellipsis when too long, and **test it with a deliberately
   long description**.
3. Under the subtotal, add a button `Row` with Submit at `flex: 2` and Reset at
   `flex: 1`.
4. Use `CrossAxisAlignment.stretch` somewhere and say out loud what changed.
5. **BREAK IT:** remove the `Expanded` from step 1. Read the error. **Write down
   which widget it names and which axis.**
6. Put it back.
7. **BREAK IT AGAIN:** put a `ListView` directly inside your `Column`. Read that
   error. Fix it with `Expanded`.
8. Open DevTools → Layout Explorer → select your Row → look at the flex factors.

> **Steps 5 and 7 are the point of the lab.** Causing an error deliberately, with
> the fix already known, is what removes the fear. If you are short on time, skip
> step 8 instead.

### Common errors

- Putting `Expanded` on the wrong child, so the total gets the space instead of
  the description.
- Nesting a `Column` in a `Row` without an `Expanded`.
- Forgetting `maxLines` with `overflow` — which does nothing on its own.

### Stretch

- Use `Spacer` instead of `Expanded` on the totals row and decide which reads
  better.
- **Replace `Expanded` with `Flexible` on the description and describe the
  difference.** *(With `Flexible`, a short description does not stretch, so the
  total sits right next to it rather than at the far right.)*
- Make the button row stack vertically when the screen is narrow, without using
  `LayoutBuilder` yet.

---

# Module 3 · Stack and responsive layouts

**13:15 – 14:45**

By the end of this module you can:

- Layer widgets with `Stack` and `Positioned`
- Tell `MediaQuery` and `LayoutBuilder` apart, and know which you want
- Use `SafeArea` correctly
- Handle rotation and text scaling

## Stack and Positioned

```dart
Stack(
  // children are painted in order; later ones sit on top
  clipBehavior: Clip.none,
  children: [
    // A non-positioned child. The Stack sizes itself to fit it.
    Container(
      height: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    // Positioned relative to the Stack's edges
    Positioned(
      left: 16,
      top: 16,
      child: Text('ORD-1042',
          style: Theme.of(context).textTheme.titleLarge),
    ),
    // A negative offset hangs off the edge. Needs Clip.none.
    Positioned(
      right: 16,
      bottom: -14,
      child: Chip(
        label: const Text('Draft'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    ),
    // Covers the whole Stack: overlays, scrims, tap targets
    const Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: Icon(Icons.inventory_2, size: 56, color: Colors.white24),
      ),
    ),
  ],
)
```

- **Paint order is list order.** The first child is at the back.
- **Non-positioned children** are laid out by the Stack's alignment, and the
  Stack sizes itself to fit the biggest of them. That is why the sized Container
  comes first.
- **Negative offsets need `clipBehavior: Clip.none`**, otherwise the overhang is
  clipped away **silently**. That catches everyone once.
- **`Positioned.fill`** covers the whole Stack — overlays, scrims, full-area tap
  targets.

> **The trap:** a `Stack` whose children are **all** `Positioned` has no size of
> its own, because nothing tells it how big to be. It collapses. Give it a sized
> child, or `fit: StackFit.expand`. **Same constraints rule, new place.**

**For the CSS people:** `Stack` is `position: relative`, `Positioned` is
`position: absolute`.

**Where you will use it:** badges on icons, a status chip on a card, an image
with a caption overlay, and a loading scrim over a screen.

## MediaQuery, LayoutBuilder, SafeArea

```dart
// 1. THE SCREEN. Use sizeOf, not of, so you only rebuild
//    when the size actually changes.
final size = MediaQuery.sizeOf(context);
final isWide = size.width >= 600;

// 2. YOUR SLOT. This is usually what you actually want.
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 700) {
      return Row(children: [
        SizedBox(width: 280, child: summary),
        Expanded(child: lines),
      ]);
    }
    return Column(children: [summary, Expanded(child: lines)]);
  },
)

// 3. ORIENTATION
OrientationBuilder(
  builder: (context, o) =>
      o == Orientation.portrait ? portraitLayout : landscapeLayout,
)

// 4. THE NOTCH, THE STATUS BAR, THE GESTURE BAR
//    SafeArea goes INSIDE the Scaffold body, not around it.
SafeArea(child: body)

// 5. TEXT SCALING.
final scaler = MediaQuery.textScalerOf(context);
```

> **`MediaQuery` gives you the screen. `LayoutBuilder` gives you your slot.**
>
> Once an app bar, some padding and a `SafeArea` have taken their share, your
> slot is smaller than the screen. Inside a `Row` it can be far smaller.
>
> **A widget that decides to go two-column because the *screen* is 800 wide,
> while actually sitting in a 300-wide panel, is broken.** That is the bug this
> distinction prevents.

- **Use `sizeOf`, not `of`.** `MediaQuery.of` rebuilds your widget when *anything*
  in MediaQuery changes, including the keyboard appearing. `sizeOf` rebuilds only
  on a size change.
- **`SafeArea` goes inside the Scaffold body**, not around the Scaffold. Around
  the Scaffold you get a white bar where the app bar should be. Everybody does it
  once.
- **Text scaling is an accessibility requirement, not a nicety.** Users set 130%
  fonts and some set 200%. **Never fix a height around text.** Day 8 tests at 200%
  and anything with a hard-coded height breaks.

### Material breakpoints

| | |
|---|---|
| compact | under 600 |
| medium | 600 to 840 |
| expanded | 840 and up |

Our app switches at **700**, deliberately above the medium breakpoint, so a phone
in landscape stays single column.

---

## LAB 6.2 · A banner and a responsive shell · 35 min

**Goal** — a Stack-based order banner with an overhanging chip, and a screen that
switches from one column to two above 700 pixels.

1. Create `OrderBanner`: a rounded `Container` 140 high, the order id positioned
   top left, a status `Chip` bottom right with a negative offset, and a large
   faded icon behind.
2. **Remember `clipBehavior: Clip.none`**, or the chip will be cut off.
3. Wrap your screen body in `SafeArea`, **inside** the Scaffold, not around it.
4. Wrap the body in a `LayoutBuilder`.
5. Below 700 keep the vertical layout. At 700 and above, put the banner in a
   fixed 280-wide column on the left and the lines in an `Expanded` on the right.
6. Rotate the emulator to landscape and confirm it switches. In Chrome, resize
   the window.
7. **Print `MediaQuery.sizeOf` width and the `LayoutBuilder` `maxWidth` to the
   console, and explain the difference to your neighbour.**

> **Step 7 is the lesson, not the layout.** The two numbers differ. The screen is
> the screen; the constraints are what is left after everything above has taken
> its share.

### Common errors

- `SafeArea` around the Scaffold instead of inside it.
- A `Stack` with only `Positioned` children, which collapses to nothing.
- Forgetting the `SizedBox` width on the banner in the wide layout.
- Rotation not working because auto-rotate is off in the emulator quick settings.

### Stretch

- Add a `Positioned.fill` scrim over the banner that appears while loading.
- Use `Wrap` instead of `Row` for a set of status chips and narrow the window
  until they reflow.
- Make the banner collapse to a single line when the height is under 500 — a
  phone in landscape.

---

# Module 4 · Lists and grids

**15:00 – 16:00**

By the end of this module you can:

- Choose between `ListView`, `ListView.builder` and `SingleChildScrollView`
- Build a lazy list from data and key it correctly
- Add swipe to delete and pull to refresh
- Build a grid that reflows without breakpoint code

## `ListView`, and why a `Column` does not scroll

> **A `Column` is not a scrolling widget.** It lays out its children and that is
> all. If they do not fit, it overflows. Scrolling is a different widget's job.

```dart
// 1. Everything built up front. Fine for a handful of items.
ListView(
  padding: const EdgeInsets.all(16),
  children: const [
    ListTile(title: Text('ORD-1042')),
    ListTile(title: Text('ORD-1043')),
  ],
)

// 2. Lazy. Only builds the rows that are visible.
//    Use this for anything from a list of data.
ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: order.lines.length,
  itemBuilder: (context, index) {
    final line = order.lines[index];
    return LineTile(key: ValueKey(line.sku), line: line);
  },
)

// 3. Lazy, with a separator between rows.
ListView.separated(
  itemCount: order.lines.length,
  separatorBuilder: (context, index) => const SizedBox(height: 8),
  itemBuilder: (context, index) => LineTile(line: order.lines[index]),
)

// THE EMPTY STATE IS NOT OPTIONAL.
if (order.lines.isEmpty) {
  return const EmptyState(message: 'No lines yet');
}
```

**`ListView.builder` is the one to default to** for anything data-driven.
`itemCount` says how many exist, `itemBuilder` produces one on demand, and rows
that scroll off are disposed.

**For the Android people:** this is `RecyclerView`, with no adapter and no view
holder. For everyone else, it is virtual scrolling.

**Keys again** — yesterday's rule applies directly, and a list is exactly where it
matters. `ValueKey` of something that identifies the item, **never the index**.

**`padding` on the ListView itself** is the idiom, rather than wrapping it in a
`Padding`, because it keeps the scrollbar at the screen edge.

## Swipe to delete, pull to refresh, scroll control

```dart
// SWIPE TO DELETE
Dismissible(
  key: ValueKey(line.sku),              // MUST be unique per item
  direction: DismissDirection.endToStart,
  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 16),
    color: Theme.of(context).colorScheme.error,
    child: const Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (_) => _remove(line),    // MUST remove from the list
  child: LineTile(line: line),
)

// PULL TO REFRESH
RefreshIndicator(
  onRefresh: () async => _reload(),     // must return a Future
  child: ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: lines.length,
    itemBuilder: (c, i) => LineTile(line: lines[i]),
  ),
)

// SCROLLING PROGRAMMATICALLY
final _scroll = ScrollController();

@override
void dispose() {
  _scroll.dispose();                    // always
  super.dispose();
}

_scroll.animateTo(
  0,
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

**`Dismissible` has two mandatory rules:** a unique key per item, and **you must
actually remove the item from the underlying list** inside `onDismissed`. Miss the
second and Flutter throws *"A dismissed Dismissible widget is still part of the
tree"*.

**Why that error happens:** the widget animated away, but the next rebuild
produced it again because the data still contains it. Flutter notices the
contradiction and complains.

**`RefreshIndicator`** wraps a scrollable and `onRefresh` must return a `Future`.
It shows the spinner until that Future completes — so an instant refresh looks
broken. `AlwaysScrollableScrollPhysics` lets a short list still be pulled.

**`ScrollController` must be disposed** — yesterday's lifecycle rule in a new
place. Create in the State, dispose in `dispose`.

## `GridView` that reflows on its own

```dart
GridView.builder(
  padding: const EdgeInsets.all(16),
  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 220,     // as many 220px columns as fit
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 1.1,
  ),
  itemCount: products.length,
  itemBuilder: (context, index) {
    final p = products[index];
    return Card(
      child: InkWell(
        onTap: () => _select(p),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.inventory_2_outlined),
              const Spacer(),
              Text(p.name, style: Theme.of(context).textTheme.titleMedium),
              Text(p.unitPrice.rands),
            ],
          ),
        ),
      ),
    );
  },
)
```

**`maxCrossAxisExtent` means "as many columns of at most this width as will
fit".** A phone gets one or two, a tablet three or four, **and you write no
breakpoint code at all.**

The alternative, `SliverGridDelegateWithFixedCrossAxisCount`, pins the number of
columns and stretches the tiles.

- **`childAspectRatio` catches people.** It is **width divided by height**, so a
  value above one is wider than tall. Tiles that overflow vertically almost
  always need this adjusted — and the error will be this morning's RenderFlex
  overflow.
- **`InkWell` inside a `Card`** gives you the ripple on tap. `InkWell` needs a
  `Material` ancestor to paint on, and `Card` provides one. No ripple? That is why.

## Which scrolling widget

```dart
// SingleChildScrollView: ONE child, usually a Column, and it
// builds everything. Use it for a FORM or a settings page.
SingleChildScrollView(
  child: Column(children: [/* a known, modest number of things */]),
)

// ListView.builder: lazy, virtualised. Use it for DATA.
ListView.builder(itemCount: n, itemBuilder: (c, i) => Row$i)

// NESTED SCROLLING: a ListView inside a Column needs a bound.
Column(children: [
  header,
  Expanded(child: ListView.builder(...)),    // the usual fix
])
```

> **The trap worth naming:** a `Column` inside a `SingleChildScrollView` gets
> **unbounded height**, so an `Expanded` inside that Column will fail. People try
> to make one section fill the remaining space inside a scroll view — there is no
> remaining space in something infinitely tall.

**`shrinkWrap: true`** makes a ListView measure **all** its children, which is
O(n) and defeats lazy building. Fine for five rows, wrong for five hundred. It is
the tempting wrong answer to the nesting problem.

> **The default:** if it is data, `ListView.builder` with `Expanded`. If it is a
> page of content, `SingleChildScrollView` with a `Column`. That covers ninety
> per cent of screens.

---

## LAB 6.3 · A list that scrolls, deletes and refreshes · 35 min

**Goal** — the order lines in a lazy, separated `ListView` with swipe to delete,
pull to refresh, and a real empty state.

1. Replace the `for` loop of `LineTile`s with a `ListView.builder`, keyed by sku.
2. Add enough lines that the list definitely overflows the screen, and confirm it
   scrolls.
3. Switch to `ListView.separated` with an 8-pixel gap.
4. Move the lines into a **mutable** `List` in your State, and wrap each
   `LineTile` in a `Dismissible` that removes it and shows a `SnackBar`.
5. Wrap the list in a `RefreshIndicator` whose `onRefresh` restores the original
   lines after one second.
6. Handle the empty case, so deleting every line shows your `EmptyState`.
7. **Delete every line, then check whether you can still pull to refresh. Think
   about why.**

> **Step 7 is a deliberate design flaw and the best question in the lab.** Once
> the list is empty, the `EmptyState` replaces the `RefreshIndicator`, so there is
> nothing to pull. **That is a real bug that ships in real apps.** The fix is
> stretch goal two.
>
> It teaches that an empty state is **a state of the list**, not a replacement
> for it.

### Common errors

- A `const` list being mutated — the list must become mutable and live in the State.
- A missing or duplicated `Dismissible` key.
- Removing by index while the list is changing.
- Forgetting the `mounted` check in the async refresh.

### Stretch

- Add a second screen with a `GridView.builder` of products at
  `maxCrossAxisExtent: 220`, and rotate to see the columns change.
- **Fix the problem from step 7** so the empty state is still pullable — keep the
  `RefreshIndicator` and put the `EmptyState` inside a `SingleChildScrollView`
  with `AlwaysScrollableScrollPhysics`.
- Add a `ScrollController` and a button that animates back to the top.

---

# Day 6 recap

- **Constraints go down, sizes go up, the parent sets the position.** Every
  layout error is a violation of one of those.
- **Tight** means exactly this size. **Loose** means up to this. **Unbounded**
  means infinity, and nothing can be infinite.
- `ListView`, `SingleChildScrollView` and **the main axis of `Row` and `Column`**
  all hand out unbounded constraints.
- **The diagnostic question:** who gave this widget its constraints, and what
  were they?
- `Expanded` **forces** a share of the leftover space, `Flexible` **allows** up to
  a share, `Spacer` is an empty gap.
- **The four errors:** RenderFlex overflow, unbounded viewport, misplaced
  ParentDataWidget, infinite width.
- `Stack` layers children in paint order. Negative offsets need `Clip.none`.
- **`MediaQuery` is the screen. `LayoutBuilder` is your slot**, and it is usually
  the one you want.
- `ListView.builder` for data, `SingleChildScrollView` for a page. A `ListView`
  in a `Column` needs `Expanded`.

**Tomorrow (Day 7 · Forms, Navigation and State):** forms, text fields and
validation; navigating between screens and passing data back; why `setState`
stops being enough; state management and injecting a service; theming the whole
app from one colour.

---

## Homework tonight · 15 min

[docs.flutter.dev/ui/layout](https://docs.flutter.dev/ui/layout) — the "Layouts
in Flutter" page, then skim the
[layout widget catalogue](https://docs.flutter.dev/ui/widgets/layout).

1. Find one layout widget we did not use today and say what problem it solves.
2. What does `Wrap` do that `Row` cannot? Where would you use it in the order app?
3. What is the difference between `Align` and `Center`, and between `SizedBox`
   and `ConstrainedBox`?
4. Find the widget you would use to pin a total to the bottom of the screen while
   the list scrolls above it.

> Tomorrow at 09:00, a quick round of the room: **each person names one widget
> and one sentence on what it is for. No repeats.**

---

# Appendix A · Lab 6.1

### Starter

```dart
// LAB 6.1 - continue from your Day 5 project

// TODO 1: change LineTile so the row is
//           an Icon, a gap, the description and sku stacked
//           vertically and taking the leftover width, then
//           the line total on the right
//         Use Row, Expanded and Column together.
// TODO 2: make the description ellipsis when it is too long,
//         and test it with a deliberately long description
// TODO 3: under the subtotal, add a row of two buttons:
//         Submit taking two thirds of the width and Reset
//         taking one third, using Expanded with flex
// TODO 4: use CrossAxisAlignment.stretch somewhere and say
//         out loud what it did
// TODO 5: BREAK IT ON PURPOSE. Remove the Expanded from
//         TODO 1 and read the error message. Write down which
//         widget it names and which axis. Then put it back.
// TODO 6: BREAK IT AGAIN. Put a ListView directly inside your
//         Column. Read that error. Fix it with Expanded.
```

### Solution

```dart
class LineTile extends StatelessWidget {
  const LineTile({super.key, required this.line});
  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.description,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${line.sku}  x${line.quantity}',
                      style: text.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(line.lineTotal.rands, style: text.titleMedium),
          ],
        ),
      ),
    );
  }
}
```

```dart
// The two buttons, two thirds and one third:
Row(
  children: [
    Expanded(
      flex: 2,
      child: FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.check),
        label: const Text('Submit'),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      flex: 1,
      child: OutlinedButton(
        onPressed: _reset,
        child: const Text('Reset'),
      ),
    ),
  ],
)
```

### Answers to TODO 5 and 6

**5:** *"A RenderFlex overflowed by N pixels on the right."* It names the `Row`,
and "on the right" means the horizontal axis. The `Text` asked for more width
than the `Row` had.

**6:** *"Vertical viewport was given unbounded height."* The `Column`'s main axis
is unbounded and a `ListView` needs a bound. `Expanded` supplies one.

---

# Appendix B · Lab 6.2

### Starter

```dart
// LAB 6.2 - a header and a responsive shell

// TODO 1: a StatelessWidget OrderBanner that uses a Stack:
//           a rounded Container 140 high in primaryContainer
//           the order id positioned top left
//           a Chip with the status label positioned bottom
//             right with a negative offset, so it overhangs
//           a large faded icon filling the Stack behind
//         Remember clipBehavior: Clip.none
// TODO 2: wrap your screen body in SafeArea, INSIDE the
//         Scaffold, not around it
// TODO 3: wrap the body in a LayoutBuilder. Below 700 logical
//         pixels, keep the current vertical layout. At 700 and
//         above, put the banner in a fixed 280 wide column on
//         the left and the lines in an Expanded on the right
// TODO 4: rotate the emulator to landscape and confirm the
//         layout switches. In Chrome, resize the window
// TODO 5: use MediaQuery.sizeOf to print the screen width to
//         the console, and compare it with the constraints
//         your LayoutBuilder receives. Explain the difference
```

### Solution

```dart
class OrderBanner extends StatelessWidget {
  const OrderBanner({super.key, required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 140,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(Icons.inventory_2, size: 64, color: Colors.white24),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.id,
                    style: text.titleLarge
                        ?.copyWith(color: colors.onPrimaryContainer)),
                Text(order.customer,
                    style: text.bodyMedium
                        ?.copyWith(color: colors.onPrimaryContainer)),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: -14,
            child: Chip(
              label: Text(order.status.label),
              backgroundColor: colors.surface,
            ),
          ),
        ],
      ),
    );
  }
}
```

```dart
// The responsive shell, inside the Scaffold:
body: SafeArea(
  child: LayoutBuilder(
    builder: (context, constraints) {
      final banner = OrderBanner(order: _order);
      final lines = ListView.builder(
        itemCount: _order.lines.length,
        itemBuilder: (c, i) =>
            LineTile(key: ValueKey(_order.lines[i].sku), line: _order.lines[i]),
      );

      if (constraints.maxWidth >= 700) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 280, child: banner),
              const SizedBox(width: 16),
              Expanded(child: lines),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            banner,
            Expanded(child: lines),
          ],
        ),
      );
    },
  ),
),
```

### Answer to TODO 5

`MediaQuery.sizeOf` gives the whole **screen**. `LayoutBuilder` gives the
constraints of **this slot**, which is smaller once padding, an app bar and a
`SafeArea` have taken their share. Inside a `Row` or a dialog they can differ a
lot, **and the LayoutBuilder number is the one you want.**

---

# Appendix C · Lab 6.3

### Starter

```dart
// LAB 6.3 - lists that scroll

// TODO 1: replace the for loop of LineTiles with a
//         ListView.builder, keyed by sku
// TODO 2: add enough lines to your order that it definitely
//         overflows the screen, and confirm it scrolls
// TODO 3: switch to ListView.separated with an 8 pixel gap
// TODO 4: wrap each LineTile in a Dismissible so a swipe from
//         right to left deletes it. Keep the lines in a
//         mutable List in your State and remove the item in
//         onDismissed. Show a SnackBar naming what was removed
// TODO 5: wrap the list in a RefreshIndicator whose onRefresh
//         restores the original lines after a one second delay
// TODO 6: handle the empty state, so deleting every line shows
//         your EmptyState widget rather than a blank area
// TODO 7 (stretch): add a second screen showing products in a
//         GridView.builder with maxCrossAxisExtent 220
```

### Solution

```dart
class _OrderScreenState extends State<OrderScreen> {
  static const _original = <OrderLine>[
    OrderLine(sku: 'SKU-1', description: 'Widget', quantity: 40, unitPrice: 250),
    OrderLine(sku: 'SKU-2', description: 'Gasket', quantity: 10, unitPrice: 120),
    OrderLine(sku: 'SKU-3', description: 'Bracket', quantity: 5, unitPrice: 90),
    OrderLine(sku: 'SKU-4', description: 'Seal', quantity: 200, unitPrice: 15),
    OrderLine(sku: 'SKU-5', description: 'Bearing', quantity: 12, unitPrice: 340),
    OrderLine(sku: 'SKU-6', description: 'Coupling', quantity: 3, unitPrice: 890),
  ];

  late List<OrderLine> _lines = List.of(_original);

  void _remove(OrderLine line) {
    setState(() => _lines.remove(line));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${line.sku}')),
    );
  }

  Future<void> _reload() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _lines = List.of(_original));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OrderFlow')),
      body: SafeArea(
        child: _lines.isEmpty
            ? const EmptyState(message: 'No lines yet. Pull down to restore.')
            : RefreshIndicator(
                onRefresh: _reload,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final line = _lines[index];
                    return Dismissible(
                      key: ValueKey(line.sku),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        color: Theme.of(context).colorScheme.error,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _remove(line),
                      child: LineTile(line: line),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
```

> **The deliberate flaw:** the empty state replaces the `RefreshIndicator`
> entirely, which means you cannot pull to restore once it is empty. Fixing that
> properly is the stretch goal: keep the `RefreshIndicator` and put the
> `EmptyState` inside a `SingleChildScrollView` with
> `AlwaysScrollableScrollPhysics`.

---

# Appendix D · Which layout widget

| You want | Use | Note |
|---|---|---|
| Things in a horizontal line | `Row` | Children get **unbounded width** |
| Things stacked vertically | `Column` | **Does not scroll** |
| One child to take the leftover space | `Expanded` | Forces the size |
| One child to take up to its share | `Flexible` | Allows a smaller size |
| A fixed gap | `SizedBox(height: 12)` | The idiom for spacing |
| A flexible gap | `Spacer()` | An empty `Expanded` |
| Things layered on top of each other | `Stack` + `Positioned` | `Clip.none` for overhang |
| Things that wrap onto a new line | `Wrap` | Chips, tags, filters |
| A scrolling page of content | `SingleChildScrollView` + `Column` | Forms, settings |
| A scrolling list from data | `ListView.builder` | Lazy. Key it by id |
| A list with separators | `ListView.separated` | |
| A grid that reflows | `GridView.builder` + max extent | No breakpoints needed |
| A different layout by width | `LayoutBuilder` | **Your slot**, not the screen |
| A different layout by device | `MediaQuery.sizeOf` | The whole screen |
| To avoid the notch | `SafeArea` | **Inside** the Scaffold body |
| To force a size | `SizedBox` | |
| Minimum or maximum bounds | `ConstrainedBox` | |
| To centre one child | `Center` | `Align` for any other position |
| Space around one child | `Padding` | Not a `Container` |

---

# Appendix E · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Yellow/black stripes, `RenderFlex overflowed` | Child bigger than the Row or Column | `Expanded`, or make the axis scrollable |
| `Vertical viewport was given unbounded height` | `ListView` inside a `Column` | `Expanded(child: ListView(...))` |
| `Incorrect use of ParentDataWidget` | `Expanded` not directly in a Flex | Move it inside the `Row` or `Column` |
| `BoxConstraints forces an infinite width` | `TextField` inside a `Row` | `Expanded(child: TextField())` |
| A widget is simply not visible | Unbounded axis, no size, no child | Give it a size, or bound the parent |
| A `Stack` renders as nothing | All children are `Positioned` | Add a sized child or `StackFit.expand` |
| A `Positioned` child is cut off | Negative offset with default clipping | `clipBehavior: Clip.none` |
| `overflow: ellipsis` does nothing | The `Text` has unbounded width | Wrap in `Expanded`, and set `maxLines` |
| White bar where the app bar should be | `SafeArea` wrapped around the `Scaffold` | Put `SafeArea` inside the body |
| `A dismissed Dismissible is still in the tree` | Item not removed in `onDismissed` | Remove it from the list, and key by id |
| Pull to refresh does nothing on a short list | Default physics will not scroll | `AlwaysScrollableScrollPhysics` |
| Grid tiles overflow vertically | `childAspectRatio` too tall | Raise the ratio — **width over height** |
| The list is very slow | `shrinkWrap: true` on a long list | Use `Expanded` and remove `shrinkWrap` |
| `Expanded` inside a scroll view fails | Unbounded height in a scroll view | There is no leftover space. Remove it |

---

# Appendix F · Links

| Topic | Link |
|---|---|
| **Understanding constraints** | https://docs.flutter.dev/ui/layout/constraints |
| Layouts in Flutter | https://docs.flutter.dev/ui/layout |
| Layout widget catalogue | https://docs.flutter.dev/ui/widgets/layout |
| Adaptive and responsive design | https://docs.flutter.dev/ui/adaptive-responsive |
| Long lists | https://docs.flutter.dev/cookbook/lists/long-lists |
| Grid lists | https://docs.flutter.dev/cookbook/lists/grid-lists |
| Swipe to dismiss | https://docs.flutter.dev/cookbook/gestures/dismissible |
| Pull to refresh | https://api.flutter.dev/flutter/material/RefreshIndicator-class.html |
| DevTools Layout Explorer | https://docs.flutter.dev/tools/devtools/inspector |
| Material breakpoints | https://m3.material.io/foundations/layout/applying-layout |
