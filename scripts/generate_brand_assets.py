#!/usr/bin/env python3
"""
Generate clean, anti-aliased brand source images for the Salah app.

Renders the app icon (matching assets/icons/app_icon_master.svg) using
supersampling for smooth edges, then writes 1024x1024 PNG sources that
flutter_launcher_icons and flutter_native_splash consume to produce all
platform-specific densities.

Outputs (assets/icons/generated/):
  icon_master_1024.png      - full launcher icon (green rounded square + mark)
  icon_foreground_1024.png  - adaptive-icon foreground (mark only, safe-zone padded)
  splash_logo_1024.png      - native splash mark (gold mark on transparent)

Usage: python scripts/generate_brand_assets.py
"""

import os
from PIL import Image, ImageDraw

# --- Design tokens (from app_icon_master.svg) -------------------------------
BG = (15, 76, 58, 255)        # #0F4C3A deep green
GOLD = (201, 168, 76, 255)    # #C9A84C
TRANSPARENT = (0, 0, 0, 0)

SS = 4                         # supersampling factor for anti-aliasing
SIZE = 1024
S = SIZE * SS                  # working canvas size

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(BASE, "assets", "icons", "generated")


def _scaled(coords):
    """Scale a list of (x,y) in the 1024 viewBox to the working canvas."""
    return [(x * SS, y * SS) for x, y in coords]


def build_mark():
    """Build the crescent + star mark on a transparent supersampled canvas.

    Returns an RGBA image (S x S) with a gold mark and transparent background.
    The inner crescent cut is genuinely transparent (alpha 0), so the mark
    composites correctly over any background.
    """
    mark = Image.new("RGBA", (S, S), TRANSPARENT)
    d = ImageDraw.Draw(mark)

    # Crescent: outer gold circle, then carve the inner circle back to transparent.
    ox, oy, orr = 500 * SS, 480 * SS, 230 * SS
    d.ellipse([ox - orr, oy - orr, ox + orr, oy + orr], fill=GOLD)
    ix, iy, irr = 560 * SS, 440 * SS, 200 * SS
    d.ellipse([ix - irr, iy - irr, ix + irr, iy + irr], fill=TRANSPARENT)

    # Five-pointed star (polygon points from the master SVG).
    star = _scaled([
        (770, 145), (788, 196), (841, 197), (799, 229), (814, 281),
        (770, 250), (726, 281), (742, 229), (699, 197), (752, 196),
    ])
    d.polygon(star, fill=GOLD)
    return mark


def rounded_mask(size, radius):
    """Return an L-mode rounded-rectangle mask at the working resolution."""
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1],
                                           radius=radius, fill=255)
    return mask


def autocrop(img):
    """Crop an RGBA image to its non-transparent bounding box."""
    bbox = img.getbbox()
    return img.crop(bbox) if bbox else img


def place_centered(content, canvas_size, fill_ratio):
    """Center `content` (RGBA) inside a transparent square, scaled so its
    longest side spans `fill_ratio` of the canvas."""
    content = autocrop(content)
    target = int(canvas_size * fill_ratio)
    w, h = content.size
    scale = target / max(w, h)
    content = content.resize((max(1, round(w * scale)), max(1, round(h * scale))),
                             Image.LANCZOS)
    canvas = Image.new("RGBA", (canvas_size, canvas_size), TRANSPARENT)
    cw, ch = content.size
    canvas.alpha_composite(content, ((canvas_size - cw) // 2, (canvas_size - ch) // 2))
    return canvas


def save(img, name):
    out = img.resize((SIZE, SIZE), Image.LANCZOS) if img.size != (SIZE, SIZE) else img
    path = os.path.join(OUT_DIR, name)
    out.save(path)
    print(f"  wrote {os.path.relpath(path, BASE)} ({out.size[0]}x{out.size[1]})")


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    mark = build_mark()

    # 1) Master launcher icon: green rounded square + centered mark (~62%).
    bg = Image.new("RGBA", (S, S), TRANSPARENT)
    bg.paste(Image.new("RGBA", (S, S), BG), (0, 0), rounded_mask(S, 230 * SS))
    centered_mark = place_centered(mark, S, 0.62)
    master = Image.alpha_composite(bg, centered_mark)
    save(master, "icon_master_1024.png")

    # 2) Adaptive foreground: mark only, padded into the inner ~60% safe zone
    #    (adaptive icons crop the outer ~25%, so keep the mark well inside).
    foreground = place_centered(mark, S, 0.56)
    save(foreground, "icon_foreground_1024.png")

    # 3) Native splash mark: gold mark on transparent, comfortably sized.
    splash = place_centered(mark, S, 0.46)
    save(splash, "splash_logo_1024.png")

    print("Done.")


if __name__ == "__main__":
    main()
