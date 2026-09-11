# Day 1 · Getting Oriented — Delegate Handbook

**Flutter for Java Developers · 8-Day Programme · Day 1 of 8**

What a mobile app is · What Flutter is · Getting it running · Meeting Dart

> No prior mobile experience is assumed. Today starts with what an app actually
> is. If you have never installed an emulator or seen an APK, this day is built
> for you.
>
> Most of what you know transfers. Dart was designed by people who wrote a lot
> of Java — variables, types, classes, loops, generics and exceptions are all
> there, mostly with the same spelling. What is genuinely new is the way the
> screen is built, and that is one idea repeated many times.

---

## Today's agenda

| | Time | Block |
|---|---|---|
| 1 | 09:00 – 10:30 | **What a mobile app is** — how it differs from a server process, what gets installed on a phone, emulators and real devices, the app lifecycle and the one UI thread |
| 2 | 10:45 – 12:30 | **What Flutter is** — the honest comparison, the three layers, installing it, **Lab 1.1** |
| 3 | 13:15 – 14:45 | **Meeting Dart** — hello world, variables, types, numbers, text, `final` and `const`, **Lab 1.2** |
| 4 | 15:00 – 16:00 | **Decisions, loops, functions** — `if`, `switch`, `??`, loops and lists, named parameters, **Lab 1.3** |

