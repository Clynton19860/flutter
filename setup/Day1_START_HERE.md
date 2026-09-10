# START HERE

**Flutter Day 1** · Please work down this page before we begin. Do not wait for the instructor.

Your first Flutter build downloads about **4 GB** and takes several minutes. The sooner you start it, the smoother your day. Everything this morning runs in a web browser, so **nothing here can hold you back**: if you get stuck, raise your hand and carry on to the last section.

---

## Step 1: Which lane are you in?

Open **PowerShell**: press the Windows key, type `powershell`, press Enter.

Type this and press Enter:

```
flutter --version
```

Then this:

```
flutter doctor
```

Look at what came back and pick your lane below.

| What you saw | Your lane |
|---|---|
| A version number, and doctor shows a tick next to Android toolchain | **Lane A** |
| A version number, but Android toolchain has an X or is missing | **Lane B** |
| `flutter` is not recognised | **Lane C** |

---

## LANE A: you are ready. Start the build now.

```
cd $HOME
```

```
flutter create --org za.co.moint quote_app
```

```
cd quote_app
```

```
flutter build apk --debug
```

Leave that running. It will take five to ten minutes. Go to **Everyone** at the bottom of the page.

---

## LANE B: Flutter is installed, Android is not.

Start this download first, then come back:

Open a browser and go to **https://developer.android.com/studio** and start the Android Studio download.

While it downloads, go to **Everyone** at the bottom of this page.

When the download finishes, install it, run the setup wizard and choose **Standard**. Then tell the instructor you have reached this point.

---

## LANE C: nothing installed yet.

Start **both** of these downloads now, in a browser. Do not wait for one to finish before starting the other.

1. **https://docs.flutter.dev/get-started/install/windows**: download the Flutter SDK zip
2. **https://developer.android.com/studio**: download Android Studio

While they download, go to **Everyone** at the bottom of this page.

When the Flutter zip has finished downloading, extract it to `C:\src\flutter` so that you end up with a folder called `C:\src\flutter\bin`.

Then open PowerShell and run this:

```
$u = [Environment]::GetEnvironmentVariable("Path", "User")
```

```
[Environment]::SetEnvironmentVariable("Path", "$u;C:\src\flutter\bin", "User")
```

Close PowerShell. Open a **new** PowerShell. Then:

```
flutter --version
```

---

## EVERYONE: do this while things download

Open a browser tab at:

**https://dartpad.dev**

That is where this morning's exercises run. It needs no installation and works on any machine.

Leave that tab open. We start at **09:00**.

---

## Before you sit back

Fill this in and leave it on the table. It tells the instructor where the room is without asking twenty people one at a time.

**Name:** ______________________________________

**Lane (circle one):**  A   ·   B   ·   C

**Your main language day to day (circle):**  C#  ·  TypeScript / JavaScript  ·  Java  ·  Other: ____________

**Front end you use (circle):**  React  ·  Angular  ·  Blazor  ·  None / Other: ____________

**Have you written any Flutter before? (circle):**  Never  ·  Tried a tutorial  ·  Built something real

---

## If something goes wrong

| What you see | What to do |
|---|---|
| `flutter` is not recognised, but you installed it | Close PowerShell, open a **new** one, try again |
| `cmdline-tools component is missing` | Leave it. The instructor covers this in the first hour |
| `Android license status unknown` | Leave it. It is a known Flutter bug, not your machine |
| Anything else | Raise your hand, then carry on to **dartpad.dev** |

**Nothing on this page can stop you taking part this morning.** All of today's first exercises run in the browser.

---

*MO Integrations · Flutter Mobile Application Development · Day 1*
