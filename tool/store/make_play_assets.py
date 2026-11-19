#!/usr/bin/env python3
"""Google Play store graphics for run4share.

Makes, for every listing language:
  - images/icon.png             512 x 512, 32-bit PNG (opaque)
  - images/featureGraphic.png   1024 x 500, 24-bit PNG (no alpha)
  - images/phoneScreenshots/N.png  1080 x 1920, 24-bit PNG, caption + framed screen

Usage (from the repo root, Pillow installed: pip3 install pillow):
  python3 tool/store/make_play_assets.py --shots store/google-play/captures

--shots is a folder holding one sub-folder per locale (en-US, pt-BR, ...)
with 1.png ... 6.png taken on the phone in that language (see
docs/google-play.md, "Screenshots"). A locale without its own folder falls
back to en-US captures. Output goes to store/google-play/metadata/android/.
"""
import argparse
import os

from PIL import Image, ImageDraw, ImageFont, ImageFilter

LOCALES = ["en-US", "pt-BR", "es-ES", "fr-FR", "de-DE"]

TAGLINE = {
    "en-US": "Your workouts, made to share",
    "pt-BR": "Treinos prontos para postar",
    "es-ES": "Entrenos listos para compartir",
    "fr-FR": "Tes séances, prêtes à partager",
    "de-DE": "Workouts, bereit zum Teilen",
}

# One caption per screenshot, in the order of the captures (see the guide).
CAPTIONS = {
    "en-US": ["Make posts like these", "Your photo. Your stats.", "Every stat, your way",
              "Charts from your real data", "Share to Stories, or just the sticker",
              "Pay once. Keep it forever."],
    "pt-BR": ["Crie posts como estes", "Sua foto. Seus números.", "Cada número do seu jeito",
              "Gráficos com seus dados reais", "Poste nos stories ou só o sticker",
              "Pague uma vez. É seu para sempre."],
    "es-ES": ["Crea publicaciones así", "Tu foto. Tus datos.", "Cada dato a tu manera",
              "Gráficos con tus datos reales", "Comparte en historias o solo el sticker",
              "Paga una vez. Tuyo para siempre."],
    "fr-FR": ["Crée des posts comme ceux-ci", "Ta photo. Tes stats.", "Chaque stat à ta façon",
              "Des graphiques de tes vraies données", "Partage en story ou juste le sticker",
              "Paie une fois. À toi pour toujours."],
    "de-DE": ["Posts wie diese", "Dein Foto. Deine Werte.", "Jeder Wert, wie du willst",
              "Diagramme aus echten Daten", "In Stories teilen oder nur den Sticker",
              "Einmal zahlen. Für immer."],
}

INK = (13, 12, 10)
BLUE = (0, 119, 189)
WHITE = (255, 255, 255)
GREY = (201, 196, 189)


def font(root, name, size):
    return ImageFont.truetype(os.path.join(root, "assets/fonts", name), size)


def fit_text(draw, text, path_font, max_w, start, root):
    size = start
    while size > 20:
        f = font(root, path_font, size)
        if draw.textlength(text, font=f) <= max_w:
            return f
        size -= 2
    return font(root, path_font, size)


def wrap(draw, text, f, max_w):
    words, lines, line = text.split(), [], ""
    for w in words:
        test = (line + " " + w).strip()
        if draw.textlength(test, font=f) <= max_w:
            line = test
        else:
            lines.append(line)
            line = w
    lines.append(line)
    return lines


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, img.size[0] - 1, img.size[1] - 1], radius, fill=255)
    return mask


def icon(root, out):
    im = Image.open(os.path.join(root, "assets/icon/icon.png")).convert("RGBA")
    bg = Image.new("RGBA", im.size, INK + (255,))
    bg.alpha_composite(im)
    bg.resize((512, 512), Image.LANCZOS).save(out, optimize=True)


def card(root, file, big, label, w=190):
    h = int(w * 16 / 9)
    im = Image.open(os.path.join(root, "assets/templates", file)).convert("RGB")
    im = im.resize((w, h), Image.LANCZOS)
    d = ImageDraw.Draw(im)
    fb = font(root, "BarlowCondensed-ExtraBoldItalic.ttf", 46)
    fl = font(root, "BarlowCondensed-Bold.ttf", 15)
    d.text((14, 30), label, font=fl, fill=WHITE)
    d.text((12, 48), big, font=fb, fill=WHITE)
    return im.convert("RGBA"), rounded(im, 16)


