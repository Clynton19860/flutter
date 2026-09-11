# VS Code config for `quote_app`

Three files that make the lab project run the same way on every machine.

## Install

Copy this folder into your `quote_app` project and rename it `.vscode`:

**Windows (PowerShell), from inside `quote_app`:**

```
xcopy /E /I ..\flutter\setup\vscode-config .vscode
```

**macOS, from inside `quote_app`:**

```
cp -R ../flutter/setup/vscode-config .vscode
```

Reload VS Code afterwards, or close and reopen the folder.

## What each file does

| File | Does |
|---|---|
| `launch.json` | Two run targets: the Android emulator, and Chrome as a fallback |
| `tasks.json` | Lists your emulators and starts one, without leaving VS Code |
| `settings.json` | Format on save, 100 character line length, UI guides, DevTools on run |

## Running the app

Press **F5**. The dropdown at the top picks the target.

**quote_app (Android emulator)** forces an Android emulator and will not
silently fall back to Chrome or to a phone. It matches any device whose id
starts with `emulator`, so it works whatever port your emulator lands on.

**quote_app (Chrome fallback)** runs the same code in the browser with hot
reload working normally. Use it if your Android build is not ready. Every lab
this week works in Chrome.

## Start the emulator first

The emulator has to be running before F5 finds it. Either start it from Android
Studio, or from VS Code:

**Terminal → Run Task → List emulators** to get your AVD id, then
**Terminal → Run Task → Start Android emulator** and paste that id in.

First boot takes one to three minutes. Leave it running for the rest of the day.

## If F5 says no devices

Run `flutter devices`. If nothing Android is listed, the emulator is not up yet.
Start it, wait for the home screen, then press F5 again.
