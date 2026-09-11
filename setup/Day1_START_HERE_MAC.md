# START HERE · macOS

**Flutter Day 1** · Please work down this page before we begin. Do not wait for the instructor.

Your first Flutter build downloads about **4 GB** and takes several minutes. The sooner you start it, the smoother your day. Everything this morning runs in a web browser, so **nothing here can hold you back**: if you get stuck, raise your hand and carry on to the last section.

> **On a Windows machine?** Use the other sheet, `Day1_START_HERE.md`. This one is macOS only.

---

## Step 0: which Mac are you on?

Open **Terminal**: press `Cmd + Space`, type `terminal`, press Enter.

```
uname -m
```

| It printed | You have | Download the zip marked |
|---|---|---|
| `arm64` | Apple Silicon (M1-M4) | **Apple silicon** |
| `x86_64` | Intel | **Intel** |

Remember which. You need it twice below.

---

## Step 1: Which lane are you in?

In the same Terminal window, type this and press Enter:

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
| A version number, and doctor shows an **Android SDK version** on the Android toolchain line | **Lane A** |
| A version number, but **no Android toolchain line at all**, or it cannot find an SDK | **Lane B** |
| `zsh: command not found: flutter` | **Lane C** |

> ### Two things in `flutter doctor` that you must ignore today
>
> **1. A red ✗ next to `Android license status unknown`.** This is a known bug in current
> Android tooling, not a problem with your machine. If you run the licences command it
> replies *"The --licenses option is no longer needed."* Your licences are fine.
> **A licence ✗ still means Lane A.**
>
> **2. Anything about `Xcode` or `CocoaPods`.** This course builds for Android and the
> browser. **Do not install Xcode today**: it is a ~10 GB download that will flatten the
> venue network for everyone else. Ignore that section completely.

---

## LANE A: you are ready. Start the build now.

```
cd ~
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

When it finishes you want a line saying it built `app-debug.apk`. That is the real proof your setup works, better proof than `flutter doctor`.

---

## LANE B: Flutter is installed, Android is not.

Start this download first, then come back:

Open a browser and go to **https://developer.android.com/studio** and start the Android Studio download. Pick the build that matches **Step 0**: Apple silicon or Intel.

While it downloads, go to **Everyone** at the bottom of this page.

When the download finishes, drag it to Applications, run it, and choose the **Standard** setup. Then tell the instructor you have reached this point.

---

## LANE C: nothing installed yet.

Start **both** of these downloads now, in a browser. Do not wait for one to finish before starting the other.

1. **https://docs.flutter.dev/get-started/install/macos**: the Flutter SDK zip, matching Step 0
2. **https://developer.android.com/studio**: Android Studio, matching Step 0

While they download, go to **Everyone** at the bottom of this page.

### When the Flutter zip has finished

```
mkdir -p ~/development
```

```
cd ~/development
```

```
unzip ~/Downloads/flutter_macos_*-stable.zip
```

You should now have a folder at `~/development/flutter/bin`. Check it:

```
ls ~/development/flutter/bin
```

Now add it to your PATH:

```
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
```

Close Terminal completely (`Cmd + Q`). Open a **new** Terminal. Then:

```
flutter --version
```

> **Already have Homebrew?** You can skip the whole zip dance with
> `brew install --cask flutter`: it puts Flutter on your PATH for you.
> Use one method or the other, not both.

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

**Mac (circle one):**  Apple Silicon   ·   Intel

**Your main language day to day (circle):**  C#  ·  TypeScript / JavaScript  ·  Java  ·  Other: ____________

**Front end you use (circle):**  React  ·  Angular  ·  Blazor  ·  None / Other: ____________

**Have you written any Flutter before? (circle):**  Never  ·  Tried a tutorial  ·  Built something real

---

## If something goes wrong

| What you see | What to do |
|---|---|
| `command not found: flutter`, but you installed it | Quit Terminal with `Cmd + Q`, open a **new** one, try again. zsh only reads `~/.zshrc` when it starts |
| *"cannot be opened because Apple cannot check it for malicious software"* | `xattr -dr com.apple.quarantine ~/development/flutter` then try again |
| `Android license status unknown` | Leave it. Known bug on current tools, not your machine. See the box in Step 1 |
| `cmdline-tools component is missing` | Leave it. The instructor covers this in the first hour |
| Xcode ✗, or CocoaPods not installed | Leave it. We are not building for iOS today. Do **not** start an Xcode download |
| `unzip` finished but `~/development/flutter/bin` is empty | You unzipped somewhere else. `cd ~/development` first, then unzip again |
| Your PATH line went into the wrong shell | If `echo $SHELL` says `bash`, use `~/.bash_profile` instead of `~/.zshrc` |
| Anything else | Raise your hand, then carry on to **dartpad.dev** |

### A note for later: the emulator

Good news on a Mac: there is no Hyper-V, no BIOS setting and no hypervisor driver to install. The Android emulator uses Apple's own virtualisation and simply works.

One thing to get right when you create a device: on **Apple Silicon** pick an **arm64-v8a** system image. An x86_64 image will be unusably slow or will not boot at all.

### A note for later: the iOS Simulator

You do **not** need this for Day 1, and you do not need it for the week — every
lab runs on the Android emulator or in Chrome. Set it up when you have time.

The iOS Simulator ships inside **Xcode**, so Xcode has to be installed first:
App Store → search Xcode → Get. It is around 10 GB and takes 30–60 minutes.
Command Line Tools on their own are not enough — that is what
`flutter doctor` means by *"Xcode installation is incomplete"*.

Once Xcode is in place, run the script instead of doing it by hand:

```
cd <the course repo>
./setup/setup_ios_simulator.sh --check     # report only, changes nothing
./setup/setup_ios_simulator.sh             # do it
```

It points the command line tools at Xcode, accepts the licence, installs the
first-launch components and the iOS runtime, checks CocoaPods, creates and
boots a simulator, and finishes with `flutter doctor`. It asks for your Mac
password once, up front, and it is safe to run again if a step fails.

One difference to remember once it works: the simulator shares your Mac's
network, so a local API is at `localhost` — **not** `10.0.2.2`, which is the
Android emulator's address for your machine.

**Nothing on this page can stop you taking part this morning.** All of today's first exercises run in the browser.

---

*MO Integrations · Flutter Mobile Application Development · Day 1*