**The whole afternoon runs in a web browser at [dartpad.dev](https://dartpad.dev).**
A broken install cannot stop you taking part. If your install is fighting you,
keep going and fix it at lunch.

---

# Module 1 · What a mobile app actually is

**09:10 – 10:30**

By the end of this module you can:

- Describe how a mobile app differs from a server process you deploy
- Say what is inside an installed app and how it gets there
- Explain what an emulator is, and when to use a real phone instead
- Describe the app lifecycle and why there is no reliable "on exit"

> **The one sentence to take from this module:** on a server you are one of many
> processes on hardware you control; on a phone you are a guest, on one thread,
> in someone's pocket, and you can be killed at any moment.

## A server process against a mobile app

| | Your Spring service | A mobile app |
|---|---|---|
| **Shape of the work** | Request in, response out, repeat | One long session, minutes or hours |
| **State between actions** | In a database. Rebuilt per request | In memory, held the whole time |
| **Who starts it** | You deploy it | The user taps an icon |
| **Who stops it** | You, on the next release | The user, or the OS, with no warning |
| **Concurrency** | A thread pool of two hundred | **One thread for the whole interface** |
| **If something takes 200 ms** | One request is a bit slow | **The entire screen freezes** |
| **Resources** | Add another instance | Whatever that phone has, and its battery |
| **Failure** | A 500 and a log line | The user sees it, and rates you one star |
| **Updating it** | Deploy whenever you like | Store review, then users must accept it |
| **Talking to it** | HTTP from another service | A person, with a finger, on glass |

The two rows that matter most are **concurrency** and **the 200 ms row**. On a
server a slow method costs you one request out of a large pool. Here it costs
the user interface, visibly, for everybody using the app.

The **update row** is worth a minute of your attention. Backend teams are used
to fixing forward. On mobile a bad release sits in the wild for days: store
review takes time, and users have to accept the update. That changes how much
you test before you ship.

## What actually gets installed on the phone

```
app-release.apk          a zip file, roughly 18 MB
├── AndroidManifest.xml  permissions, entry point, app name
├── classes.dex          a small Java/Kotlin shim, not your app logic
├── lib/
│   └── arm64-v8a/
│       ├── libflutter.so    the Flutter engine, C++, about 6 MB
│       └── libapp.so        YOUR Dart code, compiled to ARM machine code
├── assets/
│   └── flutter_assets/      images, fonts, the icon, any files you bundle
└── res/                     launcher icons, the native splash screen
```

**The comparison that lands:** a `.jar` contains bytecode and nothing else. It
assumes a JVM is already on the machine. An `.apk` assumes nothing — it carries
your compiled code, the engine that runs it, and every asset your app needs.

- **`libapp.so` is the interesting file.** That is your Dart, compiled to ARM
  machine code. Not bytecode. Machine code. It is why Flutter apps need no
  runtime installed and have no warm-up period.
- **`libflutter.so` is the engine**, and it is why a Flutter app has a size floor
  of roughly 15–20 MB. For an internal enterprise app nobody cares. For a
  consumer app in a market with expensive data it is a real consideration.
- **`classes.dex` surprises people.** Yes, there is some Java and Kotlin in
  there. It is a thin shim that creates the Android Activity and hands control to
  the engine. Your application logic is not in it.

**APK, AAB and IPA:** an APK installs directly. An **App Bundle** (`.aab`) is
what you upload to Google Play, and Play generates a trimmed APK for each
device — only that screen density, only that CPU architecture. The iOS
equivalent of an APK is an `.ipa`.

> An APK is a zip file. Rename one to `.zip` and open it. It takes thirty
> seconds and makes the whole thing concrete.

## Emulators and real devices

**What an emulator is** — a virtual Android phone running on your laptop, with a
virtual CPU, screen and storage. It is a full Android operating system in a
window, not a simulation of one.

**Why it needs hardware acceleration** — without virtualisation support turned on
in the BIOS it has to emulate the processor in software and becomes unusably
slow. This is the single most common Windows problem in this course.

**Why a real phone is often better** — real speed, real touch, real camera, and
no virtualisation to fight with:

1. Settings → About phone
2. Tap **Build number** seven times
3. Back → **Developer options** → turn on **USB debugging**
4. Plug it in, accept the prompt on the phone

**The web as a third option** — Flutter also runs in Chrome. Nothing in the first
few days needs a phone, so if your emulator will not start you can use a browser
and lose nothing.

**iOS, honestly** — you can write iOS code on any machine. You can only build and
sign it on a Mac. That is Apple's rule, not Flutter's, and no framework gets
around it.

> If your emulator refuses to start today, do not fight it. Use a phone, or use
> Chrome. Losing an hour to virtualisation settings is the worst possible use of
> your Day 1.

## The app lifecycle, and why there is no "on exit"

```
resumed    on screen, has focus, running normally
inactive   on screen but not focused (a call is coming in)
paused     not visible. Still in memory. Timers keep running.
detached   the Flutter engine is running with no view attached
hidden     about to be paused (newer Flutter versions)
```

And then, **without warning and with no callback at all**, the operating system
can kill your process to reclaim memory.

> **The rule that follows, and it is worth writing down:** save when you become
> `paused`, not when you exit, **because there is no exit**. If the user has typed
> half an order and takes a phone call, that half order must already be on disk.

Two things that catch server developers:

- **`paused` does not mean frozen.** Timers keep firing, network calls keep
  completing, and your code keeps running while the app is off screen. That is a
  common source of bugs where a callback fires against a screen that is no
  longer there. We handle it properly on **Day 4**.
- **Rotation** — on Android, rotating the device destroys and recreates the
  Activity by default. Flutter handles this far better than native Android does,
  but you will notice it if you rotate your emulator.

---

# Module 2 · What Flutter is, and getting it running

**10:45 – 12:30**

By the end of this module you can:

- Say what Flutter is and how it compares to the alternatives
- Describe the three layers without needing to touch two of them
- Explain why development feels fast and release builds run fast
- Get a Flutter app running on your own machine

## What Flutter is, in four sentences

1. **It is a toolkit for building app screens.** You write one codebase in a
   language called Dart, and it produces a real Android app and a real iOS app
   from that same code.
2. **It draws every pixel itself.** Flutter does not borrow the phone's buttons
   and text boxes. It ships a drawing engine and paints its own. That is why the
   app looks identical on every device.
3. **It compiles to native machine code.** For a release build there is no
   interpreter and no virtual machine on the phone. Your code runs directly on
   the processor.
4. **It is made by Google and it is open source.** Used in production since 2018,
   including by Google itself. The whole framework is Dart source you can read
   and step into with a debugger.

**The consequence to remember:** because Flutter draws its own controls, your app
looks the same on a Samsung and an iPhone, and an operating system update cannot
change how your app looks overnight.

**The trade-off, stated fairly:** a Flutter text field is not the platform's text
field. It behaves very similarly and Flutter works hard at that — but if your
requirement is "indistinguishable from a native control in every respect", that
is a real consideration.

## The honest comparison

| | Flutter | Native Android | React Native |
|---|---|---|---|
| Language | Dart | Kotlin or Java | TypeScript |
| Covers iOS too | Yes, same code | No, separate app | Yes, same code |
| How the UI is drawn | Its own engine | Platform controls | Platform controls |
| Looks the same on both | Yes, by design | n/a | Varies |
| Speed of the finished app | Native machine code | Fastest | Good, with a bridge |
| App size floor | About 15–20 MB | A few MB | About 10 MB |
| Learning cost for this room | A new language, familiar ideas | Familiar language, mobile only | New language and new style |
| Access to phone hardware | Plugins, or write a bridge | Direct | Native modules |
| Maturity | Production since 2018 | Highest | Production since 2015 |

**The honest case for Flutter:** one codebase for both platforms, identical
appearance, very fast iteration, and a mature ecosystem.

**The honest costs:** you learn a new language, the app has a size floor because
the engine ships inside it, and anything genuinely platform-specific needs a
plugin or a bridge you write yourself.

**When native is the right answer:** if the app is Android only, if it is deeply
tied to platform hardware, or if the team is already expert in Kotlin and has no
iOS requirement, native is a perfectly good decision.

**On Kotlin Multiplatform:** it is a real option and it would keep you in a
familiar language. It is younger, its iOS story settled much later, and the
third-party library ecosystem is smaller. That is a fair summary.

## The three layers, and which one you live in

| Layer | Written in | What it is |
|---|---|---|
| **The framework** | Dart | Everything you import and use: buttons, text, layout, gestures, animation. All of it is Dart source you can read. **This is where you spend the entire course.** |
| **The engine** | C++ | The drawing engine, the Dart runtime, and text layout. It is what makes the app look the same everywhere. You will not touch it. |
| **The embedder** | Per platform | A thin native shell: an Android Activity, an iOS view controller. It owns the window and passes touches and lifecycle events inward. You touch it only if you write a bridge to native code. |

A rough server analogy — and it is rough, which is fine: the framework is your
application code, the engine is the JVM, and the embedder is the servlet
container. You live in the first, trust the second, and rarely configure the
third.

**The point to land:** you do not need to understand the bottom two layers to
build a real app.

## Why development feels fast, and release builds run fast

```bash
# DEVELOPMENT
flutter run
# The Dart VM compiles as it runs. Because the VM is live, Flutter
# can inject changed code into it while the app keeps running.
# That is hot reload, and it takes about one second.

# PRODUCTION
flutter build apk --release
# Your Dart is compiled all the way to ARM machine code BEFORE it
# ships. On the phone there is no VM to warm up and nothing to
# interpret. The CPU runs your code directly.

# MEASURING PERFORMANCE
flutter run --profile
# Release-style compilation, plus instrumentation.
```

**Mapped to the JVM:** during development the Dart VM compiles as it runs, in the
same way HotSpot does for Java. Because that VM is alive while your app runs,
Flutter can push changed code into it without restarting — that is hot reload.
Java has HotSwap, and your IDE still tells you to restart when you add a method.
Dart hot reload adds methods, adds fields, changes classes, and rebuilds the
whole screen from your new code, in about a second, **while your app keeps its
state**.

> **Every performance number must come from profile mode.** A debug build carries
> assertions and no optimisation and can be five times slower. A "Flutter is
> slow" claim from a debug build is not a measurement.

## Installing Flutter

> **Two rules on both platforms:** no spaces anywhere in the path, and not inside
> `Program Files` or `/Applications`.

### macOS · zsh

```bash
# The simple way
brew install --cask flutter

# Or the manual way: download the zip for your chip from
#   https://docs.flutter.dev/get-started/install/macos
# then add it to your PATH
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Check it
flutter --version

# Only if you also want to build for iPhone
sudo xcode-select --install
```

### Windows · PowerShell

```powershell
# 1. Download the stable Windows zip from
#    https://docs.flutter.dev/get-started/install/windows
#    Extract it so you have C:\src\flutter\bin

# 2. Add it to your user PATH
$u = [Environment]::GetEnvironmentVariable("Path","User")
[Environment]::SetEnvironmentVariable("Path","$u;C:\src\flutter\bin","User")

# 3. CLOSE this window. Open a NEW PowerShell.
flutter --version

# 4. Ask IT to exclude C:\src\flutter and your projects folder from
#    antivirus scanning. Builds are three to five times slower without it.
```

> **Windows PowerShell 5.1 has no `&&` operator.** Run one command per line. This
> catches somebody in every single class.
>
> **Step 3 is the one people skip.** The PATH change only applies to *new*
> terminals. If `flutter` is "not recognised", you are in the old window.

## Android Studio, and starting your first build

You need Android Studio for the Android SDK and the emulator, even if you write
code in a different editor.

```bash
# 1. https://developer.android.com/studio
#    Run the setup wizard, choose Standard.

# 2. In Android Studio:
#    More Actions > SDK Manager > SDK Tools tab
#    TICK "Android SDK Command-line Tools (latest)"
#    Apply.

flutter doctor --android-licenses
# press y at every prompt

# 3. START THIS NOW. It downloads about 4 GB.
cd ~/development          # on Windows: cd $HOME
flutter create --org com.example order_flow
cd order_flow
flutter build apk --debug
```

> That first build fetches the Android build tools and takes seven to eight
> minutes. **Start it before the theory, not after it.**

`--org com.example` sets the package name that identifies the app on the device.
Changing it later means editing several native files, so it is worth setting now.

**The SDK Tools tab is a sub-tab** — the first tab shown is SDK Platforms. Look
for the second one.

## `flutter doctor`: what matters and what does not

| What it says | Blocks you? | What to do |
|---|---|---|
| `cmdline-tools component is missing` | **Yes** | Android Studio → SDK Manager → SDK Tools tab → tick Android SDK Command-line Tools → Apply |
| `Android license status unknown` | No | Known cosmetic bug. Prove the toolchain with `flutter build apk --debug` and carry on |
| `Xcode - develop for iOS incomplete` | No | Only matters if you build for iPhone. Not needed this course |
| `CocoaPods not installed` | No | iOS only. Ignore it |
| `Visual Studio - develop for Windows` | No | Only for Windows desktop apps |
| `Chrome - develop for the web` | No | Worth having. It gives you a device when the emulator will not start |
| `No devices available` | **Yes** | Start an emulator, or plug in a phone with USB debugging on |
| `flutter is not recognised` | **Yes** | You are in the old terminal window. Close it and open a new one |

> **The only test that really matters:** `flutter build apk --debug` succeeds, and
> `flutter devices` lists something. Everything else is advisory.

## Your first Flutter app, line by line

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
      home: Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: const Center(
          child: Text('No orders yet'),
        ),
      ),
    );
  }
}
```

Read it from the inside out:

| | |
|---|---|
| `Text` | the words on screen |
| `Center` | puts its child in the middle |
| `Scaffold` | gives you the standard page: app bar, body |
| `MaterialApp` | sets up theming, navigation and text direction |
| `runApp` | hands the whole thing to Flutter to draw |

**The word to learn is `widget`.** Every one of those five things is a widget. A
widget is a description of a piece of the screen. Padding is a widget. Centering
is a widget. That sounds excessive right now and it will feel obvious by the end
of the week.

**The shift from Java:** there is no XML, no FXML and no template file. The screen
is described in ordinary code, so the compiler checks it, refactoring works, and
you can use `if` and `for` inside your layout without a template language.

> `const` and `super.key` are both explained later — `const` this afternoon, keys
> when we reach widgets properly. For now, copy the pattern.

## Hot reload

Keys in the terminal where `flutter run` is running:

| Key | Does |
|---|---|
| `r` | **hot reload** — load changed code, **keep** what is on screen |
| `R` | **hot restart** — start the app again, **lose** what is on screen |
| `p` | show layout guides on the device |
| `o` | switch between the Android and iOS look |
| `v` | open DevTools in a browser |
| `q` | quit |

**Hot reload cannot handle these four. Press `R` instead:**

1. You changed `main()`, or anything outside a class
2. You changed an enum, or a class's parent
3. You added an image or edited `pubspec.yaml`
4. It stopped working entirely

> **The sneaky fifth case:** a compile error has scrolled past in the terminal and
> you keep saving and staring at the phone. **When nothing changes, read the
> terminal, not the device.**

---

## LAB 1.1 · Your first running app · 30 min

**Goal** — a Flutter app running on your emulator, your phone, or Chrome, and hot
reload working.

1. Run `flutter doctor -v` and read every line. Use the table above to decide
   what actually matters.
2. If you have not already: `flutter create --org com.example order_flow`, then
   move into that folder.
3. Start an emulator from Android Studio Device Manager, or plug in a phone with
   USB debugging on.
4. Run `flutter devices`. If nothing is listed, you have no device yet — use
   `flutter run -d chrome` instead.
5. Run `flutter run`. The first build takes seven to eight minutes. Every one
   after that takes seconds.
6. Find the app bar title in `lib/main.dart`, change the text, and save. Watch it
   update without restarting.
7. Tap the plus button a few times, then change the text again and save. **Notice
   the count survives.**
8. Now press `R` in the terminal for a hot restart. **Notice the count goes back
   to zero.** That is the difference.
9. Delete `test/widget_test.dart`. We write a real test on **Day 8** and this
   generated one gets in the way.
   *(macOS: `rm test/widget_test.dart` · Windows: `del test\widget_test.dart`)*
10. Run `flutter analyze`. It should report no issues.

> **Steps 6 to 8 are the actual lesson.** Getting the app running is plumbing.
> Feeling the difference between reload and restart is the thing you will use a
> hundred times a day.

### Stretch

- Run `flutter run -d chrome` and see the same app in a browser.
- Press `p` and look at the layout guides drawn over the app.
- Press `o` and watch the app switch between the Android and iPhone look.

---

# Module 3 · Meeting Dart

**13:15 – 14:45 · everything here runs at [dartpad.dev](https://dartpad.dev)**

By the end of this module you can:

- Read a Dart file and know where the program starts
- Declare variables, and use numbers, text and booleans
- Use string interpolation instead of concatenation
- Explain `final` and `const`, and what a nullable type means

## Hello, Dart

```dart
// Every Dart program starts here. Same idea as public static void main.
void main() {
  print('Hello from Dart');
}
```

```java
// Java
public class Hello {
  public static void main(String[] args) {
    System.out.println("Hello from Java");
  }
}
```

**No class required.** A Dart file can hold functions and variables directly at
the top level. That is not a scripting shortcut; it is a deliberate design
choice, and it is why Dart files feel lighter than Java files.

**The file naming rule:** Java forces the file name to match the public class.
Dart has no such rule, which is why Dart files are named in lowercase with
underscores rather than UpperCamelCase.

## How a Dart file is laid out

```dart
void main() {
  // Statements end with a semicolon, exactly like Java.
  print('one');
  print('two');

  // Line comment
  /* Block comment */
  /// Doc comment. This is what shows up on hover in the editor.

  // Curly braces group statements, exactly like Java.
  if (true) {
    print('inside the block');
  }
}
```

Naming, and the analyser will nag you about all of it:

| Convention | Used for |
|---|---|
| `lowerCamelCase` | variables, functions, parameters |
| `UpperCamelCase` | classes, enums, extensions |
| `lowercase_with_underscores` | file names and package names |

The triple slash is worth pointing out — it is what appears when you hover over
something in the editor, and it is the equivalent of Javadoc.

## Variables

```dart
void main() {
  // Declare with the type, exactly like Java.
  String customer = 'Acme Ltd';
  int quantity = 40;
  double unitPrice = 250.0;
  bool isUrgent = true;

  // Or let the compiler work it out. This is still fully typed:
  // sku is a String forever, and assigning an int to it is an error.
  var sku = 'SKU-1042';

  print(customer);
  print(quantity);
  print(unitPrice);
  print(isUrgent);
  print(sku);
}
```

**What `var` means:** the compiler works out the type from the value on the right
and then **fixes it forever**. `var sku = 'SKU-1042'` makes `sku` a `String`,
permanently. Assigning a number to it afterwards is a compile error.

**What `var` does not mean:** it is not JavaScript's `var`, it is not a variant,
and it is not `dynamic`. Dart does have a `dynamic` type that turns off type
checking, and we will not use it once on this course.

Java 10 added `var` for local variables and it means the same thing. If your team
is on Java 8, this will be new.

**The convention for this course:** write the type when it makes the code clearer
to a reader, and use `var` when the type is obvious from the line itself.

## Numbers and the types you will use daily

```dart
int quantity = 40;            // whole numbers, 64-bit
double unitPrice = 250.0;     // decimals, 64-bit
num anyNumber = 40;           // the parent of int and double
bool isUrgent = true;         // true or false only
String customer = 'Acme Ltd'; // text

