# Day 5 — Ship It: Deploying to Google Play

**The rule: build it as if it were going to production. Release it to internal testing only.**

Nothing goes public. But every step a real production release needs still gets done —
because the point of the exercise is the checklist, not the button at the end.

---

## 1. App identity — it is not `quote_app` any more

| What | File | Currently | Change to |
|---|---|---|---|
| Application ID | `android/app/build.gradle.kts` | `com.mointegrations.quote_app` | `com.mointegrations.quote_app.<yourname>` |
| Display name | `android/app/src/main/AndroidManifest.xml` | `android:label="quote_app"` | A real name — `Eliva Quote` |
| Version | `pubspec.yaml` | `version: 1.0.0+1` | Bump the `+N` on **every** upload |
| Launcher icon | default Flutter icon | — | Replace it (`flutter_launcher_icons`) |

> An Application ID is permanent and globally unique across all of Google Play.
> One per delegate — if two of you upload the same ID, the second one is rejected.

---

## 2. Signing — the one thing that blocks a release build

Right now `build.gradle.kts` signs release builds with the **debug** key. Play rejects that.

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties`:

```properties
storePassword=<your password>
keyPassword=<your password>
keyAlias=upload
storeFile=/Users/<you>/upload-keystore.jks
```

Wire it into `android/app/build.gradle.kts` — at the top of the file:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

…then inside `android { }`, replacing the debug-signing TODO:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

**Never commit a keystore.** `key.properties`, `*.jks` and `*.keystore` are already in
`android/.gitignore` — confirm with `git status` that none of them appear before you push.
Lose this file and you can never update the app again.

---

## 3. Build it

All three must be clean, in this order:

```bash
flutter analyze                    # No issues found!
flutter test                       # All tests passed!
flutter build appbundle --release  # → build/app/outputs/bundle/release/app-release.aab
```

An `.aab` (App Bundle), not an `.apk`. Play has not accepted APKs for new apps since 2021.

---

## 4. Play Console — do the whole production checklist

Create the app, then complete **every** item under **App content**. This is the part that
takes the time, and it is the part that is genuinely production work:

- Privacy policy URL — a real, reachable page
- Data safety — what you collect, why, whether it is shared
- Content rating — the full questionnaire
- Target audience and content
- Ads declaration
- Government apps / financial features / health declarations

And the **Store listing**:

- Short description (80 chars) and full description (4000)
- App icon — 512×512 PNG
- Feature graphic — 1024×500
- At least 2 phone screenshots

---

## 5. Release — Internal testing, and nothing else

```
Testing → Internal testing → Create new release
  → upload app-release.aab
  → add tester email addresses
  → Review release → Start rollout
```

Testers get an opt-in link, accept it, and install from the real Play Store.

> **Do not touch Production, Open testing, or Closed testing.**
> Internal testing is invisible to the public and needs no review wait.

---

## You are done when

- [ ] `flutter analyze` and `flutter test` are both clean
- [ ] The AAB is signed with **your** upload key, not the debug key
- [ ] Application ID and app name are yours, and the icon is not the Flutter default
- [ ] Every **App content** section shows green
- [ ] The app is installed from the Play Store on a real phone
- [ ] The **Production** track is still empty
