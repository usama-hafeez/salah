# Build Notes — Salah Android APK

## Quick Start (WSL / Linux)

```bash
bash scripts/build_apk.sh
```

The script handles everything: downloads Java + Android SDK if missing, accepts
licenses, installs SDK packages, and runs `flutter build apk --release`.

---

## Environment Requirements

| Tool | Version | Notes |
|---|---|---|
| Java (JDK) | 17.0.2 | Downloaded to `~/jdk-17.0.2` — no sudo needed |
| Android SDK | cmdline-tools 11076708 | Downloaded to `~/Android/Sdk` |
| build-tools | 36.0.0 | Required by plugins |
| platform (compileSdk) | android-36 | Required by google_mobile_ads, geolocator, flutter_local_notifications |
| NDK | 28.2.13676358 | Required by the `jni` plugin |
| Gradle wrapper | 8.11.1 | AGP 8.7.3 requires ≥ 8.9 |
| AGP | 8.7.3 | Defined in `android/settings.gradle` |
| Kotlin | 2.1.0 | Defined in `android/settings.gradle` |
| Flutter | 3.41.7 stable | Already installed at `~/flutter` |

---

## android/app/build.gradle — Key Settings

```groovy
android {
    compileSdk 36
    ndkVersion "28.2.13676358"       // pins NDK for the jni plugin

    compileOptions {
        coreLibraryDesugaringEnabled true   // required by flutter_local_notifications
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = "11" }

    defaultConfig {
        minSdkVersion flutter.minSdkVersion   // 21
        targetSdk 36
    }
}

dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'
}
```

---

## Known Issues / Pending Fixes

### 1. `flutter_timezone` v1.0.8 — Kotlin 2.1.0 incompatibility ✅ FIXED
**Was:** `Unresolved reference 'Registrar'` in FlutterTimezonePlugin.kt  
**Fix applied:** Removed `flutter_timezone` entirely. Replaced with a native
`MethodChannel` call (`com.prayerapp.muslim/timezone`) implemented directly in
`MainActivity.kt` using `TimeZone.getDefault().id`. Zero third-party dependency,
immune to future Kotlin/embedding changes.

### 2. `README.md` in `android/app/src/main/res/raw/`
**Error:** `'R' is not a valid file-based resource name character`  
**Fix:** Already removed. Do not re-add any non-mp3 files to `res/raw/`.

### 3. Plugins requiring SDK 36
`flutter_local_notifications`, `geolocator_android`, `google_mobile_ads`,
`in_app_purchase_android`, `device_info_plus` all require `compileSdk 36`.  
**Fix:** Already set in `build.gradle`.

---

## Output Location

After a successful build:

| OS | Path |
|---|---|
| WSL | `build/app/outputs/flutter-apk/app-release.apk` |
| Windows | `C:\usama096\salah\build\app\outputs\flutter-apk\app-release.apk` |

The APK is signed with the **debug keystore** (sufficient for sharing via
WhatsApp / side-loading). For Play Store submission a proper release keystore
is needed.

---

## One-Time Environment Setup (manual)

If you prefer to set up manually instead of using the script:

```bash
# 1. Set env vars (add to ~/.bashrc to persist)
export JAVA_HOME=~/jdk-17.0.2
export ANDROID_HOME=~/Android/Sdk
export PATH=$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

# 2. Verify
java -version          # openjdk 17.0.2
flutter doctor         # should show Android toolchain ✓
```