print(quantity.isEven);          // true
print(quantity.toDouble());      // 40.0
print(unitPrice.round());        // 250

// Integer division and remainder
print(7 ~/ 2);    // 3   (note the tilde-slash, not just /)
print(7 / 2);     // 3.5 (a single slash always gives you a double)
print(7 % 2);     // 1

// Converting text to numbers
int? maybeQty = int.tryParse('40');     // 40, or null if it is not a number
double price = double.parse('250.0');   // throws if it is not a number
```

**There are no primitives in Dart.** `int` is a real object, so there is no `int`
versus `Integer`, no boxing, and no `NullPointerException` from unboxing a null
`Integer`. It also means you can call methods on a number directly.

> **The two division operators are the trap.** In Java, `7 / 2` with two ints
> gives you `3`. In Dart, a single slash **always** gives a double, so `7 / 2` is
> `3.5`. For integer division use `~/`. This one silently produces wrong numbers
> rather than an error.

**`num` is the parent** of `int` and `double`. You will meet it when you decode
JSON, because a JSON number could be either.

**`tryParse` versus `parse`:** `tryParse` returns `null` when the text is not a
number; `parse` throws. **For anything a user typed, use `tryParse`.**

`toStringAsFixed(2)` is how you format money. You will use it on every screen.

## Text, and string interpolation

```dart
void main() {
  // Single or double quotes. Single is the convention.
  var a = 'Acme Ltd';
  var b = "Acme Ltd";

  var sku = 'SKU-1042';
  var qty = 40;

  // A dollar sign and a variable name
  print('Ordered $qty of $sku');

  // Braces when it is an expression rather than a plain variable
  print('Total: ${qty * 250}');
  print('Upper: ${sku.toUpperCase()}');

  // Multi-line text needs no escaping and no concatenation
  var note = '''
Dear customer,
Your order has been received.
''';

  // Useful methods, mostly named the same as Java
  print(sku.length);
  print(sku.toLowerCase());
  print(sku.contains('1042'));
  print(sku.startsWith('SKU'));
  print(sku.split('-'));           // [SKU, 1042]
  print('  padded  '.trim());
  print(note);
}
```

The Java equivalent:

```java
System.out.println("Ordered " + qty + " of " + sku);
System.out.printf("Total: %d%n", qty * 250);
```

> **The common mistake:** forgetting the braces around an expression. `'$qty * 250'`
> prints `40 * 250` as literal text, because only `qty` is interpolated. Braces
> are needed for anything that is not a plain variable name.

Triple quotes give you multi-line text with no escaping and no plus signs. Java
only got text blocks in version 15.

## `final` and `const`

```dart
void main() {
  // final: assigned once. This is Java's final, and it behaves the same.
  final customer = 'Acme Ltd';
  // customer = 'Beta Co';        // ERROR: already assigned

  // final works with values only known at runtime
  final rightNow = DateTime.now();

  // const: known at COMPILE time. Java has no direct equivalent.
  const vatRate = 0.15;
  // const bad = DateTime.now();  // ERROR: not knowable at compile time

  // The compiler creates ONE object and reuses it everywhere.
  const a = [1, 2, 3];
  const b = [1, 2, 3];
  print(identical(a, b));         // true - literally the same object

  final c = [1, 2, 3];
  final d = [1, 2, 3];
  print(identical(c, d));         // false - two separate lists

  print(rightNow);
  print(vatRate);
}
```

- **`final` is exactly Java's `final`.** Assigned once, at runtime. Nothing new.
- **`const` is new.** The value must be knowable when the program is compiled,
  before it ever runs. `DateTime.now()` cannot be const. The number `0.15` can.

**The `identical` demo is the point.** Two `const` lists with the same contents
are literally the same object in memory, because the compiler created one and
reused it. Two `final` lists are two separate objects.

**Why this matters later:** a `const` widget is created once and skipped on every
rebuild. In Flutter, `const` is not a style preference; it is how you avoid
unnecessary work. The analyser will suggest it constantly.

> **The rule for this course:**
> - use `final` by default
> - use `const` whenever the compiler will let you
> - use `var` only when the value genuinely changes

*"Why not make everything const?"* Because most values are not known until the
program runs. The compiler will tell you which is which — try `const` first and
let it correct you.

## Null, and why Dart will not let you crash

In Java, every object reference can be null and the compiler does not care. That
is where `NullPointerException` comes from. **In Dart, a type cannot hold null
unless you say so.**

```dart
void main() {
  String customer = 'Acme Ltd';
  // customer = null;             // COMPILE ERROR, not a runtime crash

  // Add a question mark to allow null
  String? notes;                  // starts as null
  print(notes);                   // null

  // The compiler will not let you use it without dealing with it
  // print(notes.length);         // ERROR: notes might be null

  // 1. Check it. After the check the compiler knows it is safe.
  if (notes != null) {
    print(notes.length);          // fine, notes is a String here
  }

  // 2. Ask safely. Returns null instead of crashing.
  print(notes?.length);           // null

  // 3. Supply a fallback.
  print(notes?.length ?? 0);      // 0
}
```

**The core idea:** nullability is part of the type. `String` and `String?` are
different types and the compiler enforces the difference everywhere. It is not a
library, not an annotation, not a lint, and there is no opting out.

**Flow analysis is the part that delights people.** After `if (notes != null)`,
the compiler knows `notes` is a plain `String` for the rest of that block. No
unwrapping, no `map`, no `orElse`.

**Against `Optional`:** `Optional` is a wrapper object you construct and unwrap,
it cannot sensibly be used on fields, most codebases apply it inconsistently, and
it does not stop anyone assigning null to a plain `String`. Dart's version is the
type system itself, it costs nothing at runtime, and there is no way to opt out.

---

## LAB 1.2 · Your first Dart program · 30 min

**Goal** — a DartPad program that declares variables, formats money with
interpolation, uses `final` and `const`, handles a null, and makes a decision.

1. Open [dartpad.dev](https://dartpad.dev). Nothing is installed and nothing can
   block you.
2. Copy the starter from **Appendix A** and work down the TODOs in order.
3. **TODO 1–3:** variables for the customer, quantity and unit price, then one
   interpolated line of output.
4. **TODO 4–6:** a `final` line total, a `const` VAT rate, and the VAT and grand
   total printed.
5. **TODO 7:** a nullable `String` for delivery notes, printed with a fallback
   using `??`.
6. **TODO 8:** an `if` / `else if` / `else` chain printing bulk, standard or small.
7. Check your output against the expected output in Appendix A.
8. **When it works, break it on purpose:** remove the question mark from the notes
   type and read the error.

> **Step 8 is the actual lesson.** The compile error explains itself. Everyone
> should see it.

### Stretch

- Use `toStringAsFixed(2)` everywhere so every amount has exactly two decimals.
- Replace the `if` chain with a ternary and decide which you find more readable.
- Try to make the line total `const` instead of `final`, and explain to your
  neighbour why the compiler refuses.

---

# Module 4 · Decisions, loops and functions

**15:00 – 16:00**

By the end of this module you can:

- Use `if`, `switch` and the `??` operator to make decisions
- Loop over a range and over a collection
- Use a `List` and a `Map` for the things you would use `ArrayList` and `HashMap` for
- Write a function, including one with named parameters

## Making decisions

```dart
void main() {
  var quantity = 40;

  // if / else if / else - identical to Java
  if (quantity > 100) {
    print('bulk order');
  } else if (quantity > 10) {
    print('standard order');
  } else {
    print('small order');
  }

  // Ternary - identical to Java
  var label = quantity > 10 ? 'standard' : 'small';
  print(label);

  // Comparison and logic operators are all the same
  //   ==  !=  <  >  <=  >=  &&  ||  !

  // One Dart-only operator: ?? supplies a value when the left is null
  String? note;
  var display = note ?? 'no notes';
  print(display);

  // switch on a value. Dart does not need break on each case.
  var status = 'submitted';
  switch (status) {
    case 'draft':
      print('Still being edited');
    case 'submitted':
      print('Waiting for picking');
    default:
      print('Unknown status');
  }
}
```

**`switch` does not fall through by default**, so it does not need `break` on
every case. Anyone who has shipped a missing-`break` bug will appreciate that.

**Switch *expressions*** — the form that returns a value — come later, alongside
sealed classes, where they make more sense.

## Loops

```dart
void main() {
  // Classic for loop - identical to Java
  for (var i = 0; i < 3; i++) {
    print('line $i');
  }

  // For-each. Java: for (String s : items)
  var skus = ['SKU-1', 'SKU-2', 'SKU-3'];
  for (final sku in skus) {
    print(sku);
  }

  // while and do-while - identical to Java
  var remaining = 3;
  while (remaining > 0) {
    print('remaining $remaining');
    remaining--;
  }

  // break and continue work exactly as you expect
  for (final sku in skus) {
    if (sku == 'SKU-2') continue;
    if (sku == 'SKU-3') break;
    print('processing $sku');
  }

  // forEach with a function, if you prefer that style
  skus.forEach((sku) => print(sku));
}
```

**The only difference worth naming:** Java writes `for (String s : items)` with a
colon. Dart writes `for (final sku in skus)` with the word `in`. That is
genuinely the whole difference.

`final` in the loop variable is the convention — the variable is fresh on each
pass and never reassigned.

## Lists and Maps

```dart
void main() {
  // A List is Java's ArrayList. There is no separate array type
  // that you use day to day.
  var skus = ['SKU-1', 'SKU-2', 'SKU-3'];

  // Or declare the type explicitly
  List<String> more = ['SKU-4'];

  // An empty list needs its type, because there is nothing to infer
  var empty = <String>[];

  print(skus.length);          // 3
  print(skus[0]);              // SKU-1   (square brackets, not .get(0))
  print(skus.first);           // SKU-1
  print(skus.last);            // SKU-3
  print(skus.isEmpty);         // false
  print(skus.contains('SKU-2'));

  skus.add('SKU-9');
  skus.remove('SKU-1');
  skus.addAll(more);
  skus.sort();
  print(skus);

  // A Map is Java's HashMap
  var stock = <String, int>{
    'SKU-1': 12,
    'SKU-2': 0,
  };

  print(stock['SKU-1']);       // 12
  print(stock['SKU-9']);       // null, not an exception
  stock['SKU-3'] = 7;
  print(stock.keys);
  print(stock.length);
}
```

The four things that differ from Java:

1. **Literals.** Square brackets for a list, curly brackets for a map, right in
   the code. No `new ArrayList`, no `Arrays.asList`, no `Map.of`.
2. **Indexing uses square brackets**, not a `get` method. `skus[0]`, not
   `skus.get(0)`. Same for maps.
3. **A missing map key returns `null`**, it does not throw — same as Java's
   `HashMap`. The nullable type system now makes this visible: the type of
   `stock['SKU-9']` is `int?`, not `int`, and the compiler will hold you to it.
4. **An empty collection needs its type.** `var empty = <String>[]`. Without the
   angle brackets the compiler cannot infer anything useful.

`first` and `last` are **properties**, not methods, and they throw on an empty
list. `firstOrNull` is the safe version.

## Functions, and named parameters

```dart
// A top-level function. It does not have to live inside a class.
double lineTotal(int quantity, double unitPrice) {
  return quantity * unitPrice;
}

