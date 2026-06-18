"""Generates the app icon master (assets/icon/app_icon.png).

A rounded-square green gradient with a bold white "</>" glyph, drawn as vector
shapes (not text) so it stays crisp at small sizes. Re-run after editing:

    /tmp/iconvenv/bin/python tool/generate_icon.py

Then regenerate platform icons with:  dart run flutter_launcher_icons
"""

from PIL import Image, ImageDraw

SIZE = 1024
MARGIN = 96            # transparent breathing room around the tile
RADIUS = 220           # rounded-square corner radius
TOP = (156, 204, 101)  # light green 400  (#9CCC65)
BOTTOM = (85, 139, 47)  # light green 800  (#558B2F)
STROKE = 70            # glyph line thickness


def gradient(w, h, top, bottom):
    grad = Image.new("RGB", (w, h))
    px = grad.load()
    for y in range(h):
        t = y / (h - 1)
        px_row = tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        for x in range(w):
            px[x, y] = px_row
    return grad


def rounded_mask(w, h, box, radius):
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle(box, radius=radius, fill=255)
    return mask


def thick_polyline(draw, points, width, fill):
    """Polyline with rounded joins and caps."""
    draw.line(points, fill=fill, width=width, joint="curve")
    r = width / 2
    for x, y in points:
        draw.ellipse((x - r, y - r, x + r, y + r), fill=fill)


def main():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

    # Gradient tile clipped to a rounded square.
    box = (MARGIN, MARGIN, SIZE - MARGIN, SIZE - MARGIN)
    tile = gradient(SIZE, SIZE, TOP, BOTTOM)
    img.paste(tile, (0, 0), rounded_mask(SIZE, SIZE, box, RADIUS))

    draw = ImageDraw.Draw(img)
    white = (255, 255, 255, 255)

    # "<"  chevron
    thick_polyline(draw, [(430, 392), (300, 512), (430, 632)], STROKE, white)
    # ">"  chevron
    thick_polyline(draw, [(594, 392), (724, 512), (594, 632)], STROKE, white)
    # "/"  slash between them
    thick_polyline(draw, [(560, 356), (464, 668)], STROKE, white)

    out = "assets/icon/app_icon.png"
    img.save(out)
    print(f"wrote {out}")


if __name__ == "__main__":
    main()
