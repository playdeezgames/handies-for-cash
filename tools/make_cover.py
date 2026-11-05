#!/usr/bin/env python3
"""Draws the 630 by 500 itch.io cover from the game's own font sheet (DINOBYTE, unmodified)."""
import sys
from PIL import Image

SHEET = "assets/dinobyte/dbyte_1x.png"
OUT = sys.argv[1] if len(sys.argv) > 1 else "assets/cover.png"
BG = (11, 11, 18)
INK = {
    "beige": (172, 172, 145),
    "white": (255, 255, 255),
    "yellow": (255, 215, 95),
    "green": (95, 215, 95),
    "red": (255, 95, 95),
    "gray": (128, 128, 128),
    "dim": (60, 60, 72),
    "cyan": (95, 215, 215),
}

sheet = Image.open(SHEET).convert("RGBA")
W, H = 630, 500
img = Image.new("RGB", (W, H), BG)


def glyph(code, color, scale):
    cx, cy = (code % 16) * 6, (code // 16) * 8
    cell = sheet.crop((cx, cy, cx + 6, cy + 8))
    out = Image.new("RGBA", (6, 8), color + (0,))
    out.putalpha(cell.getchannel("A"))
    return out.resize((6 * scale, 8 * scale), Image.NEAREST)


def put(x, y, s, color, scale):
    for ch in s:
        code = ch if isinstance(ch, int) else ord(ch)
        g = glyph(code, INK[color], scale)
        img.paste(g, (x, y), g)
        x += 6 * scale


def centered(y, s, color, scale):
    put((W - len(s) * 6 * scale) // 2, y, s, color, scale)


# Title
centered(26, "HANDIES", "yellow", 9)
centered(108, "FOR CASH!", "yellow", 6)

# A dark alley: brick walls above and below, a bin, the two of you and the money.
S = 5
cols = W // (6 * S)
left = (W - cols * 6 * S) // 2
scene_y = 190
for i in range(cols):
    put(left + i * 6 * S, scene_y, [0xB1], "dim", S)
    put(left + i * 6 * S, scene_y + 16 * S, [0xB1], "dim", S)
row = scene_y + 8 * S
put(left + 2 * 6 * S, row, [0xDC], "gray", S)  # the bin
put(left + 8 * 6 * S, row, [0x02], "white", S)  # you
put(left + 10 * 6 * S, row, [0x01], "beige", S)  # John
put(left + 15 * 6 * S, row, "$", "green", S)
put(left + 17 * 6 * S, row, "$", "green", S)
put(left + 19 * 6 * S, row, "$", "green", S)

# Tagline and credits
centered(372, "In a dark alley.", "white", 3)
centered(404, "Five cash a time.", "white", 3)
centered(452, "TheGrumpyGameDev", "beige", 2)
img.save(OUT)
print("wrote", OUT, img.size)
