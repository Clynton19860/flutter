# quote_app

The app built across the MO Integrations Flutter training week.

| Branch | State of this app |
|---|---|
| `lab-3-start` / `lab-3-1-start` | End of Day 2: brand key in `_QuoteAppState`, threaded down as `brand` + `onSwitchBrand`. Validated capture form, premium in a SnackBar. |
| `lab-3-1-solution` | Lab 3.1: brand key moved to a Riverpod `NotifierProvider`. No brand parameters, no callbacks. |
| `lab-3-2-solution` | Lab 3.2: the whole quote flow through `QuoteNotifier` — idle / loading / loaded / failed — with `QuoteService` injected and a passing unit test. |

```
flutter pub get
flutter run
flutter analyze
flutter test
```

Handbooks and exercises are on `main`.
