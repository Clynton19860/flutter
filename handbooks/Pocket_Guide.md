# Flutter Pocket Guide

Keep this one. Everything from a blank machine to a signed build in the store,
plus every error we hit during the week and what fixed it.

MO Integrations · Flutter Mobile Application Development

---

## 1 · Commands you will use every day

```
flutter doctor -v            # what is broken about my setup
flutter pub get              # fetch dependencies (after every pubspec edit)
flutter run                  # build and launch, hot reload attached
flutter analyze              # static analysis - keep this clean
flutter test                 # unit + widget tests
flutter clean                # nuke build artefacts when it makes no sense
```

Less often, but worth knowing:

```
flutter devices              # what can I run on
flutter emulators            # list emulators
flutter emulators --launch <id>
flutter pub add <package>    # add a dependency and pub get in one step
flutter pub outdated         # what could be upgraded
flutter upgrade              # upgrade the SDK itself
dart format .                # format everything
dart fix --apply             # auto-fix what the analyser can fix
```

Code generation (Day 4 onwards):

```
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs
```

**Always pass `--delete-conflicting-outputs`.** Without it you get
*"Found 1 declared output which already exists on disk"* and a prompt.

---

## 2 · Keyboard shortcuts

### In the terminal, while `flutter run` is attached

| Key | Does | Use when |
|---|---|---|
| `r` | Hot **reload** | You changed a widget's `build` |
| `R` | Hot **restart** | You changed `main()`, an initialiser, a `const`, an enum, or added a package |
| `q` | Quit | |
| `p` | Toggle the layout debug overlay | Hunting an overflow |
| `o` | Toggle platform (Android ↔ iOS look) | |
| `v` | Open DevTools in the browser | |
| `c` | Clear the screen | |

**The single most common false alarm all week:** "hot reload did nothing."
It almost always means the change needs a hot **restart**. Press `R`.

And after adding any package with native code — `sqflite`, `shared_preferences`,
`path_provider` — a reload *and* a restart are not enough. **Stop the app and
`flutter run` again**, or you get `MissingPluginException`.

### VS Code

| Shortcut | Does |
|---|---|
| `F5` | Run and attach the debugger |
| `Ctrl/Cmd + F5` | Run without debugging |
| `Shift + F5` | Stop |
| `Ctrl/Cmd + Shift + F5` | Hot restart |
| `Ctrl/Cmd + S` | Save — hot reloads automatically with our settings |
| `Ctrl/Cmd + .` | Quick fix — **wrap with Widget, wrap with Padding, remove widget** |
| `Ctrl/Cmd + Shift + P` → "Flutter" | Every Flutter command |
| `F2` | Rename symbol across the project |
| `Alt/Option + Shift + F` | Format document |
| `Ctrl/Cmd + Click` | Jump to definition — use it on Flutter's own source |

`Ctrl/Cmd + .` on a widget is the one that saves the most time. It writes the
`Expanded`, `Padding` or `Column` wrapper for you with correct indentation.

### The emulator

| Shortcut | Does |
|---|---|
| `Ctrl + Left/Right` (Win), `Cmd + Left/Right` (mac) | Rotate |
| `Ctrl/Cmd + M` | Open the Android dev menu |
| `Cmd + K` (mac), `Ctrl + K` (Win) | Toggle the software keyboard |

---

## 3 · From a blank machine to a running app

1. Install the **Flutter SDK**. Unzip it to a path with **no spaces**
   (`~/development/flutter`, `C:\src\flutter`). Add `<sdk>/bin` to PATH.
2. Open a **new** terminal. `flutter --version` must work.
3. Install **Android Studio**. In SDK Manager → SDK Tools, tick
   **Command-line Tools (latest)**.
4. `flutter doctor -v`. Work down the list until only the things you do not
   need are red.
5. `flutter doctor --android-licenses` → accept everything.
6. Create an emulator in Device Manager, or plug in a phone with USB debugging on.
7. `flutter create my_app && cd my_app && flutter run`.

**First build downloads about 4 GB** — NDK, SDK platform, Gradle. It is not
hung. Later builds are seconds.

**macOS extras for iOS:** install Xcode from the App Store first — the iOS
Simulator lives inside it and it is a ~10 GB download. Then let the script do
the rest:

```
./setup/setup_ios_simulator.sh --check     # report only, changes nothing
./setup/setup_ios_simulator.sh             # switch, licence, runtime, boot
```

It handles `xcode-select --switch`, the licence, `-runFirstLaunch`, downloading
the iOS runtime, CocoaPods, creating and booting a device, and verifies with
`flutter doctor`. Safe to run more than once.

---

## 4 · Gotchas, by symptom

### Setup and tooling

