#!/usr/bin/env python3
"""
Generate PNG app icons using only Python stdlib (no ImageMagick needed).
Creates solid-color placeholder PNGs at the correct sizes.
Replace with proper SVG-exported PNGs when ImageMagick is available.

Usage: python3 generate_icons.py
"""

import zlib
import struct
import os
import math


def make_png(width, height, pixels):
    """pixels: list of (r,g,b,a) tuples, row by row."""
    def chunk(name, data):
        c = struct.pack('>I', len(data)) + name + data
        crc = zlib.crc32(name + data) & 0xFFFFFFFF
        return c + struct.pack('>I', crc)

    sig = b'\x89PNG\r\n\x1a\n'
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    # Use RGBA (color type 6) for transparency support
    ihdr_data = struct.pack('>IIBBBB B', width, height, 8, 6, 0, 0, 0)
    ihdr = chunk(b'IHDR', struct.pack('>II', width, height) + bytes([8, 6, 0, 0, 0]))

    raw_rows = []
    idx = 0
    for y in range(height):
        row = b'\x00'  # filter type None
        for x in range(width):
            r, g, b, a = pixels[idx]
            row += bytes([r, g, b, a])
            idx += 1
        raw_rows.append(row)

    raw = b''.join(raw_rows)
    compressed = zlib.compress(raw, 9)
    idat = chunk(b'IDAT', compressed)
    iend = chunk(b'IEND', b'')
    return sig + ihdr + idat + iend


def draw_icon(width, height):
    """
    Draw a simplified version of the app icon at any size:
    - Deep green background with rounded corners
    - Gold crescent moon
    - Gold star
    """
    pixels = []

    cx, cy = width / 2, height / 2
    # Colors
    BG = (15, 76, 58, 255)       # #0F4C3A
    GOLD = (201, 168, 76, 255)   # #C9A84C
    TRANS = (0, 0, 0, 0)

    # Rounded rect radius ratio (matches SVG: rx=230/1024)
    rr = 0.225

    def in_rounded_rect(x, y, w, h, r):
        rx, ry = r * w, r * h
        if x < rx and y < ry:
            return (x - rx)**2 + (y - ry)**2 <= rx**2
        if x > w - rx and y < ry:
            return (x - (w - rx))**2 + (y - ry)**2 <= rx**2
        if x < rx and y > h - ry:
            return (x - rx)**2 + (y - (h - ry))**2 <= rx**2
        if x > w - rx and y > h - ry:
            return (x - (w - rx))**2 + (y - (h - ry))**2 <= rx**2
        return True

    # Crescent: outer circle at (0.449, 0.469) r=0.225, inner at (0.547, 0.430) r=0.195
    # Scale from 1024 viewBox
    def crescent(x, y):
        px, py = x / width, y / height
        outer = (px - 0.449)**2 + (py - 0.469)**2 <= 0.2246**2
        inner = (px - 0.547)**2 + (py - 0.430)**2 <= 0.1953**2
        return outer and not inner

    # Star: 5-pointed star at (0.703, 0.254), half-width ~0.085
    # Points from SVG scaled to 0..1: center ~(720/1024, 263/1024)
    star_points_norm = [
        (720/1024, 185/1024),
        (742/1024, 245/1024),
        (806/1024, 245/1024),
        (756/1024, 280/1024),
        (775/1024, 342/1024),
        (720/1024, 308/1024),
        (665/1024, 342/1024),
        (684/1024, 280/1024),
        (634/1024, 245/1024),
        (698/1024, 245/1024),
    ]

    def sign(p1, p2, p3):
        return (p1[0]-p3[0])*(p2[1]-p3[1]) - (p2[0]-p3[0])*(p1[1]-p3[1])

    def in_triangle(pt, v1, v2, v3):
        d1 = sign(pt, v1, v2)
        d2 = sign(pt, v2, v3)
        d3 = sign(pt, v3, v1)
        has_neg = (d1 < 0) or (d2 < 0) or (d3 < 0)
        has_pos = (d1 > 0) or (d2 > 0) or (d3 > 0)
        return not (has_neg and has_pos)

    def in_star(x, y):
        px, py = x / width, y / height
        pt = (px, py)
        # Fan triangulate from center
        cx_s, cy_s = star_points_norm[0][0], sum(p[1] for p in star_points_norm) / 10
        center = (720/1024, (185+342)/2/1024)
        n = len(star_points_norm)
        for i in range(n):
            v1 = star_points_norm[i]
            v2 = star_points_norm[(i+1) % n]
            if in_triangle(pt, center, v1, v2):
                return True
        return False

    for y in range(height):
        for x in range(width):
            if not in_rounded_rect(x, y, width, height, rr):
                pixels.append(TRANS)
            elif crescent(x, y) or in_star(x, y):
                pixels.append(GOLD)
            else:
                pixels.append(BG)

    return pixels


def save_png(path, width, height):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pixels = draw_icon(width, height)
    data = make_png(width, height, pixels)
    with open(path, 'wb') as f:
        f.write(data)
    print(f"  Written: {path} ({width}x{height})")


BASE = os.path.dirname(os.path.abspath(__file__))
RES = os.path.join(BASE, 'android', 'app', 'src', 'main', 'res')

print("Generating Android launcher icons...")
save_png(os.path.join(RES, 'mipmap-mdpi',    'ic_launcher.png'),  48,  48)
save_png(os.path.join(RES, 'mipmap-hdpi',    'ic_launcher.png'),  72,  72)
save_png(os.path.join(RES, 'mipmap-xhdpi',   'ic_launcher.png'),  96,  96)
save_png(os.path.join(RES, 'mipmap-xxhdpi',  'ic_launcher.png'), 144, 144)
save_png(os.path.join(RES, 'mipmap-xxxhdpi', 'ic_launcher.png'), 192, 192)

print("\nGenerating adaptive icon layers...")
# Background: solid green, no transparency needed
def solid_png(path, w, h, color):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    pixels = [color] * (w * h)
    data = make_png(w, h, pixels)
    with open(path, 'wb') as f:
        f.write(data)
    print(f"  Written: {path} ({w}x{h})")

solid_png(
    os.path.join(RES, 'mipmap-xxxhdpi', 'ic_launcher_background.png'),
    432, 432, (15, 76, 58, 255)
)
save_png(
    os.path.join(RES, 'mipmap-xxxhdpi', 'ic_launcher_foreground.png'),
    432, 432
)

print("\nGenerating Play Store icon (512x512)...")
save_png(os.path.join(BASE, 'assets', 'icons', 'play_store_icon_512.png'), 512, 512)

print("\nDone! All icons generated.")
print("\nNOTE: These are Python-rendered approximations of the SVG design.")
print("For pixel-perfect output, install ImageMagick and run:")
print("  sudo apt-get install imagemagick")
print("  Then re-run the convert commands from ASSETS.md Section 3.2")
