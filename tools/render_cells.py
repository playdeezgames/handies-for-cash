#!/usr/bin/env python3
"""Renders .cells dumps (from odin/shots_test.odin) to PNG with the DINOBYTE sheet, as the page does."""
import sys
from PIL import Image

SHEET = "assets/dinobyte/dbyte_1x.png"
BG = (11, 11, 18)
# Same order as Ink in odin/screen.odin and PALETTE in web/index.html.
PALETTE = [(172, 172, 145), (255, 255, 255), (255, 215, 95), (95, 215, 95),
           (255, 95, 95), (128, 128, 128), (95, 215, 215), (215, 95, 215)]
CW, CH = 6, 8


def tinted(sheet, color):
    out = Image.new("RGBA", sheet.size, color + (0,))
    a = sheet.getchannel("A")
    out.putalpha(a)
    return out


def render(src, dst, scale):
    data = open(src, "rb").read()
    cols, rows = data[0], data[1]
    sheet = Image.open(SHEET).convert("RGBA")
    sheets = [tinted(sheet, c) for c in PALETTE]
    bg_sheet = tinted(sheet, BG)
    img = Image.new("RGB", (cols * CW, rows * CH), BG)
    for r in range(rows):
        for c in range(cols):
            i = 2 + (r * cols + c) * 2
            ch, attr = data[i], data[i + 1]
            ink = attr & 15
            s = sheets[ink] if ink < len(sheets) else sheets[0]
            if attr & 0x80:
                img.paste(PALETTE[ink], (c * CW, r * CH, c * CW + CW, r * CH + CH))
                s = bg_sheet
            if ch not in (0, 32):
                g = s.crop(((ch % 16) * CW, (ch // 16) * CH, (ch % 16) * CW + CW, (ch // 16) * CH + CH))
                img.paste(g, (c * CW, r * CH), g)
    img = img.resize((img.width * scale, img.height * scale), Image.NEAREST)
    img.save(dst)
    print("wrote", dst, img.size)


if __name__ == "__main__":
    render(sys.argv[1], sys.argv[2], int(sys.argv[3]) if len(sys.argv) > 3 else 3)