| Symptom | Fix |
|---|---|
| `flutter` not recognised | Open a **new** terminal. No spaces in the SDK path |
| `cmdline-tools component is missing` | SDK Manager → SDK Tools → Command-line Tools (latest) |
| `Android license status unknown` | `flutter doctor --android-licenses`. With tools 23.0+ this warning is cosmetic — prove it with `flutter build apk --debug` |
| `Multiple adb binaries found` | Remove the duplicate, keep Android Studio's |
| Emulator stuck on the boot logo | No hardware acceleration. Enable WHPX/Hypervisor + BIOS virtualisation, or use a phone or Chrome |
| `adb devices` empty (Windows) | OEM USB driver missing, or a charge-only cable |
| `Unsupported class file major version` | `flutter config --jdk-dir "C:\Program Files\Android\Android Studio\jbr"` |
| `Filename too long` (git, Windows) | `git config --system core.longpaths true` |
| Build broken for no reason | `flutter clean` then `flutter pub get` |

### Layout

| Symptom | Fix |
|---|---|
| Yellow/black stripes, `RenderFlex overflowed` | Wrap the child in `Expanded`/`Flexible`, or the flex in `SingleChildScrollView` |
| `Vertical viewport was given unbounded height` | `Expanded(child: ListView(...))`. `shrinkWrap: true` only for tiny lists |
| `Incorrect use of ParentDataWidget` | `Expanded` must be **directly** inside a `Row`/`Column` |
| `BoxConstraints forces an infinite width` | `TextField` in a `Row` → `Expanded(child: TextField())` |
| Container invisible | Loose parent, no child, no size — give it one |
| Stack has zero size | Give it a sized child, or `fit: StackFit.expand` |
| Keyboard covers the button | `SingleChildScrollView` around the form |
| No ripple on `InkWell` | Needs a `Material` ancestor |

### Forms and state

| Symptom | Fix |
|---|---|
| `Unable to load asset` | Two-space indent under `flutter:`, `flutter pub get`, hot **restart** |
| `A TextEditingController was used after being disposed` | Create it as a State field, not in `build()` |
| `setState() called after dispose()` | `if (!mounted) return;` after every `await` |
| `Form.of()` cannot find the Form | Give the `Form` a `GlobalKey<FormState>` |
| `controller` and `initialValue` together | Pick one. The controller wins |

### Riverpod

| Symptom | Fix |
|---|---|
| `No ProviderScope found` | Wrap `runApp` in `ProviderScope`, then hot **restart** |
| **Widget never updates, no error at all** | `ref.read` in `build`. Use `ref.watch` |
| **State assigned but nothing rebuilds** | You mutated in place. Assign a new value: `state = [...state, x]` |
| `Undefined name 'ref'` | Needs `ConsumerWidget`, or `ConsumerStatefulWidget` + `ConsumerState` |
| `The switch expression isn't exhaustive` | Add the missing case. This is the feature working |
| Spinner never stops | An exception escaped the `try`. Await **inside** it |
| A provider silently re-runs after an error | Riverpod 3 auto-retry. `ProviderScope(retry: (c, e) => null)` while learning |
| `StateProvider isn't defined` | `import 'package:flutter_riverpod/legacy.dart';` |
| SnackBar fires twice | Call `ref.listen` once, at the top of `build` |

### Navigation

| Symptom | Fix |
|---|---|
| `No GoRouter found in context` | The call is above `MaterialApp.router`. Move it below, or use `ref` |
| Redirect loop | Guard with `state.matchedLocation` |
| **Onboarding never finishes** | Two files each declare the provider. Keep **one** declaration, fix both imports |
| Back returns to onboarding | You used `push`. Let the redirect `go` |
| Deep link does nothing | Manifest changed — stop and `flutter run`, a restart is not enough |
| Deep link opens the wrong route | Three slashes: `quoteapp:///quote/...` |

### Network and JSON

| Symptom | Fix |
|---|---|
| `Connection refused` / "Cannot reach the service" | Server not running, or `localhost` on Android. Use **`10.0.2.2`** |
| `Cleartext HTTP traffic not permitted` | Add `usesCleartextTraffic`, then a full restart |
| **A list from the API is always empty** | Field name ≠ JSON key. `@JsonKey(name: 'the_real_key')`, then regenerate |
| `Found 1 declared output which already exists` | Pass `--delete-conflicting-outputs` |
| `Target of URI hasn't been generated` | Run the generator |
| `_$XFromJson isn't defined` | The `part` directive does not match the file name |
| Crash on a JSON number | `1` parses as `int`. Use `(json['x'] as num).toDouble()` |

**Where the host machine lives:**

| Running on | Base URL |
|---|---|
| Android emulator | `http://10.0.2.2:8080` |
| iOS simulator, Chrome | `http://localhost:8080` |
| Physical phone | `http://<laptop LAN IP>:8080`, same Wi-Fi |

### Storage

| Symptom | Fix |
|---|---|
| `MissingPluginException` | Native plugin added — **stop and `flutter run`** |
| `MissingPluginException` in Chrome | `sqflite` is mobile-only. Use an in-memory repository on web |
| `UnimplementedError` | A provider override is missing from `main` |
| Saved list does not refresh | Missing `ref.invalidateSelf()` after the write |
| Onboarding shows every launch | `setBool` not awaited, or the wrong key |
| **`Looking up a deactivated widget's ancestor is unsafe`** | `if (!context.mounted) return;` after **every** await |

