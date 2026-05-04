#!/usr/bin/env bash
# ============================================================
#  Salah — Android APK Build Script (WSL / Linux)
#  Run from the project root:  bash scripts/build_apk.sh
# ============================================================
set -e

JAVA_VERSION="17.0.2"
JAVA_DIR="$HOME/jdk-$JAVA_VERSION"
ANDROID_SDK_DIR="$HOME/Android/Sdk"
NDK_VERSION="28.2.13676358"

export JAVA_HOME="$JAVA_DIR"
export ANDROID_HOME="$ANDROID_SDK_DIR"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# ── 1. Java 17 ───────────────────────────────────────────────────────────────
if [ ! -f "$JAVA_DIR/bin/java" ]; then
  echo ">>> Downloading OpenJDK $JAVA_VERSION..."
  wget -q --show-progress \
    "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz" \
    -O /tmp/jdk17.tar.gz
  tar -xzf /tmp/jdk17.tar.gz -C "$HOME"
  rm /tmp/jdk17.tar.gz
  echo ">>> Java installed: $JAVA_DIR"
else
  echo ">>> Java already present: $JAVA_DIR"
fi

java -version 2>&1

# ── 2. Android SDK command-line tools ────────────────────────────────────────
if [ ! -f "$ANDROID_SDK_DIR/cmdline-tools/latest/bin/sdkmanager" ]; then
  echo ">>> Downloading Android SDK command-line tools..."
  mkdir -p "$ANDROID_SDK_DIR/cmdline-tools"
  wget -q --show-progress \
    "https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip" \
    -O /tmp/cmdline-tools.zip
  unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdtools_extract
  mv /tmp/cmdtools_extract/cmdline-tools "$ANDROID_SDK_DIR/cmdline-tools/latest"
  rm -rf /tmp/cmdline-tools.zip /tmp/cmdtools_extract
  echo ">>> SDK command-line tools installed"
else
  echo ">>> SDK command-line tools already present"
fi

# ── 3. Accept licenses ────────────────────────────────────────────────────────
echo ">>> Accepting SDK licenses..."
yes | sdkmanager --licenses > /dev/null 2>&1 || true

# ── 4. Install required SDK packages ─────────────────────────────────────────
echo ">>> Installing SDK packages (build-tools, platforms, platform-tools, NDK)..."
sdkmanager \
  "platform-tools" \
  "build-tools;36.0.0" \
  "platforms;android-36" \
  "ndk;$NDK_VERSION" 2>&1 | grep -E "Installing|complete|Unzipping" | tail -10

# ── 5. Write local.properties ────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cat > "$PROJECT_ROOT/android/local.properties" <<EOF
flutter.sdk=$(which flutter | sed 's|/bin/flutter||')
sdk.dir=$ANDROID_SDK_DIR
EOF
echo ">>> local.properties written"

# ── 6. Configure Flutter SDK path ────────────────────────────────────────────
flutter config --android-sdk "$ANDROID_SDK_DIR" > /dev/null 2>&1

# ── 7. Get Flutter dependencies ───────────────────────────────────────────────
cd "$PROJECT_ROOT"
echo ">>> Running flutter pub get..."
flutter pub get

# ── 8. Build release APK ─────────────────────────────────────────────────────
echo ""
echo ">>> Building release APK..."
flutter build apk --release

echo ""
echo "=================================================="
echo " BUILD COMPLETE"
echo " APK location:"
echo "   $PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk"
echo " Windows path:"
echo "   $(echo "$PROJECT_ROOT/build/app/outputs/flutter-apk/app-release.apk" | sed 's|/mnt/c|C:|' | sed 's|/|\\|g')"
echo "=================================================="
