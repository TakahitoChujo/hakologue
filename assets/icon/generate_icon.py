#!/usr/bin/env python3
"""
Hakologue App Icon Generator v3
Generates a 1024x1024 flat-design app icon featuring:
- Blue gradient background
- White cardboard box silhouette with open flaps
- Small QR code pattern on the box (below tape)
- Orange accent tape
- Scan corner markers around QR
"""

from PIL import Image, ImageDraw, ImageFilter
import math
import os


SIZE = 1024
PRIMARY = (74, 144, 217)        # #4A90D9
PRIMARY_LIGHT = (115, 175, 240) # lighter center for gradient
EDGE_COLOR = (45, 100, 170)     # darker edges
ACCENT = (245, 166, 35)         # #F5A623 Orange
WHITE = (255, 255, 255)


def lerp_color(c1, c2, t):
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))


def draw_radial_gradient(img, center, radius, color_center, color_edge):
    pixels = img.load()
    cx, cy = center
    for y in range(img.height):
        for x in range(img.width):
            dist = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            t = min(dist / radius, 1.0)
            t = t ** 1.5
            pixels[x, y] = lerp_color(color_center, color_edge, t)


def draw_rounded_rect(draw, bbox, radius, fill):
    x0, y0, x1, y1 = bbox
    r = min(radius, (x1 - x0) // 2, (y1 - y0) // 2)
    if r <= 0:
        draw.rectangle(bbox, fill=fill)
        return
    draw.rectangle([x0 + r, y0, x1 - r, y1], fill=fill)
    draw.rectangle([x0, y0 + r, x1, y1 - r], fill=fill)
    draw.pieslice([x0, y0, x0 + 2 * r, y0 + 2 * r], 180, 270, fill=fill)
    draw.pieslice([x1 - 2 * r, y0, x1, y0 + 2 * r], 270, 360, fill=fill)
    draw.pieslice([x0, y1 - 2 * r, x0 + 2 * r, y1], 90, 180, fill=fill)
    draw.pieslice([x1 - 2 * r, y1 - 2 * r, x1, y1], 0, 90, fill=fill)


def draw_qr_pattern(draw, cx, cy, cell_size, gap, color):
    """Draw a stylized QR code pattern (7x7 with finder patterns)."""
    pattern = [
        [1, 1, 1, 0, 1, 1, 1],
        [1, 0, 1, 0, 1, 0, 1],
        [1, 1, 1, 0, 1, 1, 1],
        [0, 0, 0, 1, 0, 0, 0],
        [1, 1, 1, 0, 1, 0, 1],
        [1, 0, 1, 0, 0, 1, 0],
        [1, 1, 1, 0, 1, 0, 1],
    ]

    rows = len(pattern)
    cols = len(pattern[0])
    total_w = cols * cell_size + (cols - 1) * gap
    total_h = rows * cell_size + (rows - 1) * gap
    start_x = cx - total_w // 2
    start_y = cy - total_h // 2

    for r in range(rows):
        for c in range(cols):
            if pattern[r][c]:
                sx = start_x + c * (cell_size + gap)
                sy = start_y + r * (cell_size + gap)
                cr = max(2, cell_size // 5)
                draw_rounded_rect(draw, (sx, sy, sx + cell_size, sy + cell_size), cr, fill=color)

    return total_w, total_h


def generate_icon():
    # === BACKGROUND ===
    bg = Image.new("RGB", (SIZE, SIZE), PRIMARY)
    draw_radial_gradient(bg, (SIZE // 2, SIZE // 2 - 30), SIZE * 0.72, PRIMARY_LIGHT, EDGE_COLOR)
    img = bg.convert("RGBA")

    # === SUBTLE BACKGROUND CIRCLE ===
    circle_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    circle_draw = ImageDraw.Draw(circle_layer)
    cr = 370
    ccx, ccy = SIZE // 2, SIZE // 2 + 5
    circle_draw.ellipse(
        [ccx - cr, ccy - cr, ccx + cr, ccy + cr],
        fill=(255, 255, 255, 16),
    )
    img = Image.alpha_composite(img, circle_layer)

    # === BOX DIMENSIONS ===
    box_w = 440
    box_h = 360
    cx = SIZE // 2
    cy = SIZE // 2 + 50

    bx0 = cx - box_w // 2
    by0 = cy - box_h // 2
    bx1 = cx + box_w // 2
    by1 = cy + box_h // 2

    # === DROP SHADOW (blurred) ===
    shadow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    sh_off = 10
    draw_rounded_rect(
        shadow_draw,
        (bx0 + sh_off, by0 + sh_off, bx1 + sh_off, by1 + sh_off + 6),
        20,
        fill=(0, 0, 0, 35),
    )
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(radius=8))
    img = Image.alpha_composite(img, shadow_layer)

    # === BOX BODY ===
    box_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    box_draw = ImageDraw.Draw(box_layer)
    draw_rounded_rect(box_draw, (bx0, by0, bx1, by1), 20, fill=WHITE + (255,))
    img = Image.alpha_composite(img, box_layer)

    # === BOX FLAPS (open) ===
    flap_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    flap_draw = ImageDraw.Draw(flap_layer)

    flap_h = int(box_w * 0.20)
    mid_x = cx
    flap_gap = int(box_w * 0.025)

    # Left flap
    left_flap = [
        (bx0, by0),
        (bx0 - int(box_w * 0.05), by0 - flap_h),
        (mid_x - flap_gap, by0 - flap_h + int(flap_h * 0.12)),
        (mid_x - flap_gap, by0),
    ]
    flap_draw.polygon(left_flap, fill=WHITE + (255,))

    # Right flap
    right_flap = [
        (bx1, by0),
        (bx1 + int(box_w * 0.05), by0 - flap_h),
        (mid_x + flap_gap, by0 - flap_h + int(flap_h * 0.12)),
        (mid_x + flap_gap, by0),
    ]
    flap_draw.polygon(right_flap, fill=WHITE + (255,))

    # Subtle fold lines at flap base
    flap_draw.line([(bx0, by0), (mid_x - flap_gap, by0)], fill=(200, 210, 220, 80), width=3)
    flap_draw.line([(mid_x + flap_gap, by0), (bx1, by0)], fill=(200, 210, 220, 80), width=3)

    img = Image.alpha_composite(img, flap_layer)

    # === TAPE (Orange accent) ===
    tape_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    tape_draw = ImageDraw.Draw(tape_layer)

    tape_w = 26
    tape_x0 = cx - tape_w // 2
    tape_x1 = cx + tape_w // 2

    # Tape on flaps
    tape_top = by0 - flap_h + int(flap_h * 0.30)
    tape_draw.rectangle([tape_x0, tape_top, tape_x1, by0], fill=ACCENT + (240,))

    # Tape on box body (top to ~40% down)
    tape_bottom = by0 + int((by1 - by0) * 0.40)
    tape_draw.rectangle([tape_x0, by0, tape_x1, tape_bottom], fill=ACCENT + (240,))

    img = Image.alpha_composite(img, tape_layer)

    # === HORIZONTAL FOLD LINE ===
    fold_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    fold_draw = ImageDraw.Draw(fold_layer)
    fold_y = by0 + 3
    fold_draw.rectangle([bx0 + 10, fold_y, bx1 - 10, fold_y + 2], fill=(195, 205, 218, 90))
    img = Image.alpha_composite(img, fold_layer)

    # === QR CODE PATTERN (positioned below the tape) ===
    qr_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    qr_draw = ImageDraw.Draw(qr_layer)

    qr_cx = cx
    qr_cy = tape_bottom + int((by1 - tape_bottom) * 0.52)  # centered in area below tape
    cell_size = 18
    cell_gap = 3
    qr_color = (74, 144, 217, 155)

    qr_w, qr_h = draw_qr_pattern(qr_draw, qr_cx, qr_cy, cell_size, cell_gap, qr_color)
    img = Image.alpha_composite(img, qr_layer)

    # === SCAN CORNER MARKERS (orange L-shaped brackets around QR) ===
    corner_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    corner_draw = ImageDraw.Draw(corner_layer)

    pad = 16
    qr_half_w = qr_w // 2 + pad
    qr_half_h = qr_h // 2 + pad
    ql = qr_cx - qr_half_w
    qt = qr_cy - qr_half_h
    qr_ = qr_cx + qr_half_w
    qb = qr_cy + qr_half_h

    cl = 24   # corner arm length
    ct = 4    # corner arm thickness
    cc = ACCENT + (190,)

    # Top-left
    corner_draw.rectangle([ql, qt, ql + cl, qt + ct], fill=cc)
    corner_draw.rectangle([ql, qt, ql + ct, qt + cl], fill=cc)
    # Top-right
    corner_draw.rectangle([qr_ - cl, qt, qr_, qt + ct], fill=cc)
    corner_draw.rectangle([qr_ - ct, qt, qr_, qt + cl], fill=cc)
    # Bottom-left
    corner_draw.rectangle([ql, qb - ct, ql + cl, qb], fill=cc)
    corner_draw.rectangle([ql, qb - cl, ql + ct, qb], fill=cc)
    # Bottom-right
    corner_draw.rectangle([qr_ - cl, qb - ct, qr_, qb], fill=cc)
    corner_draw.rectangle([qr_ - ct, qb - cl, qr_, qb], fill=cc)

    img = Image.alpha_composite(img, corner_layer)

    # === FLATTEN AND SAVE ===
    final = img.convert("RGB")
    out_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "app_icon.png")
    final.save(out_path, "PNG")
    print(f"Icon saved to: {out_path}")
    print(f"Size: {final.size}")

    # Also generate a small preview to check visibility
    small = final.resize((64, 64), Image.LANCZOS)
    small_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "app_icon_64.png")
    small.save(small_path, "PNG")
    print(f"Small preview saved to: {small_path}")

    return out_path


if __name__ == "__main__":
    generate_icon()
