#!/usr/bin/env bash
#
# Set up the iOS Simulator for Flutter on macOS.
#
#   ./setup_ios_simulator.sh              # check, fix what it can, report
#   ./setup_ios_simulator.sh --check      # report only, change nothing
#   ./setup_ios_simulator.sh --device "iPhone 16 Pro"
#
# Safe to run repeatedly. Every step is idempotent and checks before acting.
# Nothing here silently waits on a prompt: sudo is requested once, up front,
# and long downloads announce themselves before they start.

set -uo pipefail

DEVICE_NAME=""
CHECK_ONLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --check) CHECK_ONLY=1 ;;
    --device) DEVICE_NAME="${2:-}"; shift ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

step()  { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
ok()    { printf '    \033[32mOK\033[0m   %s\n' "$*"; }
warn()  { printf '    \033[33mWARN\033[0m %s\n' "$*"; }
fail()  { printf '    \033[31mFAIL\033[0m %s\n' "$*"; }
die()   { printf '\n\033[31m%s\033[0m\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- preflight
step "Preflight"

[ "$(uname -s)" = "Darwin" ] || die "This only works on macOS. The iOS Simulator does not exist on Windows or Linux — use the Android emulator or Chrome instead."
ok "macOS $(sw_vers -productVersion)"

command -v flutter >/dev/null 2>&1 || die "flutter is not on PATH. Open a new terminal, or add <sdk>/bin to PATH."
ok "flutter $(flutter --version 2>/dev/null | head -1 | awk '{print $2}')"

ARCH=$(uname -m)
ok "architecture $ARCH"

# ------------------------------------------------------------------- Xcode
step "Xcode"

XCODE_APP=""
for candidate in /Applications/Xcode.app /Applications/Xcode-beta.app; do
  [ -d "$candidate" ] && { XCODE_APP="$candidate"; break; }
done
# also honour a non-standard location already selected
if [ -z "$XCODE_APP" ]; then
  sel=$(xcode-select -p 2>/dev/null || true)
  case "$sel" in
    */Xcode*.app/Contents/Developer) XCODE_APP="${sel%/Contents/Developer}" ;;
  esac
fi

if [ -z "$XCODE_APP" ]; then
  fail "Xcode is not installed. Only the Command Line Tools are present."
  cat <<'MSG'

    The iOS Simulator ships inside Xcode. It cannot be installed from a
    script — it is a ~10 GB App Store download that needs your Apple ID.

    Install it one of these ways, then run this script again:

      1. App Store  ->  search "Xcode"  ->  Get
      2. https://developer.apple.com/download/all/  (choose a stable Xcode)
      3. If you have `mas`:   mas install 497799835

    Expect 30-60 minutes on a good connection. You can carry on with the
    Android emulator or Chrome in the meantime:

      flutter run -d chrome

MSG
  exit 1
fi
ok "found $XCODE_APP"

XCODE_VER=$(defaults read "$XCODE_APP/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "unknown")
ok "version $XCODE_VER"

# ------------------------------------------------------------------- sudo
NEED_SUDO=0
CURRENT_DEV=$(xcode-select -p 2>/dev/null || echo "")
[ "$CURRENT_DEV" = "$XCODE_APP/Contents/Developer" ] || NEED_SUDO=1
"$XCODE_APP/Contents/Developer/usr/bin/xcodebuild" -version >/dev/null 2>&1 || NEED_SUDO=1

if [ "$NEED_SUDO" = 1 ] && [ "$CHECK_ONLY" = 0 ]; then
  step "Administrator access"
  echo "    Switching the active developer directory and accepting the Xcode"
  echo "    licence both need sudo. You will be asked once, now."
  sudo -v || die "sudo declined; nothing has been changed."
  # keep the timestamp alive while we work, and stop when the script does
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
  SUDO_KEEPALIVE=$!
  trap 'kill "$SUDO_KEEPALIVE" 2>/dev/null || true' EXIT
fi

# --------------------------------------------------- select + licence + first launch
step "Command line tools point at Xcode"
if [ "$CURRENT_DEV" = "$XCODE_APP/Contents/Developer" ]; then
  ok "already selected"
elif [ "$CHECK_ONLY" = 1 ]; then
  warn "would run: sudo xcode-select --switch $XCODE_APP/Contents/Developer"
else
  sudo xcode-select --switch "$XCODE_APP/Contents/Developer" \
    && ok "switched" || die "xcode-select failed"
fi

step "Xcode licence"
if xcodebuild -version >/dev/null 2>&1; then
  ok "accepted"
elif [ "$CHECK_ONLY" = 1 ]; then
  warn "would run: sudo xcodebuild -license accept"
else
  sudo xcodebuild -license accept && ok "accepted" || die "could not accept the licence"
fi

step "First launch components"
if [ "$CHECK_ONLY" = 1 ]; then
  warn "would run: sudo xcodebuild -runFirstLaunch"
else
  echo "    Installing any missing components (can take a few minutes)..."
  sudo xcodebuild -runFirstLaunch >/dev/null 2>&1 && ok "done" || warn "runFirstLaunch reported an issue; continuing"
fi

# -------------------------------------------------------- iOS platform runtime
step "iOS platform and simulator runtime"
RUNTIMES=$(xcrun simctl list runtimes 2>/dev/null | grep -c "iOS" || true)
if [ "${RUNTIMES:-0}" -gt 0 ]; then
  ok "$RUNTIMES iOS runtime(s) installed"
  xcrun simctl list runtimes 2>/dev/null | grep "iOS" | sed 's/^/         /'
elif [ "$CHECK_ONLY" = 1 ]; then
  warn "no iOS runtime; would run: xcodebuild -downloadPlatform iOS"
else
  warn "no iOS runtime installed"
  echo "    Downloading the iOS platform. This is several GB and can take"
  echo "    20+ minutes. It will not prompt you; leave it running."
  if xcodebuild -downloadPlatform iOS; then
    ok "iOS platform installed"
  else
    fail "download failed"
    echo "         Fall back to: Xcode -> Settings -> Components -> iOS Simulator"
    exit 1
  fi
fi

# ------------------------------------------------------------------ CocoaPods
step "CocoaPods"
if command -v pod >/dev/null 2>&1; then
  ok "pod $(pod --version 2>/dev/null)"
else
  warn "not installed - needed for any plugin with native iOS code"
  if [ "$CHECK_ONLY" = 1 ]; then
    warn "would run: brew install cocoapods"
  elif command -v brew >/dev/null 2>&1; then
    brew install cocoapods && ok "installed" || warn "brew install cocoapods failed; try: sudo gem install cocoapods"
  else
    warn "install it with:  sudo gem install cocoapods    (or install Homebrew first)"
  fi
fi

# ----------------------------------------------------------------- a device
step "Simulator device"
AVAILABLE=$(xcrun simctl list devices available 2>/dev/null | grep -E "iPhone|iPad" | sed 's/^ *//' || true)
if [ -n "$AVAILABLE" ]; then
  ok "available devices:"
  printf '%s\n' "$AVAILABLE" | sed 's/^/         /'
else
  warn "no simulator devices"
  if [ "$CHECK_ONLY" = 0 ]; then
    RT=$(xcrun simctl list runtimes 2>/dev/null | grep "iOS" | head -1 | awk '{print $NF}')
    DT=$(xcrun simctl list devicetypes 2>/dev/null | grep "iPhone" | tail -1 | sed -E 's/.*\((com\.apple[^)]*)\)/\1/')
    if [ -n "$RT" ] && [ -n "$DT" ]; then
      xcrun simctl create "Flutter iPhone" "$DT" "$RT" >/dev/null 2>&1 \
        && ok "created 'Flutter iPhone'" || warn "could not create a device"
    fi
  fi
fi

if [ "$CHECK_ONLY" = 0 ]; then
  step "Boot the simulator"
  BOOTED=$(xcrun simctl list devices booted 2>/dev/null | grep -cE "iPhone|iPad" || true)
  if [ "${BOOTED:-0}" -gt 0 ]; then
    ok "already booted"
  else
    if [ -n "$DEVICE_NAME" ]; then
      xcrun simctl boot "$DEVICE_NAME" 2>/dev/null || warn "could not boot '$DEVICE_NAME'"
    else
      TARGET=$(xcrun simctl list devices available 2>/dev/null | grep "iPhone" | tail -1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')
      [ -n "$TARGET" ] && xcrun simctl boot "$TARGET" 2>/dev/null || true
    fi
    open -a Simulator 2>/dev/null || warn "could not open Simulator.app"
    printf '    waiting for boot'
    for _ in $(seq 1 30); do
      if xcrun simctl list devices booted 2>/dev/null | grep -qE "iPhone|iPad"; then break; fi
      printf '.'; sleep 2
    done
    printf '\n'
    xcrun simctl list devices booted 2>/dev/null | grep -qE "iPhone|iPad" \
      && ok "booted" || warn "not booted yet - it may still be starting"
  fi

  step "Flutter iOS artefacts"
  flutter precache --ios >/dev/null 2>&1 && ok "precached" || warn "flutter precache --ios reported an issue"
fi

# ------------------------------------------------------------------- verify
step "Verify"
flutter doctor 2>&1 | grep -iE "xcode|cocoapods" | sed 's/^/    /'
echo
flutter devices 2>&1 | grep -iE "ios|simulator" | sed 's/^/    /' || warn "no iOS device visible to Flutter yet"

step "Done"
cat <<'MSG'
    Run your app on the simulator:

      flutter devices                       # confirm it is listed
      flutter run -d "iPhone"               # or the exact device name

    If the app talks to a local API, the simulator shares your Mac's
    network, so localhost is correct here (unlike the Android emulator,
    which needs 10.0.2.2):

      flutter run --dart-define=API_URL=http://localhost:8080
MSG