def feature(root, loc, out):
    W, H = 1024, 500
    g = Image.new("RGB", (W, H), INK)
    # Three template cards, fanned on the right.
    specs = [("summit-day.jpg", "+1,240 M", "CLIMB", -8, (575, 70)),
             ("final-score.jpg", "42:18", "NIGHT RUN", 7, (835, 70)),
             ("sunrise-half.jpg", "21.10 KM", "HALF MARATHON", 0, (700, 40))]
    for file, big, label, angle, (x, y) in specs:
        im, m = card(root, file, big, label, 200)
        im.putalpha(m)
        shadow = Image.new("RGBA", (im.size[0] + 60, im.size[1] + 60), (0, 0, 0, 0))
        ImageDraw.Draw(shadow).rounded_rectangle([30, 40, im.size[0] + 30, im.size[1] + 40], 18, fill=(0, 0, 0, 150))
        shadow = shadow.filter(ImageFilter.GaussianBlur(14)).rotate(angle, expand=True, resample=Image.BICUBIC)
        rot = im.rotate(angle, expand=True, resample=Image.BICUBIC)
        g.paste(shadow, (x - 30 - (shadow.size[0] - im.size[0] - 60) // 2, y - 30), shadow)
        g.paste(rot, (x - (rot.size[0] - im.size[0]) // 2, y - (rot.size[1] - im.size[1]) // 2), rot)
    # Left: icon, name, tagline.
    ic = Image.open(os.path.join(root, "assets/icon/icon.png")).convert("RGBA").resize((112, 112), Image.LANCZOS)
    d = ImageDraw.Draw(g)
    d.rounded_rectangle([62, 118, 177, 233], 28, outline=(61, 58, 54), width=2)
    g.paste(ic, (64, 120), rounded(ic, 26))
    d.text((60, 248), "run", font=font(root, "BarlowCondensed-ExtraBoldItalic.ttf", 92), fill=WHITE)
    x = 60 + d.textlength("run", font=font(root, "BarlowCondensed-ExtraBoldItalic.ttf", 92))
    d.text((x, 248), "4", font=font(root, "BarlowCondensed-ExtraBoldItalic.ttf", 92), fill=(46, 146, 206))
    x += d.textlength("4", font=font(root, "BarlowCondensed-ExtraBoldItalic.ttf", 92))
    d.text((x, 248), "share", font=font(root, "BarlowCondensed-ExtraBoldItalic.ttf", 92), fill=WHITE)
    ft = fit_text(d, TAGLINE[loc], "Inter-Medium.ttf", 470, 32, root)
    d.text((64, 362), TAGLINE[loc], font=ft, fill=GREY)
    g.save(out, optimize=True)


def screenshot(root, loc, n, src, out):
    W, H = 1080, 1920
    g = Image.new("RGB", (W, H), INK)
    d = ImageDraw.Draw(g)
    cap = CAPTIONS[loc][n - 1].upper()
    f = font(root, "BarlowCondensed-ExtraBoldItalic.ttf", 104)
    lines = wrap(d, cap, f, 940)
    if len(lines) > 2:
        f = font(root, "BarlowCondensed-ExtraBoldItalic.ttf", 84)
        lines = wrap(d, cap, f, 940)
    y = 110
    for line in lines:
        w = d.textlength(line, font=f)
        d.text(((W - w) / 2, y), line, font=f, fill=WHITE)
        y += f.size * 0.98
    d.rounded_rectangle([W / 2 - 60, y + 26, W / 2 + 60, y + 38], 6, fill=BLUE)
    shot = Image.open(src).convert("RGB")
    top = int(y + 90)
    sh = H - top - 70
    sw = int(sh * shot.size[0] / shot.size[1])
    if sw > 860:
        sw = 860
        sh = int(sw * shot.size[1] / shot.size[0])
    shot = shot.resize((sw, sh), Image.LANCZOS)
    x = (W - sw) // 2
    d.rounded_rectangle([x - 10, top - 10, x + sw + 9, top + sh + 9], 54, fill=(61, 58, 54))
    g.paste(shot, (x, top), rounded(shot, 46))
    g.save(out, optimize=True)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default=".")
    ap.add_argument("--shots", default="store/google-play/captures")
    ap.add_argument("--out", default="store/google-play/metadata/android")
    a = ap.parse_args()
    for loc in LOCALES:
        img = os.path.join(a.out, loc, "images")
        os.makedirs(os.path.join(img, "phoneScreenshots"), exist_ok=True)
        icon(a.root, os.path.join(img, "icon.png"))
        feature(a.root, loc, os.path.join(img, "featureGraphic.png"))
        folder = os.path.join(a.shots, loc)
        if not os.path.isdir(folder):
            folder = os.path.join(a.shots, "en-US")
        for n in range(1, 7):
            src = os.path.join(folder, f"{n}.png")
            if os.path.exists(src):
                screenshot(a.root, loc, n, src, os.path.join(img, "phoneScreenshots", f"{n}.png"))
        print("done", loc)


if __name__ == "__main__":
    main()
