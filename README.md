# MO Integrations · Flutter Mobile Application Development

Five-day technical training. Delegate handbooks, slides, exercises and the
lab application.

## What is where

| Folder | What's in it |
|---|---|
| `handbooks/` | `Day1`–`Day5_Handbook.md`. The delegate handbook for each day. Open alongside the course and copy code straight out. |
| `slides/` | The presenter deck for each day, `Day1`–`Day5`. Speaker notes are in each deck. |
| `exercises/` | Eighteen find-the-bug exercises. 1–10 run in DartPad; 11–18 run in the app. |
| `solutions/` | Worked answers to all eighteen exercises, plus the labs that were demonstrated rather than typed (1.2, 2.1, 3.1, 4.1, 4.2). Try it yourself first — then check. |
| `dartpad/` | Ready-to-paste DartPad files for the Day 1 labs. |
| `setup/` | `START_HERE` install guides and the VS Code config. Do this before Day 1. |
| `handouts-pdf/` | PDF exports for printing and emailing. |
| `full-flutter-and-dart-training/` | A separate, longer course: **Flutter for Java Developers**, 8 days. Its own handbooks and decks, four days of Dart before any Flutter. Not part of the 5-day programme above. |

## The lab app

The app is **not in this branch.** It lives on the `lab-*` branches:

```
lab-3-start        End of Day 2. Where delegates begin Day 3.
lab-3-1-solution   Brand toggle moved to a Riverpod provider.
lab-3-2-solution   Quote flow through QuoteNotifier, idle/loading/loaded/failed.
lab-4-1-solution   go_router, onboarding guard, result screen.
lab-4-2-solution   Real quote API with dio.
lab-4-3-solution   Onboarding to capture to API to result to saved. End of Day 4.
```

Work on the app in a **separate clone**, so switching branches never fights
the materials:

```
git clone <this repo> flutter-labs
cd flutter-labs
git checkout lab-3-start
cd quote_app && flutter pub get && flutter run
```

Keep this clone on the materials branches (`main`, `day*-materials`) and the
other one on `lab-*`. `quote_app/` is gitignored here for that reason.

## Running the app

```
cd quote_app
flutter pub get
flutter run
flutter analyze
flutter test
```

Day 4 onwards needs the mock API in a second terminal:

```
dart run tool/mock_server.dart
```

Android emulator reaches it at `10.0.2.2:8080` (the default). For Chrome or
the iOS simulator:

```
flutter run --dart-define=API_URL=http://localhost:8080
```

## Course shape

| Day | Subject | Deck |
|---|---|---|
| 1 | Foundations and Dart | `slides/Day1_Foundations_and_Dart.pptx` |
| 2 | Widgets and layout | `slides/Day2_Widgets_and_Layout.pptx` |
| 3 | State management | `slides/Day3_State_Management.pptx` |
| 4 | Data, APIs and navigation | `slides/Day4_Data_APIs_Navigation.pptx` |
| 5 | Testing, CI/CD and shipping | `slides/Day5_Testing_CICD_Shipping.pptx` |