### Tests

| Symptom | Fix |
|---|---|
| `pumpAndSettle` times out | An infinite animation. Use `pump(Duration(...))` |
| `No MaterialLocalizations found` | Wrap the widget under test in `MaterialApp(home: Scaffold(...))` |
| `registerFallbackValue` error | `setUpAll(() => registerFallbackValue(FakeX()))` |
| `A ProviderContainer was not disposed` | `addTearDown(container.dispose)` |
| `No tests ran` | File must end `_test.dart` and live under `test/` |

---

## 5 · Release: signing to store

### Step 1 — create the upload keystore

**One keystore per company, not per app.** Back it up. Keep the `.jks`
**outside** the repo, and never commit it.

macOS:
```
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

Windows (PowerShell):
```
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -keyalg RSA `
  -keysize 2048 -validity 10000 -alias upload
```

If `keytool` is not on PATH it ships with Android Studio's JDK:
`/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool`
or `C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe`.

### Step 2 — wire it up

`android/key.properties` — **add this file to `.gitignore`**:

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

Windows paths need `C:\\Users\\...` or forward slashes.

### Step 3 — build

```
flutter build appbundle --obfuscate --split-debug-info=build/symbols
# → build/app/outputs/bundle/release/app-release.aab

flutter build apk --split-per-abi      # for testers, not the store
```

Verify what you built:
```
apksigner verify --print-certs app.apk
```

**Versioning** lives in `pubspec.yaml` as `version: 1.0.0+1` — name plus build
number. **Bump the build number on every single upload** or the store rejects it.
Override at build time with `--build-name=1.0.1 --build-number=2`.

### Step 4 — Google Play

| # | Do | Gotcha |
|---|---|---|
| 1 | Create app: name, language, free/paid | **Free can never become paid** |
| 2 | Privacy policy URL, app access, ads, content rating, target audience, data safety | Insurance → declare financial features. Data safety must match what you actually collect |
| 3 | Store listing: icon 512², feature graphic 1024×500, 2–8 screenshots | Screenshots per brand, from the flavour builds |
| 4 | Internal testing → upload `.aab` → release notes → testers | Live in minutes, up to 100 testers |
| 5 | Accept Play App Signing | Google holds the signing key, you keep the upload key |
| 6 | Promote internal → closed → open → production | First production review: hours to a few days |
| 7 | Every update: bump the build number | Package name is **forever** |

### Step 5 — App Store

| # | Do | Gotcha |
|---|---|---|
| 1 | Enrol in the Apple Developer Program as an organisation | Needs a D-U-N-S number, **1–2 weeks** — start early |
| 2 | App ID + capabilities; let Xcode manage signing | One provisioning profile per bundle id |
| 3 | App Store Connect → New App | The name must be unique store-wide |
| 4 | `flutter build ipa` → Xcode Organizer → Distribute | **Mac only**, or use Codemagic from a Git push |
| 5 | TestFlight | Processing takes 10–30 min |
| 6 | Privacy questionnaire, age rating, screenshots 6.7" + 6.5", demo account | **Missing purpose strings in `Info.plist` = instant rejection** |
| 7 | Submit; answer in Resolution Center | 24–72 h typically; resubmits are faster |

### Release gotchas

| Symptom | Fix |
|---|---|
| `You must specify a --flavor` | Flavours are defined — add `--flavor alpha` |
| `Keystore file not found` | Use an absolute path; escape Windows backslashes |
| **Release crashes, debug is fine** | Minify stripped a class. Add keep rules to `proguard-rules.pro`, or set `isMinifyEnabled = false` to confirm |
| CI: `flutter: command not found` | Add the Flutter setup action before any flutter step |
| Store rejects the upload | Build number not bumped |

---

## 6 · Rules worth memorising

1. **watch in build, read in callbacks, listen for side effects.**
2. **Assign new state, never mutate it.** `state = [...state, x]`
3. **`if (!context.mounted) return;` after every await.**
4. **Hot reload for `build`, hot restart for everything else, full stop-and-run for native plugins.**
5. **`10.0.2.2` is your laptop, from inside the Android emulator.**
6. **Bump the build number on every upload.**
7. **The keystore never goes in the repo, and losing it is a very bad day.**

---

## 7 · Links

| Topic | Link |
|---|---|
| Layout constraints | docs.flutter.dev/ui/layout/constraints |
| Widget catalogue | docs.flutter.dev/ui/widgets |
| State management intro | docs.flutter.dev/data-and-backend/state-mgmt/intro |
| Riverpod | riverpod.dev |
| go_router | pub.dev/packages/go_router |
| dio | pub.dev/packages/dio |
| Testing | docs.flutter.dev/testing |
| Android release | docs.flutter.dev/deployment/android |
| iOS release | docs.flutter.dev/deployment/ios |
| Play Console | play.google.com/console |
| App Store Connect | appstoreconnect.apple.com |
