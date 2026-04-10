# Salah App — Visual Assets Guide
## ASSETS.md — Complete Design & Image Generation Instructions

> **Instructions for Claude:**
> This file covers every visual asset needed for the Salah prayer app.
> For each asset, you will find: exact specifications, an SVG/code implementation you must produce,
> and where to save the file. Work through each section in order.
> All SVG assets must be saved as `.svg` files in the correct `assets/` subfolder.
> For raster assets (PNG), generate the SVG first, then provide the ImageMagick command to export PNG.
> Never leave a placeholder — every asset must be fully implemented.

---

## Table of Contents
1. [App Name Decision](#1-app-name-decision)
2. [Brand Identity](#2-brand-identity)
3. [App Icon (All Sizes)](#3-app-icon-all-sizes)
4. [Splash Screen](#4-splash-screen)
5. [Onboarding Illustrations](#5-onboarding-illustrations)
6. [Prayer Icons (5 icons)](#6-prayer-icons-5-icons)
7. [Navigation Icons](#7-navigation-icons)
8. [Feature Illustrations](#8-feature-illustrations)
9. [Home Screen Widget Backgrounds](#9-home-screen-widget-backgrounds)
10. [Play Store Assets](#10-play-store-assets)
11. [AI Image Generation Prompts](#11-ai-image-generation-prompts)
12. [Asset Checklist](#12-asset-checklist)

---

## 1. App Name Decision

**Chosen name: `Salah`**
- Full Play Store title: **Salah — Prayer Times & Quran**
- Package ID: `com.salahapp.muslim`
- Tagline: *Your daily companion for prayer, Quran, and worship*

### Why Salah
- Arabic word for Islamic prayer itself — universally understood by all 1.8 billion Muslims
- Single word — fits Play Store title limit, easy to search
- Works in every language without translation
- Clean, professional brand potential
- High search volume: "salah app", "salah prayer times", "salah times today"

### Alternative if `com.salahapp.muslim` is taken
- `com.salah.prayertimes`
- `com.namaaz.muslim` (use name "Namaaz" for Pakistan/India market)

---

## 2. Brand Identity

### Core colors (use these exact hex values everywhere)
```
Primary Green:    #0F4C3A   (Dark Islamic green — app bars, buttons, icon background)
Secondary Green:  #1A6B52   (Lighter green — secondary buttons, section headers)
Accent Gold:      #C9A84C   (Gold — prayer times, highlights, accent elements)
Deep Gold:        #8B6914   (Darker gold — text on light backgrounds)
Background Dark:  #121212   (Dark mode background)
Background Light: #FAFAF8   (Light mode background — slightly warm white)
Surface Dark:     #1E2D2A   (Dark mode card surfaces)
Surface Light:    #FFFFFF   (Light mode card surfaces)
Text Primary:     #FFFFFF / #1A1A1A  (white for dark, near-black for light)
Text Secondary:   #9E9E9E   (Captions, subtitles)
```

### Typography in brand materials
- **English:** Roboto Medium (500) for headings, Roboto Regular (400) for body
- **Arabic:** Hafs Quran font for Quranic text; Noto Naskh Arabic for UI
- **Urdu:** Noto Nastaliq Urdu

### Logo mark concept
- Crescent moon (right-facing) with a single five-pointed star
- Colors: gold crescent + star on deep green background
- Rounded square container (like an app icon)
- The crescent is the most universally recognised Islamic symbol — works at 16px

---

## 3. App Icon (All Sizes)

### 3.1 Master SVG icon

> **Instruction for Claude:** Create this file at `assets/icons/app_icon_master.svg`
> This is the single source of truth. All other sizes are exported from this.

```svg
<!-- Save as: assets/icons/app_icon_master.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <!-- Background: rounded square, deep green -->
  <rect width="1024" height="1024" rx="230" fill="#0F4C3A"/>

  <!-- Subtle inner glow ring (decorative) -->
  <rect x="40" y="40" width="944" height="944" rx="200"
    fill="none" stroke="#1A6B52" stroke-width="4" opacity="0.6"/>

  <!-- Crescent moon: constructed as two overlapping circles -->
  <!-- Outer circle of crescent -->
  <circle cx="460" cy="480" r="230" fill="#C9A84C"/>
  <!-- Inner circle that cuts the crescent (same color as background) -->
  <circle cx="560" cy="440" r="200" fill="#0F4C3A"/>

  <!-- Five-pointed star (top right of crescent) -->
  <!-- Star center at approximately (720, 260), size 90 -->
  <polygon
    points="720,185 742,245 806,245 756,280 775,342 720,308 665,342 684,280 634,245 698,245"
    fill="#C9A84C"/>

  <!-- App name text "Salah" in Arabic: صلاة -->
  <!-- Centered below the crescent -->
  <text
    x="512" y="820"
    font-family="serif"
    font-size="120"
    font-weight="500"
    fill="#C9A84C"
    text-anchor="middle"
    dominant-baseline="middle">صلاة</text>

  <!-- Thin gold separator line above text -->
  <line x1="312" y1="730" x2="712" y2="730"
    stroke="#C9A84C" stroke-width="3" opacity="0.4"/>
</svg>
```

### 3.2 Required PNG sizes for Android

> **Instruction for Claude:**
> After creating the SVG, run the following ImageMagick commands to export all required Android sizes.
> Install ImageMagick first if not available: `sudo apt-get install imagemagick`

```bash
# Create all Android icon directories first
mkdir -p android/app/src/main/res/mipmap-mdpi
mkdir -p android/app/src/main/res/mipmap-hdpi
mkdir -p android/app/src/main/res/mipmap-xhdpi
mkdir -p android/app/src/main/res/mipmap-xxhdpi
mkdir -p android/app/src/main/res/mipmap-xxxhdpi

# Export each size from the master SVG
# mdpi (48x48)
convert -background none assets/icons/app_icon_master.svg \
  -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png

# hdpi (72x72)
convert -background none assets/icons/app_icon_master.svg \
  -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png

# xhdpi (96x96)
convert -background none assets/icons/app_icon_master.svg \
  -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png

# xxhdpi (144x144)
convert -background none assets/icons/app_icon_master.svg \
  -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png

# xxxhdpi (192x192) — most modern phones use this
convert -background none assets/icons/app_icon_master.svg \
  -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png

# Play Store icon (512x512) — must be exactly 512x512, no transparency
convert -background "#0F4C3A" assets/icons/app_icon_master.svg \
  -resize 512x512 -flatten assets/icons/play_store_icon_512.png
```

### 3.3 Adaptive icon (Android 8.0+)

Android adaptive icons have a foreground layer and a background layer.
The system applies a mask shape (circle, squircle, etc.) — your content must stay inside the "safe zone".

**Background layer** — save at `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_background.png`
```bash
# Solid green background (432x432 — the adaptive icon canvas size)
convert -size 432x432 xc:"#0F4C3A" \
  android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_background.png
```

**Foreground layer** — save at `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png`
> The foreground must have transparent background. Safe zone = central 66% (about 286x286px).
> The crescent+star should fit within that safe zone.

```bash
# Export foreground: crescent + star only, centered on transparent 432x432 canvas
# Use a modified SVG that has the crescent/star centered without the background rect
convert -background none assets/icons/app_icon_foreground.svg \
  -resize 432x432 \
  android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png
```

Create `assets/icons/app_icon_foreground.svg` — same as master but WITHOUT the background rect:
```svg
<!-- Save as: assets/icons/app_icon_foreground.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
  <!-- No background rect — transparent -->
  <circle cx="460" cy="480" r="230" fill="#C9A84C"/>
  <circle cx="560" cy="440" r="200" fill="#0F4C3A"/>
  <polygon
    points="720,185 742,245 806,245 756,280 775,342 720,308 665,342 684,280 634,245 698,245"
    fill="#C9A84C"/>
</svg>
```

**Register in `android/app/src/main/res/xml/ic_launcher.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
```

---

## 4. Splash Screen

### 4.1 Flutter splash screen setup

Install the package:
```yaml
# Add to pubspec.yaml dev_dependencies:
flutter_native_splash: ^2.4.0
```

Add splash configuration to `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#0F4C3A"           # Background color (primary green)
  color_dark: "#000000"      # Background for dark mode devices
  image: assets/images/splash_logo.png
  image_dark: assets/images/splash_logo.png
  android_12:
    image: assets/images/splash_logo_android12.png
    icon_background_color: "#0F4C3A"
    color: "#0F4C3A"
  web: false                 # Not building for web
  ios: false                 # Android first
```

Run to generate native splash:
```bash
dart run flutter_native_splash:create
```

### 4.2 Splash logo SVG

> **Instruction for Claude:** Create this SVG, then export to PNG at the required sizes.

```svg
<!-- Save as: assets/images/splash_logo.svg -->
<!-- Used centered on the #0F4C3A background during splash -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300">

  <!-- Crescent moon -->
  <circle cx="185" cy="130" r="90" fill="#C9A84C"/>
  <circle cx="225" cy="110" r="78" fill="#0F4C3A"/>

  <!-- Star -->
  <polygon
    points="290,60 300,88 330,88 306,104 315,132 290,117 265,132 274,104 250,88 280,88"
    fill="#C9A84C"/>

  <!-- App name: Salah -->
  <text x="200" y="240"
    font-family="Georgia, serif"
    font-size="52"
    font-weight="700"
    fill="#FFFFFF"
    text-anchor="middle"
    letter-spacing="8">SALAH</text>

  <!-- Tagline -->
  <text x="200" y="272"
    font-family="Arial, sans-serif"
    font-size="14"
    fill="#C9A84C"
    text-anchor="middle"
    letter-spacing="2">PRAYER TIMES &amp; QURAN</text>

</svg>
```

Export to PNG:
```bash
# Main splash logo (used by flutter_native_splash)
convert -background "#0F4C3A" assets/images/splash_logo.svg \
  -resize 400x300 assets/images/splash_logo.png

# Android 12 icon (must be 1152x1152 with content in central 768x768)
convert -background "#0F4C3A" assets/images/splash_logo.svg \
  -resize 300x300 -gravity center -extent 1152x1152 \
  assets/images/splash_logo_android12.png
```

### 4.3 Animated splash (Flutter widget)

After native splash dismisses, show this animated widget briefly before home screen:

```dart
// lib/features/onboarding/splash_screen.dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
    );
    _scaleUp = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        final isOnboarded = StorageService.onboardingDone;
        Navigator.of(context).pushReplacementNamed(
          isOnboarded ? '/home' : '/onboarding',
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0F4C3A),
    body: Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scaleUp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/images/splash_logo.svg', width: 180),
                const SizedBox(height: 24),
                const Text('SALAH',
                  style: TextStyle(color: Colors.white,
                    fontSize: 36, fontWeight: FontWeight.w600,
                    letterSpacing: 8)),
                const SizedBox(height: 8),
                const Text('Prayer Times & Quran',
                  style: TextStyle(color: Color(0xFFC9A84C),
                    fontSize: 13, letterSpacing: 2)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
```

---

## 5. Onboarding Illustrations

Three onboarding screens need illustrations. Each is a simple, clean SVG illustration.

### 5.1 Onboarding screen 1 — "Accurate Prayer Times"

```svg
<!-- Save as: assets/images/onboarding_1.svg -->
<!-- Illustration: Mosque silhouette at dusk with clock -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 280">

  <!-- Sky background (dusk gradient represented as layered rects) -->
  <rect width="360" height="280" fill="#0a2d20"/>
  <rect width="360" height="140" y="140" fill="#0F4C3A" opacity="0.5"/>

  <!-- Stars -->
  <circle cx="40" cy="30" r="1.5" fill="#C9A84C" opacity="0.8"/>
  <circle cx="80" cy="15" r="1" fill="#FFFFFF" opacity="0.6"/>
  <circle cx="140" cy="25" r="1.5" fill="#FFFFFF" opacity="0.5"/>
  <circle cx="200" cy="10" r="1" fill="#C9A84C" opacity="0.7"/>
  <circle cx="260" cy="30" r="1.5" fill="#FFFFFF" opacity="0.6"/>
  <circle cx="320" cy="18" r="1" fill="#C9A84C" opacity="0.8"/>
  <circle cx="310" cy="55" r="1" fill="#FFFFFF" opacity="0.5"/>
  <circle cx="60" cy="60" r="1" fill="#FFFFFF" opacity="0.4"/>

  <!-- Moon (crescent) -->
  <circle cx="300" cy="50" r="28" fill="#C9A84C" opacity="0.9"/>
  <circle cx="313" cy="43" r="23" fill="#0a2d20"/>

  <!-- Mosque main body -->
  <rect x="120" y="160" width="120" height="90" rx="4" fill="#1A6B52"/>

  <!-- Central dome -->
  <ellipse cx="180" cy="160" rx="44" ry="40" fill="#1A6B52"/>
  <ellipse cx="180" cy="160" rx="40" ry="36" fill="#155940"/>

  <!-- Dome finial (crescent on top) -->
  <line x1="180" y1="120" x2="180" y2="108" stroke="#C9A84C" stroke-width="2"/>
  <circle cx="180" cy="104" r="8" fill="#C9A84C"/>
  <circle cx="185" cy="101" r="6" fill="#0a2d20"/>

  <!-- Left minaret -->
  <rect x="100" y="140" width="18" height="90" rx="3" fill="#1A6B52"/>
  <ellipse cx="109" cy="140" rx="9" ry="14" fill="#155940"/>
  <line x1="109" y1="126" x2="109" y2="118" stroke="#C9A84C" stroke-width="1.5"/>
  <circle cx="109" cy="116" r="4" fill="#C9A84C"/>
  <circle cx="111" cy="114" r="3" fill="#0a2d20"/>

  <!-- Right minaret -->
  <rect x="242" y="140" width="18" height="90" rx="3" fill="#1A6B52"/>
  <ellipse cx="251" cy="140" rx="9" ry="14" fill="#155940"/>
  <line x1="251" y1="126" x2="251" y2="118" stroke="#C9A84C" stroke-width="1.5"/>
  <circle cx="251" cy="116" r="4" fill="#C9A84C"/>
  <circle cx="253" cy="114" r="3" fill="#0a2d20"/>

  <!-- Windows on mosque -->
  <ellipse cx="155" cy="190" rx="10" ry="14" fill="#0a2d20" opacity="0.7"/>
  <ellipse cx="180" cy="190" rx="10" ry="14" fill="#0a2d20" opacity="0.7"/>
  <ellipse cx="205" cy="190" rx="10" ry="14" fill="#0a2d20" opacity="0.7"/>

  <!-- Ground -->
  <rect y="248" width="360" height="32" fill="#0F4C3A"/>

  <!-- Clock widget floating top-left -->
  <rect x="16" y="70" width="90" height="60" rx="10" fill="#1A6B52" opacity="0.95"/>
  <text x="61" y="94" font-family="Arial" font-size="11" fill="#C9A84C"
    text-anchor="middle" font-weight="600">NEXT PRAYER</text>
  <text x="61" y="118" font-family="Arial" font-size="18" fill="#FFFFFF"
    text-anchor="middle" font-weight="700">04:12</text>

</svg>
```

Export:
```bash
convert -background none assets/images/onboarding_1.svg \
  -resize 360x280 assets/images/onboarding_1.png
```

### 5.2 Onboarding screen 2 — "Full Quran Reader"

```svg
<!-- Save as: assets/images/onboarding_2.svg -->
<!-- Illustration: Open book with Arabic text -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 280">

  <!-- Background -->
  <rect width="360" height="280" fill="#0a2d20"/>

  <!-- Decorative geometric pattern (top corners) -->
  <polygon points="0,0 80,0 0,80" fill="#1A6B52" opacity="0.4"/>
  <polygon points="360,0 280,0 360,80" fill="#1A6B52" opacity="0.4"/>

  <!-- Open book base -->
  <!-- Left page -->
  <rect x="40" y="70" width="130" height="160" rx="4" fill="#F5F0E8"/>
  <!-- Right page -->
  <rect x="190" y="70" width="130" height="160" rx="4" fill="#FAFAF8"/>
  <!-- Spine shadow -->
  <rect x="168" y="70" width="24" height="160" rx="2" fill="#C9A84C" opacity="0.3"/>
  <!-- Spine line -->
  <line x1="180" y1="70" x2="180" y2="230" stroke="#C9A84C" stroke-width="2" opacity="0.7"/>

  <!-- Left page: Arabic text lines (simulated) -->
  <text x="155" y="102" font-family="serif" font-size="13" fill="#1A1A1A"
    text-anchor="end" direction="rtl">بِسْمِ اللَّهِ</text>
  <rect x="55" y="110" width="95" height="2" rx="1" fill="#ccbda0"/>
  <rect x="55" y="122" width="80" height="2" rx="1" fill="#ccbda0"/>
  <rect x="55" y="134" width="95" height="2" rx="1" fill="#ccbda0"/>
  <rect x="55" y="146" width="70" height="2" rx="1" fill="#ccbda0"/>
  <rect x="55" y="158" width="95" height="2" rx="1" fill="#ccbda0"/>
  <rect x="55" y="170" width="85" height="2" rx="1" fill="#ccbda0"/>
  <rect x="55" y="182" width="95" height="2" rx="1" fill="#ccbda0"/>
  <rect x="55" y="194" width="60" height="2" rx="1" fill="#ccbda0"/>

  <!-- Left page: ayah number circle -->
  <circle cx="68" cy="102" r="10" fill="#C9A84C"/>
  <text x="68" y="106" font-family="Arial" font-size="9" fill="#FFFFFF"
    text-anchor="middle" font-weight="700">١</text>

  <!-- Right page: Translation lines -->
  <text x="200" y="100" font-family="Arial" font-size="9" fill="#888">Translation</text>
  <rect x="200" y="110" width="110" height="2" rx="1" fill="#ddd"/>
  <rect x="200" y="122" width="95" height="2" rx="1" fill="#ddd"/>
  <rect x="200" y="134" width="110" height="2" rx="1" fill="#ddd"/>
  <rect x="200" y="146" width="80" height="2" rx="1" fill="#ddd"/>
  <rect x="200" y="158" width="110" height="2" rx="1" fill="#ddd"/>
  <rect x="200" y="170" width="90" height="2" rx="1" fill="#ddd"/>

  <!-- Bookmark ribbon -->
  <polygon points="295,70 310,70 310,110 302,102 295,110" fill="#C9A84C"/>

  <!-- Stars decoration -->
  <circle cx="30" cy="40" r="2" fill="#C9A84C" opacity="0.6"/>
  <circle cx="180" cy="20" r="2" fill="#C9A84C" opacity="0.5"/>
  <circle cx="330" cy="40" r="2" fill="#C9A84C" opacity="0.6"/>

  <!-- Bottom label -->
  <rect x="120" y="244" width="120" height="24" rx="12" fill="#1A6B52"/>
  <text x="180" y="260" font-family="Arial" font-size="11" fill="#C9A84C"
    text-anchor="middle" font-weight="600">114 SURAHS</text>

</svg>
```

Export:
```bash
convert -background none assets/images/onboarding_2.svg \
  -resize 360x280 assets/images/onboarding_2.png
```

### 5.3 Onboarding screen 3 — "Home Screen Widget"

```svg
<!-- Save as: assets/images/onboarding_3.svg -->
<!-- Illustration: Phone showing home screen with widget -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 280">

  <!-- Background -->
  <rect width="360" height="280" fill="#0a2d20"/>

  <!-- Phone body -->
  <rect x="110" y="20" width="140" height="245" rx="20" fill="#1c1c1e"/>
  <!-- Screen -->
  <rect x="118" y="34" width="124" height="218" rx="12" fill="#2a2a2e"/>
  <!-- Notch -->
  <rect x="155" y="34" width="50" height="10" rx="5" fill="#1c1c1e"/>

  <!-- Home screen wallpaper (dark green) -->
  <rect x="118" y="44" width="124" height="208" rx="6" fill="#0F4C3A"/>

  <!-- Prayer Widget on home screen -->
  <rect x="126" y="54" width="108" height="70" rx="10" fill="#1A6B52"/>
  <!-- Widget: app name small -->
  <text x="134" y="68" font-family="Arial" font-size="7" fill="#9ECFBA">Salah Widget</text>
  <!-- Widget: prayer name -->
  <text x="134" y="84" font-family="Arial" font-size="12" fill="#FFFFFF" font-weight="600">Asr</text>
  <!-- Widget: countdown -->
  <text x="134" y="100" font-family="Arial" font-size="16" fill="#C9A84C" font-weight="700">01:32:44</text>
  <!-- Widget: date -->
  <text x="134" y="114" font-family="Arial" font-size="7" fill="#9ECFBA">15 Shawwal · Thu Apr 9</text>

  <!-- App icons grid -->
  <!-- Row 1 -->
  <rect x="126" y="138" width="24" height="24" rx="6" fill="#C9A84C" opacity="0.8"/>
  <rect x="158" y="138" width="24" height="24" rx="6" fill="#1A6B52" opacity="0.8"/>
  <rect x="190" y="138" width="24" height="24" rx="6" fill="#4a2980" opacity="0.8"/>
  <rect x="222" y="138" width="24" height="24" rx="6" fill="#8B1A1A" opacity="0.8"/>
  <!-- Row 2 -->
  <rect x="126" y="170" width="24" height="24" rx="6" fill="#185FA5" opacity="0.8"/>
  <rect x="158" y="170" width="24" height="24" rx="6" fill="#3B6D11" opacity="0.8"/>
  <rect x="190" y="170" width="24" height="24" rx="6" fill="#854F0B" opacity="0.8"/>
  <rect x="222" y="170" width="24" height="24" rx="6" fill="#0F4C3A" opacity="0.9"/>

  <!-- Dock -->
  <rect x="126" y="212" width="108" height="34" rx="10" fill="#000000" opacity="0.4"/>
  <rect x="134" y="219" width="20" height="20" rx="6" fill="#C9A84C"/>
  <rect x="162" y="219" width="20" height="20" rx="6" fill="#1A6B52"/>
  <rect x="190" y="219" width="20" height="20" rx="6" fill="#185FA5"/>
  <rect x="218" y="219" width="20" height="20" rx="6" fill="#5F5E5A"/>

  <!-- "Swipe to unlock" hint -->
  <text x="180" y="265" font-family="Arial" font-size="9" fill="#C9A84C"
    text-anchor="middle" opacity="0.8">Widget on your home screen</text>

  <!-- Left decoration -->
  <text x="70" y="140" font-family="Arial" font-size="40" fill="#C9A84C"
    opacity="0.15" font-weight="700">&#9790;</text>

</svg>
```

Export:
```bash
convert -background none assets/images/onboarding_3.svg \
  -resize 360x280 assets/images/onboarding_3.png
```

---

## 6. Prayer Icons (5 icons)

One unique icon per prayer. All icons use the same style: gold stroke on transparent background.
Size: 64x64 SVG. The icon visually represents the spiritual character of each prayer.

> **Instruction for Claude:** Create all 5 SVG files. These are used as the icon in each prayer row on the home screen.

### Fajr (Dawn prayer)

```svg
<!-- Save as: assets/icons/fajr.svg -->
<!-- Concept: Crescent moon + rising sun rays (dawn) -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Rising sun (half circle at horizon) -->
  <line x1="12" y1="44" x2="52" y2="44" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <path d="M20 44 A12 12 0 0 1 44 44" fill="none" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <!-- Sun rays -->
  <line x1="32" y1="26" x2="32" y2="20" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="20" y1="32" x2="15" y2="29" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="44" y1="32" x2="49" y2="29" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="23" y1="23" x2="19" y2="19" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="41" y1="23" x2="45" y2="19" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Crescent moon (small, top right) -->
  <circle cx="47" cy="16" r="7" fill="#C9A84C" opacity="0.9"/>
  <circle cx="50" cy="14" r="6" fill="transparent"/>
  <!-- Make the inner circle mask with the icon's background context -->
  <!-- Note: set fill to match theme background dynamically in Flutter -->
</svg>
```

### Dhuhr (Midday prayer)

```svg
<!-- Save as: assets/icons/dhuhr.svg -->
<!-- Concept: Full sun at zenith -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Sun circle -->
  <circle cx="32" cy="32" r="10" fill="none" stroke="#C9A84C" stroke-width="2"/>
  <!-- 8 rays -->
  <line x1="32" y1="14" x2="32" y2="8" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <line x1="32" y1="50" x2="32" y2="56" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <line x1="14" y1="32" x2="8" y2="32" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <line x1="50" y1="32" x2="56" y2="32" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <line x1="20" y1="20" x2="15" y2="15" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <line x1="44" y1="44" x2="49" y2="49" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <line x1="20" y1="44" x2="15" y2="49" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <line x1="44" y1="20" x2="49" y2="15" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
</svg>
```

### Asr (Afternoon prayer)

```svg
<!-- Save as: assets/icons/asr.svg -->
<!-- Concept: Sun lower in sky, long shadow line -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Sun (slightly below center, smaller) -->
  <circle cx="42" cy="26" r="8" fill="none" stroke="#C9A84C" stroke-width="2"/>
  <!-- Rays (fewer, angled) -->
  <line x1="42" y1="12" x2="42" y2="8" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="52" y1="16" x2="55" y2="13" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="56" y1="26" x2="60" y2="26" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="52" y1="36" x2="55" y2="39" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Long shadow (person + shadow) -->
  <line x1="16" y1="44" x2="52" y2="44" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Person stick figure (simple) -->
  <circle cx="22" cy="34" r="4" fill="none" stroke="#C9A84C" stroke-width="1.5"/>
  <line x1="22" y1="38" x2="22" y2="48" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Shadow extending far right -->
  <line x1="22" y1="48" x2="50" y2="44" stroke="#C9A84C" stroke-width="1" stroke-linecap="round" opacity="0.5"/>
</svg>
```

### Maghrib (Sunset prayer)

```svg
<!-- Save as: assets/icons/maghrib.svg -->
<!-- Concept: Sun setting at horizon with orange reflection -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Horizon line -->
  <line x1="8" y1="42" x2="56" y2="42" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Setting sun (half below horizon) -->
  <path d="M22 42 A10 10 0 0 1 42 42" fill="none" stroke="#C9A84C" stroke-width="2.5" stroke-linecap="round"/>
  <!-- Sun disk center -->
  <circle cx="32" cy="42" r="2" fill="#C9A84C"/>
  <!-- Rays above horizon only -->
  <line x1="32" y1="24" x2="32" y2="18" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="18" y1="30" x2="13" y2="26" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="46" y1="30" x2="51" y2="26" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="20" y1="22" x2="16" y2="17" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="44" y1="22" x2="48" y2="17" stroke="#C9A84C" stroke-width="1.5" stroke-linecap="round"/>
  <!-- Reflection on water (subtle) -->
  <line x1="24" y1="47" x2="40" y2="47" stroke="#C9A84C" stroke-width="1" stroke-linecap="round" opacity="0.4"/>
  <line x1="28" y1="51" x2="36" y2="51" stroke="#C9A84C" stroke-width="1" stroke-linecap="round" opacity="0.25"/>
</svg>
```

### Isha (Night prayer)

```svg
<!-- Save as: assets/icons/isha.svg -->
<!-- Concept: Full crescent moon + stars (night) -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">
  <!-- Crescent moon -->
  <circle cx="30" cy="32" r="14" fill="#C9A84C" opacity="0.95"/>
  <circle cx="36" cy="29" r="12" fill="transparent"/>
  <!-- Stars -->
  <circle cx="48" cy="16" r="2" fill="#C9A84C"/>
  <circle cx="52" cy="28" r="1.5" fill="#C9A84C" opacity="0.8"/>
  <circle cx="44" cy="44" r="1.5" fill="#C9A84C" opacity="0.6"/>
  <circle cx="16" cy="14" r="1.5" fill="#C9A84C" opacity="0.5"/>
  <circle cx="14" cy="44" r="1" fill="#C9A84C" opacity="0.4"/>
  <circle cx="56" cy="44" r="1" fill="#C9A84C" opacity="0.5"/>
  <!-- Four-pointed sparkle star (large) -->
  <path d="M50 12 L51.5 16 L56 12 L51.5 8 Z M50 12 L48 13.5 L50 18 L52 13.5 Z"
    fill="#C9A84C" opacity="0.6"/>
</svg>
```

Export all prayer icons:
```bash
for prayer in fajr dhuhr asr maghrib isha; do
  convert -background none assets/icons/${prayer}.svg \
    -resize 64x64 assets/icons/${prayer}.png
done
```

---

## 7. Navigation Icons

Five bottom navigation bar icons. Style: simple line icons, 24x24.
The active icon uses `#C9A84C` fill, inactive uses `#9E9E9E`.

> **Instruction for Claude:** In Flutter, use `SvgPicture.asset` with a `colorFilter` to tint them.

```dart
// Apply color tint dynamically based on active state
SvgPicture.asset(
  'assets/icons/nav_home.svg',
  colorFilter: ColorFilter.mode(
    isActive ? const Color(0xFFC9A84C) : const Color(0xFF9E9E9E),
    BlendMode.srcIn,
  ),
  width: 24, height: 24,
)
```

### nav_home.svg (house)
```svg
<!-- Save as: assets/icons/nav_home.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="M3 10.5L12 3l9 7.5V21a1 1 0 01-1 1H5a1 1 0 01-1-1V10.5z"
    fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
  <rect x="9" y="14" width="6" height="8" rx="1"
    fill="none" stroke="currentColor" stroke-width="1.5"/>
</svg>
```

### nav_quran.svg (open book)
```svg
<!-- Save as: assets/icons/nav_quran.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="M2 4h8a2 2 0 012 2v14a1.5 1.5 0 00-1.5-1.5H2V4z"
    fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
  <path d="M22 4h-8a2 2 0 00-2 2v14a1.5 1.5 0 011.5-1.5H22V4z"
    fill="none" stroke="currentColor" stroke-width="1.5" stroke-linejoin="round"/>
</svg>
```

### nav_qibla.svg (compass)
```svg
<!-- Save as: assets/icons/nav_qibla.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="9" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <polygon points="12,4 14,12 12,20 10,12" fill="none" stroke="currentColor"
    stroke-width="1.5" stroke-linejoin="round"/>
  <circle cx="12" cy="12" r="2" fill="currentColor"/>
</svg>
```

### nav_tasbih.svg (prayer beads)
```svg
<!-- Save as: assets/icons/nav_tasbih.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="5" r="2.5" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <circle cx="18" cy="9" r="2" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <circle cx="19" cy="15" r="2" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <circle cx="15" cy="20" r="2" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <circle cx="9" cy="20" r="2" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <circle cx="5" cy="15" r="2" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <circle cx="6" cy="9" r="2" fill="none" stroke="currentColor" stroke-width="1.5"/>
  <path d="M12 7.5 Q14 8 16.5 10.5" fill="none" stroke="currentColor"
    stroke-width="1" stroke-dasharray="2 2"/>
</svg>
```

### nav_more.svg (three dots)
```svg
<!-- Save as: assets/icons/nav_more.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <circle cx="12" cy="5" r="1.5" fill="currentColor"/>
  <circle cx="12" cy="12" r="1.5" fill="currentColor"/>
  <circle cx="12" cy="19" r="1.5" fill="currentColor"/>
</svg>
```

---

## 8. Feature Illustrations

### Qibla compass background
```svg
<!-- Save as: assets/images/qibla_compass_bg.svg -->
<!-- Full decorative compass rose for Qibla screen background -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 320">
  <!-- Outer ring -->
  <circle cx="160" cy="160" r="148" fill="none" stroke="#1A6B52" stroke-width="1" opacity="0.4"/>
  <circle cx="160" cy="160" r="130" fill="none" stroke="#1A6B52" stroke-width="0.5" opacity="0.3"/>
  <circle cx="160" cy="160" r="80" fill="none" stroke="#C9A84C" stroke-width="0.5" opacity="0.3"/>

  <!-- Cardinal direction ticks (N, E, S, W) -->
  <line x1="160" y1="14" x2="160" y2="30" stroke="#C9A84C" stroke-width="2" stroke-linecap="round"/>
  <line x1="160" y1="290" x2="160" y2="306" stroke="#1A6B52" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="14" y1="160" x2="30" y2="160" stroke="#1A6B52" stroke-width="1.5" stroke-linecap="round"/>
  <line x1="290" y1="160" x2="306" y2="160" stroke="#1A6B52" stroke-width="1.5" stroke-linecap="round"/>

  <!-- 8 minor ticks -->
  <line x1="261" y1="59" x2="252" y2="68" stroke="#1A6B52" stroke-width="1" stroke-linecap="round" opacity="0.5"/>
  <line x1="261" y1="261" x2="252" y2="252" stroke="#1A6B52" stroke-width="1" stroke-linecap="round" opacity="0.5"/>
  <line x1="59" y1="261" x2="68" y2="252" stroke="#1A6B52" stroke-width="1" stroke-linecap="round" opacity="0.5"/>
  <line x1="59" y1="59" x2="68" y2="68" stroke="#1A6B52" stroke-width="1" stroke-linecap="round" opacity="0.5"/>

  <!-- Cardinal labels -->
  <text x="160" y="10" font-family="Arial" font-size="12" fill="#C9A84C"
    text-anchor="middle" font-weight="700">N</text>
  <text x="160" y="318" font-family="Arial" font-size="12" fill="#9E9E9E"
    text-anchor="middle">S</text>
  <text x="4" y="164" font-family="Arial" font-size="12" fill="#9E9E9E"
    text-anchor="start">W</text>
  <text x="316" y="164" font-family="Arial" font-size="12" fill="#9E9E9E"
    text-anchor="end">E</text>

  <!-- Center dot -->
  <circle cx="160" cy="160" r="6" fill="#C9A84C" opacity="0.8"/>
  <circle cx="160" cy="160" r="3" fill="#FFFFFF"/>
</svg>
```

### Compass needle (rotated dynamically in Flutter)
```svg
<!-- Save as: assets/images/compass_needle.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 120">
  <!-- North pointer (gold — points toward Qibla) -->
  <polygon points="20,0 26,55 14,55" fill="#C9A84C"/>
  <!-- South pointer (muted) -->
  <polygon points="20,120 26,65 14,65" fill="#5F5E5A"/>
  <!-- Center circle -->
  <circle cx="20" cy="60" r="8" fill="#1E2D2A" stroke="#C9A84C" stroke-width="1.5"/>
</svg>
```

---

## 9. Home Screen Widget Backgrounds

These are the background images for each widget theme, drawn in Android XML layout.
For Flutter's `home_widget` package, backgrounds are set via the XML layout, not SVG.

> **Instruction for Claude:** Create these Android drawable XML files.

```xml
<!-- Save as: android/app/src/main/res/drawable/widget_bg_midnight.xml -->
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
  <solid android:color="#0F4C3A"/>
  <corners android:radius="16dp"/>
</shape>
```

```xml
<!-- Save as: android/app/src/main/res/drawable/widget_bg_gold.xml -->
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
  <solid android:color="#1A2D00"/>
  <corners android:radius="16dp"/>
  <stroke android:width="1dp" android:color="#C9A84C"/>
</shape>
```

```xml
<!-- Save as: android/app/src/main/res/drawable/widget_bg_dark.xml -->
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
  <solid android:color="#000000"/>
  <corners android:radius="16dp"/>
</shape>
```

---

## 10. Play Store Assets

These must be created before submitting to the Play Store.

### 10.1 Feature Graphic (1024 × 500 px)

> **Instruction for Claude:** Generate an SVG at 1024×500, then export as PNG.
> This is shown at the top of your Play Store listing — it's the first thing users see.

```svg
<!-- Save as: assets/store/feature_graphic.svg -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 500">

  <!-- Background: deep green -->
  <rect width="1024" height="500" fill="#0F4C3A"/>

  <!-- Decorative geometric pattern — top right -->
  <polygon points="1024,0 824,0 1024,200" fill="#1A6B52" opacity="0.4"/>
  <polygon points="1024,0 924,0 1024,100" fill="#1A6B52" opacity="0.3"/>

  <!-- Decorative pattern — bottom left -->
  <polygon points="0,500 200,500 0,300" fill="#1A6B52" opacity="0.3"/>

  <!-- Large crescent (left side) -->
  <circle cx="220" cy="250" r="160" fill="#C9A84C" opacity="0.15"/>
  <circle cx="220" cy="250" r="140" fill="#C9A84C" opacity="0.9"/>
  <circle cx="270" cy="220" r="120" fill="#0F4C3A"/>

  <!-- Star near crescent -->
  <polygon
    points="370,100 382,136 420,136 390,158 402,194 370,172 338,194 350,158 320,136 358,136"
    fill="#C9A84C"/>

  <!-- App name: SALAH (center) -->
  <text x="560" y="220"
    font-family="Georgia, serif"
    font-size="96"
    font-weight="700"
    fill="#FFFFFF"
    text-anchor="middle"
    letter-spacing="12">SALAH</text>

  <!-- Arabic name -->
  <text x="560" y="290"
    font-family="serif"
    font-size="48"
    fill="#C9A84C"
    text-anchor="middle"
    opacity="0.9">صلاة</text>

  <!-- Tagline -->
  <text x="560" y="360"
    font-family="Arial, sans-serif"
    font-size="22"
    fill="#9ECFBA"
    text-anchor="middle"
    letter-spacing="3">PRAYER TIMES · QURAN · QIBLA</text>

  <!-- Bottom divider line -->
  <line x1="360" y1="390" x2="760" y2="390"
    stroke="#C9A84C" stroke-width="1" opacity="0.4"/>

  <!-- Star decorations -->
  <circle cx="120" cy="80" r="3" fill="#C9A84C" opacity="0.5"/>
  <circle cx="80" cy="140" r="2" fill="#FFFFFF" opacity="0.3"/>
  <circle cx="900" cy="400" r="3" fill="#C9A84C" opacity="0.5"/>
  <circle cx="960" cy="340" r="2" fill="#FFFFFF" opacity="0.4"/>
  <circle cx="840" cy="440" r="2" fill="#C9A84C" opacity="0.3"/>

</svg>
```

Export:
```bash
convert -background "#0F4C3A" assets/store/feature_graphic.svg \
  -resize 1024x500 assets/store/feature_graphic.png
```

### 10.2 Screenshots (what each must show)

> **Instruction for Claude:** These are not generated programmatically — they must be captured by running the app on a device or emulator and taking screenshots. Below are the required shots and their captions for the Play Store listing.

| # | Screen to capture | Caption text |
|---|---|---|
| 1 | Home screen showing Asr as next prayer, countdown visible | "Accurate prayer times for your city" |
| 2 | Home screen widget on a dark Android home screen | "Beautiful home screen widget" |
| 3 | Quran reader open on Al-Fatiha, Arabic + English showing | "Full Quran with translation" |
| 4 | Qibla compass screen pointing toward Mecca | "Precise Qibla direction" |
| 5 | Ramadan screen showing Sehri/Iftar countdown | "Complete Ramadan companion" |
| 6 | Theme picker showing all 8 themes | "8 beautiful themes to choose from" |
| 7 | Hijri calendar with Eid marked | "Hijri calendar with Islamic events" |
| 8 | Notification settings screen | "Customise Azaan alerts" |

**Screenshot specs:**
- Minimum: 4 screenshots required
- Recommended: 8 screenshots
- Dimensions: 1080×1920 px (portrait phone)
- Format: PNG or JPEG
- No device frames required (Play Store adds them)

### 10.3 Short promo video (optional but highly recommended)

**30-second script:**
```
0:00–0:05  App icon animating in. "Salah" text fades in.
0:05–0:12  Home screen — prayer countdown ticking live. Azaan notification appearing.
0:12–0:18  Widget being placed on home screen. Showing it update.
0:18–0:24  Quran reader — scrolling through Al-Fatiha in Arabic.
0:24–0:28  Qibla compass rotating to point at Mecca.
0:28–0:30  App icon. "Download Salah — Free". Play Store badge.
```

---

## 11. AI Image Generation Prompts

Use these prompts in Midjourney, DALL·E, or Adobe Firefly if you want photorealistic or painted versions of any illustration.

> **Important:** All AI-generated images must be reviewed before use. Do not use any image that contains:
> - Faces (avoid human face generation for Islamic apps — can be controversial)
> - Copyrighted architecture you do not have rights to
> - Text (AI-generated text is often wrong — add text separately in Figma)

### Onboarding screen 1 (Mosque at dusk)
```
Minimalist flat illustration of a beautiful mosque silhouette at sunset,
deep Islamic green and gold color palette, crescent moon visible in sky,
stars beginning to appear, no faces, clean geometric Islamic art style,
suitable for a mobile app onboarding screen, 360x280 aspect ratio
```

### Onboarding screen 2 (Quran)
```
Flat illustration of an open Quran on a prayer mat,
deep green and gold Islamic colors, soft warm light,
Arabic calligraphy visible on pages, minimalist and modern style,
no human figures, clean lines, app illustration style
```

### Play Store feature graphic background texture
```
Dark Islamic geometric pattern, deep forest green background,
intricate arabesque gold line art, tileable texture,
no text, no figures, suitable for app store banner background,
1024x500 landscape format, high detail
```

### Prayer time notification illustration
```
Minimalist illustration of a phone showing a notification
with a crescent moon icon, soft evening light ambiance,
Islamic green and gold color scheme, flat design style,
no faces, no text on the phone screen
```

---

## 12. Asset Checklist

> **Instruction for Claude:** Before declaring the asset phase complete, verify every item below.

### App icon
- [ ] `assets/icons/app_icon_master.svg` created
- [ ] `assets/icons/app_icon_foreground.svg` created
- [ ] `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- [ ] `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- [ ] `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- [ ] `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- [ ] `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)
- [ ] `assets/icons/play_store_icon_512.png` (512x512, no transparency)
- [ ] `android/app/src/main/res/xml/ic_launcher.xml` (adaptive icon XML)

### Splash screen
- [ ] `assets/images/splash_logo.svg` created
- [ ] `assets/images/splash_logo.png` exported (400x300)
- [ ] `assets/images/splash_logo_android12.png` exported (1152x1152)
- [ ] `flutter_native_splash` config added to `pubspec.yaml`
- [ ] `dart run flutter_native_splash:create` run successfully
- [ ] `lib/features/onboarding/splash_screen.dart` created

### Onboarding illustrations
- [ ] `assets/images/onboarding_1.svg` (Mosque at dawn)
- [ ] `assets/images/onboarding_1.png` exported
- [ ] `assets/images/onboarding_2.svg` (Quran book)
- [ ] `assets/images/onboarding_2.png` exported
- [ ] `assets/images/onboarding_3.svg` (Widget on phone)
- [ ] `assets/images/onboarding_3.png` exported

### Prayer icons
- [ ] `assets/icons/fajr.svg`
- [ ] `assets/icons/dhuhr.svg`
- [ ] `assets/icons/asr.svg`
- [ ] `assets/icons/maghrib.svg`
- [ ] `assets/icons/isha.svg`
- [ ] All 5 exported as 64x64 PNG

### Navigation icons
- [ ] `assets/icons/nav_home.svg`
- [ ] `assets/icons/nav_quran.svg`
- [ ] `assets/icons/nav_qibla.svg`
- [ ] `assets/icons/nav_tasbih.svg`
- [ ] `assets/icons/nav_more.svg`

### Feature illustrations
- [ ] `assets/images/qibla_compass_bg.svg`
- [ ] `assets/images/compass_needle.svg`

### Widget backgrounds
- [ ] `android/app/src/main/res/drawable/widget_bg_midnight.xml`
- [ ] `android/app/src/main/res/drawable/widget_bg_gold.xml`
- [ ] `android/app/src/main/res/drawable/widget_bg_dark.xml`

### Play Store
- [ ] `assets/store/feature_graphic.svg` created
- [ ] `assets/store/feature_graphic.png` exported (1024x500)
- [ ] 8 app screenshots captured from running app
- [ ] Play Store listing text prepared (title, description, keywords)

### Audio assets (download manually)
> These cannot be auto-generated — download from the sources below.
- [ ] `assets/audio/azaan_mecca.mp3` — Download: freesound.org (search "azan mecca")
- [ ] `assets/audio/azaan_egypt.mp3` — Download: freesound.org
- [ ] `assets/audio/azaan_pakistan.mp3` — Download: freesound.org
- [ ] `assets/audio/azaan_turkey.mp3` — Download: freesound.org
- [ ] `assets/audio/azaan_short.mp3` — Any short Islamic tone (30 seconds max)

> **Legal note:** Only use audio files with Creative Commons or royalty-free license.
> Search freesound.org with filter "Creative Commons 0" for completely free-to-use recordings.

### Font assets (download manually)
- [ ] `assets/fonts/Hafs.ttf` — Download: tanzil.net/docs/resources (KFGQPC Hafs font)
- [ ] `assets/fonts/NotoNastaliqUrdu.ttf` — Download: fonts.google.com/noto

---

## Final Notes for Claude

- All SVG files must use `viewBox` and be scalable — never hardcode pixel dimensions inside SVG shapes
- All colors must use the brand palette defined in Section 2 — no off-brand colors
- For Flutter: register all asset folders in `pubspec.yaml` under `flutter.assets`
- Test every icon at small sizes (24px) to ensure it reads clearly — simplify if needed
- The compass needle SVG (`compass_needle.svg`) is rotated dynamically in Flutter using `Transform.rotate` — the needle points up (north) at 0 degrees by default
- Audio files are the only assets that CANNOT be generated by Claude — provide download links to the user and explain the licensing requirement

---

*This ASSETS.md was generated as a companion to CLAUDE.md for the Salah prayer app.
Feed this file to Claude Code at the start of the asset generation session.*
