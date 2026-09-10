// Exercise 15: Cannot reach the quote service
//
// `localhost` inside the Android emulator IS the emulator, not your machine.
// The host is reachable at the special address 10.0.2.2.
//
//   Android emulator   http://10.0.2.2:8080
//   iOS simulator      http://localhost:8080     (shares the host network)
//   Chrome             http://localhost:8080
//   Physical phone     http://<your LAN IP>:8080 (same Wi-Fi)
//
// Never hard-code an environment URL. Keep the emulator default and override
// per platform at launch:
//   flutter run --dart-define=API_URL=http://localhost:8080

const apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080',   // was http://localhost:8080
);