// If the body is a single expression, use the fat arrow.
// It means "return this". These two are identical.
double lineTotalShort(int quantity, double unitPrice) =>
    quantity * unitPrice;

// void means it returns nothing, same as Java.
void printTotal(double amount) {
  print('Total: $amount');
}

// NAMED PARAMETERS. Java has nothing like this and you will
// use them constantly once we reach widgets.
double discounted({required double amount, double rate = 0.0}) {
  return amount * (1 - rate);
}

void main() {
  print(lineTotal(40, 250));

  // At the call site you write the names. Compare this
  //   discounted(1000, 0.05)
  // with this
  print(discounted(amount: 1000, rate: 0.05));

  // rate has a default, so it can be left out entirely
  print(discounted(amount: 1000));

  printTotal(lineTotal(40, 250));
}
```

- **The fat arrow** is shorthand for a body that is a single expression, with an
  implicit return.
- **Named parameters are the headline.** Braces in the signature, and callers
  pass `name: value`. Compare `discounted(1000, 0.05)` with
  `discounted(amount: 1000, rate: 0.05)` — in the first you have to go and read
  the signature to know what `0.05` is.
- **`required` is a keyword, not an annotation.** If a parameter is required and
  the caller leaves it out, that is a compile error, not a runtime null.
- **Default values go in the signature.** In Java that needs overloads or a
  builder. Here it is one line.

> **Why this matters for the rest of the course:** once we reach widgets you will
> write constructors with eight or nine parameters. Named parameters are why that
> stays readable, and they are the reason Flutter does not need a builder pattern.

---

## LAB 1.3 · Putting the day together · 30 min

**Goal** — three functions, a `List`, a `Map`, a loop, and a formatted report
printed to the console. Everything from today, in one program.

1. Continue in the same DartPad, below your Lab 1.2 code, or start a new pad.
2. **TODO 1:** a `lineTotal` function using the fat arrow form.
3. **TODO 2:** a `withVat` function using named parameters, with a default rate
   of `0.15`.
4. **TODO 3:** a `band` function returning bulk, standard or small.
5. **TODO 4–5:** a `List` of three SKUs and a `Map` of SKU to quantity.
6. **TODO 6:** loop over the map keys and print one formatted line per SKU using
   your functions.
7. **TODO 7:** add up the quantities into a running total and print it.
8. **TODO 8:** print the band for that running total.
9. Check against the expected output in **Appendix B**.

> **One thing in this lab has not been taught yet:** the exclamation mark in
> `quantities[sku]!`. A map lookup can return null, so the type is `int?`, not
> `int`. The exclamation mark asserts "trust me, it is there". We cover when that
> is acceptable tomorrow morning.

### Stretch

- Add a second `Map` of SKU to unit price and use it instead of the hard-coded
  `250.0`.
- Print a line of dashes and a grand total row so it looks like a real report.
- Make `band` use a `switch` statement instead of `if` chains.

---

# Day 1 recap

- A mobile app is one long session in someone's pocket, on one thread, that the
  operating system can end at any moment.
- What ships is a package containing your compiled code, the Flutter engine, and
  every asset. Nothing needs to be installed first.
- Flutter draws its own pixels, which is why it looks the same on every device.
- Development uses a live virtual machine, which gives you hot reload. Release
  builds are compiled to machine code.
- Dart files need no class. `main()` is where it starts and `print()` is how you
  look at things.
- `final` is assigned once. `const` is known at compile time and shared. Prefer
  `const` wherever the compiler allows it.
- A type cannot hold null unless you add a question mark, and then the compiler
  makes you deal with it.
- Functions can be top level, the fat arrow is a one-expression body, and named
  parameters make long argument lists readable.

**Tomorrow (Day 2 · Dart Core):** classes and objects in Dart, constructors,
collections properly with `map`, `where` and `fold`, and enums.

---

## Optional reading tonight · 15 min

The Dart language tour, **the "Introduction" and "Variables" pages only** —
[dart.dev/language](https://dart.dev/language). Do not read further; the rest of
the tour covers things we do over the next few days.

Answer these as you read:

1. Find one thing on those two pages that we did not cover today, and be ready to
   say what it is for.
2. The tour describes a `dynamic` type. What is it, and why do you think we are
   not going to use it on this course?
3. Find the section on the default value of an uninitialised variable. What is
   it, and how does that interact with what we learned about null?

> This is optional. If you would rather sleep, sleep. Nothing tomorrow depends
> on it.

---

# Appendix A · Lab 1.2

### Starter

```dart
// LAB 1.2 STARTER - paste into dartpad.dev and fill in the TODOs
void main() {
  // TODO 1: create a String variable for the customer name
  // TODO 2: create an int for the quantity, and a double for unit price
  // TODO 3: print a single line: "Acme Ltd ordered 40 units at R 250.00"
  //         using string interpolation, not the plus operator
  // TODO 4: work out the line total (quantity times unit price)
  //         and store it in a final variable
  // TODO 5: create a const for the VAT rate of 0.15
  // TODO 6: print the VAT amount and the total including VAT
  // TODO 7: create a nullable String for delivery notes, leave it null,
  //         and print "Notes: none" using the ?? operator
  // TODO 8: use an if / else if / else to print
  //           "bulk"     when quantity is over 100
  //           "standard" when quantity is over 10
  //           "small"    otherwise
}
```

### Solution

```dart
void main() {
  var customer = 'Acme Ltd';
  var quantity = 40;
  var unitPrice = 250.0;

  print('$customer ordered $quantity units at R ${unitPrice.toStringAsFixed(2)}');

  final lineTotal = quantity * unitPrice;
  const vatRate = 0.15;
  final vat = lineTotal * vatRate;
  final total = lineTotal + vat;

  print('Line total  R ${lineTotal.toStringAsFixed(2)}');
  print('VAT         R ${vat.toStringAsFixed(2)}');
  print('Total       R ${total.toStringAsFixed(2)}');

  String? notes;
  print('Notes: ${notes ?? 'none'}');

  if (quantity > 100) {
    print('bulk');
  } else if (quantity > 10) {
    print('standard');
  } else {
    print('small');
  }
}
```

### Expected output

```
Acme Ltd ordered 40 units at R 250.00
Line total  R 10000.00
VAT         R 1500.00
Total       R 11500.00
Notes: none
standard
```

---

# Appendix B · Lab 1.3

### Starter

```dart
// LAB 1.3 STARTER - continue in the same DartPad

