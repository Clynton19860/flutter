# 15 · Cannot reach the quote service

**Day 4 · APIs.** Run in your `quote_app`, with the mock server running:
`dart run tool/mock_server.dart`

```dart
const apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8080',      // <-- here
);
```

## What you should see

On the Android emulator, every Get quote ends in the SnackBar
**"Cannot reach the quote service."** The mock server is running. `curl
http://localhost:8080/health` on your laptop returns `{"status":"ok"}`. The
server log shows no request arriving at all.

## Clue

The app is not running on your laptop. It is running inside a virtual device
that has its own idea of what `localhost` means.

## Why it matters

`localhost` inside the Android emulator is the emulator. Your machine is
`10.0.2.2`. The iOS simulator shares the host network, so `localhost` is correct
there — which is why this bug looks like "works on Mac, broken on Windows" and
sends people hunting for a firewall.

| Running on | Base URL |
|---|---|
| Android emulator | `http://10.0.2.2:8080` |
| iOS simulator, Chrome | `http://localhost:8080` |
| Physical phone | `http://<your LAN IP>:8080` |

---

Solution: `solutions/exercise_15.dart`