// TODO 1: write a function
//           double lineTotal(int quantity, double unitPrice)
//         using the fat arrow form

// TODO 2: write a function with named parameters
//           double withVat({required double amount, double rate = 0.15})
//         that returns the amount plus VAT

// TODO 3: write a function
//           String band(int quantity)
//         returning 'bulk', 'standard' or 'small'

void main() {
  // TODO 4: make a List<String> of three SKUs
  // TODO 5: make a Map<String, int> of SKU to quantity, three entries
  // TODO 6: loop over the map's keys with for-in and print
  //         "SKU-1 x 40 = R 10000.00" for each, using your functions
  //         (assume every unit price is 250.0)
  // TODO 7: add up all the quantities into a running total and print it
  // TODO 8: print the band for the running total
}
```

### Solution

```dart
double lineTotal(int quantity, double unitPrice) => quantity * unitPrice;

double withVat({required double amount, double rate = 0.15}) =>
    amount * (1 + rate);

String band(int quantity) {
  if (quantity > 100) return 'bulk';
  if (quantity > 10) return 'standard';
  return 'small';
}

void main() {
  var skus = ['SKU-1', 'SKU-2', 'SKU-3'];
  var quantities = <String, int>{
    'SKU-1': 40,
    'SKU-2': 10,
    'SKU-3': 5,
  };
  const unitPrice = 250.0;
  var runningTotal = 0;

  for (final sku in quantities.keys) {
    final qty = quantities[sku]!;
    final total = lineTotal(qty, unitPrice);
    print('$sku x $qty = R ${total.toStringAsFixed(2)}');
    runningTotal = runningTotal + qty;
  }

  print('Units total  $runningTotal');
  print('With VAT     R ${withVat(amount: lineTotal(runningTotal, unitPrice)).toStringAsFixed(2)}');
  print('Band         ${band(runningTotal)}');
  print(skus);
}
```

### Expected output

```
SKU-1 x 40 = R 10000.00
SKU-2 x 10 = R 2500.00
SKU-3 x 5 = R 1250.00
Units total  55
With VAT     R 15812.50
Band         standard
[SKU-1, SKU-2, SKU-3]
```

> Note the exclamation mark in `quantities[sku]!`. A map lookup returns a
> nullable type, and that mark asserts the value is present.

---

# Appendix C · Commands used today

Identical on Windows and macOS:

```bash
flutter doctor
flutter doctor -v
flutter devices
flutter create --org com.example order_flow
flutter run
flutter analyze
dart fix --apply
dart format .
flutter clean
flutter pub get
```

Only the install commands differ between the two operating systems.

---

# Appendix D · Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `flutter is not recognised` | Old terminal window | Close it and open a new one |
| `The token '&&' is not a valid statement separator` | PowerShell 5.1 | One command per line |
| `cmdline-tools component is missing` | SDK Tools not installed | Android Studio → SDK Manager → SDK Tools tab → tick it → Apply |
| `Android license status unknown` | Known detection bug | Cosmetic. Prove it with `flutter build apk --debug` |
| `No devices available` | No emulator or phone | Start an emulator, or `flutter run -d chrome` |
| Emulator extremely slow (Windows) | No hardware acceleration | Enable virtualisation in the BIOS, or use a phone |
| Hot reload changes nothing | Changed `main`, or a compile error | Press `R` for a restart, and read the terminal |
| `A value of type Null can't be assigned` | Assigning null to a non-nullable type | Add a `?` to the type, or give it a real value |
| `The property ... can't be unconditionally accessed` | Using a nullable value without a check | Use `?.` or `??`, or check with an `if` first |
| `Invalid constant value` | Runtime value in a `const` | Use `final` instead |
| `Expected to find ';'` | Missing semicolon, usually a line earlier | Look at the line **above** the one reported |
| `7 / 2` gives `3.5` not `3` | A single slash always returns a double | Use `~/` for integer division |
| Undefined name in DartPad | Typo, or the variable is out of scope | Dart is case sensitive. Check the spelling exactly |

---

# Appendix E · Links

| Topic | Link |
|---|---|
| Install Flutter | https://docs.flutter.dev/get-started/install |
| DartPad, the online editor | https://dartpad.dev |
| Dart language tour | https://dart.dev/language |
| Variables | https://dart.dev/language/variables |
| Understanding null safety | https://dart.dev/null-safety/understanding-null-safety |
| Built-in types | https://dart.dev/language/built-in-types |
| Functions | https://dart.dev/language/functions |
| Android Studio | https://developer.android.com/studio |
| Set up an emulator | https://developer.android.com/studio/run/managing-avds |
| Architecture, for the curious | https://docs.flutter.dev/resources/architectural-overview |
