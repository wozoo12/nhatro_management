#!/usr/bin/env python3
"""ABC Design — nhập tiêu đề, tự đối chiếu quy tắc thương hiệu + thiết kế, xuất ảnh LOZIDO.

Cách dùng:
    python src/abc_design.py "Hướng dẫn chốt điện nước cuối tháng"
    python src/abc_design.py "Tạo hóa đơn VietQR trong 30 giây" --format all --sub "Gửi Zalo cho khách ngay trên app"
"""
import argparse, hashlib, json, random, re, sys, unicodedata
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SS = 2  # supersampling để cạnh bo góc mịn


def load(name):
    return json.loads((ROOT / "rules" / name).read_text(encoding="utf-8"))


def norm(s):
    s = unicodedata.normalize("NFD", s.lower().replace("đ", "d"))
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    return re.sub(r"[^a-z0-9 ]", " ", s)


def rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def lum(c):
    def f(v):
        v /= 255
        return v / 12.92 if v <= 0.03928 else ((v + 0.055) / 1.055) ** 2.4
    r, g, b = map(f, c)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def contrast(a, b):
    hi, lo = sorted((lum(a), lum(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)


def font(brand, role, size):
    p = ROOT / "assets" / "fonts" / brand["fonts"][role]
    return ImageFont.truetype(str(p), int(size * SS))


# ---------- Bước 1: làm sạch + kiểm tra tiêu đề ----------
def sanitize(title, brand, design, log):
    t = unicodedata.normalize("NFC", title)
    clean = re.sub(r"[\U0001F000-\U0001FAFF\u2600-\u27BF]", "", t)
    if clean != t:
        log.append(("fix", "Đã bỏ emoji khỏi tiêu đề"))
    t = re.sub(r"\s+", " ", clean).strip()
    t2 = re.sub(r"([!?.])\1+", r"\1", t)
    if t2 != t:
        log.append(("fix", "Đã gộp dấu câu lặp"))
    t = t2
    letters = [c for c in t if c.isalpha()]
    if len(letters) > 3 and all(c.isupper() for c in letters):
        t = t[:1].upper() + t[1:].lower()
        log.append(("fix", "Tiêu đề viết HOA toàn bộ → đổi về viết hoa đầu câu"))
    padded = f" {norm(t)} "
    for w in brand["voice"]["forbidden"]:
        if f" {norm(w).strip()} " in padded:
            log.append(("warn", f"Từ cường điệu trái giọng thương hiệu: “{w}”"))
    if not t:
        log.append(("error", "Tiêu đề trống"))
    elif len(t) > design["title"]["max_chars"]:
        log.append(("error", f"Tiêu đề dài {len(t)} ký tự, tối đa {design['title']['max_chars']}. Hãy rút gọn."))
    else:
        log.append(("ok", f"Độ dài tiêu đề {len(t)}/{design['title']['max_chars']} ký tự"))
    return t


# ---------- Bước 2: chọn chủ đề từ tiêu đề ----------
def detect_theme(title, themes, forced=None):
    if forced:
        return forced, []
    t = f" {norm(title)} "
    best, hits_best = "general", []
    for name, th in themes["themes"].items():
        hits = [k for k in th["keywords"] if f" {k} " in t]
        if len(hits) > len(hits_best):
            best, hits_best = name, hits
    return best, hits_best


# ---------- Bước 3: dàn chữ ----------
def wrap(text, f, maxw):
    lines, cur = [], ""
    for w in text.split():
        trial = (cur + " " + w).strip()
        if f.getlength(trial) <= maxw:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def balanced(text, f, maxw):
    base = wrap(text, f, maxw)
    n, w, best = len(base), maxw, base
    while w > maxw * 0.55:
        w -= 8
        cand = wrap(text, f, w)
        if len(cand) != n or max(f.getlength(x) for x in cand) > maxw:
            break
        best = cand
    return best


def fit_title(text, brand, cfg, maxw, maxh):
    for size in range(cfg["font_size_max"], cfg["font_size_min"] - 1, -2):
        f = font(brand, "title", size)
        lines = balanced(text, f, maxw * SS)
        if len(lines) <= cfg["max_lines"] and len(lines) * size * cfg["line_height"] <= maxh:
            return size, lines, f
    return None


# ---------- Bước 4: vẽ ----------
def rrect(d, box, r, fill):
    d.rounded_rectangle([int(v * SS) for v in box], radius=int(r * SS), fill=fill)


def render(title, sub, theme_name, theme, fmt, brand, design, log):
    W, H = design["formats"][fmt]
    m = design["margin"]
    C = {k: rgb(v) for k, v in brand["colors"].items()}
    img = Image.new("RGB", (W * SS, H * SS), C["paper"])
    d = ImageDraw.Draw(img)

    # Logo: 4 ô phòng, 1 ô vàng = phòng trống
    s, g = 22, 6
    for i in range(4):
        x = m + (i % 2) * (s + g)
        y = m + (i // 2) * (s + g)
        rrect(d, (x, y, x + s, y + s), 6, C["accent"] if i == 3 else C["ink"])
    d.text(((m + 2 * s + g + 18) * SS, (m + s + g / 2) * SS), brand["name"],
           font=font(brand, "title", 34), fill=C["ink"], anchor="lm")

    # Vùng tiêu đề
    grid_top = int(H * design["grid"]["top_ratio"][fmt])
    top = m + 2 * s + g + 70
    bottom = grid_top - 60
    sub_h = 0
    sub_lines = []
    if sub:
        sf = font(brand, "body", design["sub"]["font_size"])
        sub_lines = wrap(sub, sf, (W - 2 * m - 120) * SS)[: design["sub"]["max_lines"]]
        sub_h = len(sub_lines) * design["sub"]["font_size"] * 1.4 + 24
    fit = fit_title(title, brand, design["title"], W - 2 * m, bottom - top - sub_h)
    if not fit:
        log.append(("error", "Tiêu đề không vừa khung ở cỡ chữ tối thiểu. Hãy rút gọn."))
        return None
    size, lines, tf = fit
    log.append(("ok", f"Dàn chữ: {len(lines)} dòng, cỡ {size}px, căn trái, lề {m}px"))
    step = size * design["title"]["line_height"]
    for i, ln in enumerate(lines):
        d.text((m * SS, (top + i * step) * SS), ln, font=tf, fill=C["ink"], anchor="la")
    if sub_lines:
        y0 = top + len(lines) * step + 24
        sf = font(brand, "body", design["sub"]["font_size"])
        for i, ln in enumerate(sub_lines):
            d.text((m * SS, (y0 + i * design["sub"]["font_size"] * 1.4) * SS), ln, font=sf, fill=C["muted"], anchor="la")
        cm = contrast(C["muted"], C["paper"])
        log.append(("ok" if cm >= design["contrast_min"] else "error", f"Tương phản phụ đề {cm:.1f}:1"))

    ct = contrast(C["ink"], C["paper"])
    log.append(("ok" if ct >= design["contrast_min"] else "error", f"Tương phản tiêu đề {ct:.1f}:1"))

    # Lưới phòng tràn mép
    gc = design["grid"]
    tw, th, gap, rad = gc["tile_w"], gc["tile_h"], gc["gap"], gc["radius"]
    cols = int((W - m) // (tw + gap)) + 2
    rows = int((H - grid_top) // (th + gap)) + 2
    rng = random.Random(int(hashlib.md5(title.encode()).hexdigest(), 16))
    keys = list(theme["weights"])
    hero = keys[0]
    nf, nl = font(brand, "title", 40), font(brand, "label", 24)
    min_c = 21.0
    for r in range(rows):
        for c in range(cols):
            st = hero if (r == 0 and c == 0) else rng.choices(keys, [theme["weights"][k] for k in keys])[0]
            info = brand["status"][st]
            col = rgb(info["color"])
            x, y = m + c * (tw + gap), grid_top + r * (th + gap)
            rrect(d, (x, y, x + tw, y + th), rad, col)
            txt = C["white"] if contrast(col, C["white"]) >= contrast(col, C["ink"]) else C["ink"]
            min_c = min(min_c, contrast(col, txt))
            floor = rows - r
            d.text(((x + 26) * SS, (y + 24) * SS), f"P.{floor}{c + 1:02d}", font=nf, fill=txt, anchor="la")
            d.text(((x + 26) * SS, (y + th - 26) * SS), info["label"], font=nl, fill=txt, anchor="ls")
    log.append(("ok" if min_c >= design["contrast_min"] else "error",
                f"Tương phản chữ trên ô phòng thấp nhất {min_c:.1f}:1"))
    return img.resize((W, H), Image.LANCZOS)


def main():
    brand, design, themes = load("brand.json"), load("design.json"), load("themes.json")
    ap = argparse.ArgumentParser(description="ABC Design – tạo ảnh LOZIDO từ tiêu đề")
    ap.add_argument("title", help="Tiêu đề bài viết")
    ap.add_argument("--sub", default="", help="Dòng phụ (tuỳ chọn)")
    ap.add_argument("--format", default="post", choices=[*design["formats"], "all"])
    ap.add_argument("--theme", choices=list(themes["themes"]), help="Ép chủ đề thay vì tự nhận diện")
    ap.add_argument("--out", default=str(ROOT / "output"))
    a = ap.parse_args()

    log = []
    title = sanitize(a.title, brand, design, log)
    sub = re.sub(r"\s+", " ", a.sub).strip()
    if len(sub) > design["sub"]["max_chars"]:
        log.append(("error", f"Phụ đề dài quá {design['sub']['max_chars']} ký tự"))
    theme_name, hits = detect_theme(title, themes, a.theme)
    theme = themes["themes"][theme_name]
    log.append(("ok", f"Chủ đề: {theme_name}" + (f" (khớp: {', '.join(hits)})" if hits else "")))

    outs = []
    if not any(l == "error" for l, _ in log):
        slug = "-".join(norm(title).split())[:50] or "untitled"
        Path(a.out).mkdir(parents=True, exist_ok=True)
        for fmt in (design["formats"] if a.format == "all" else [a.format]):
            im = render(title, sub, theme_name, theme, fmt, brand, design, log)
            if im:
                p = Path(a.out) / f"{slug}_{fmt}.png"
                im.save(p, optimize=True)
                outs.append(str(p))

    icon = {"ok": "✔", "fix": "✎", "warn": "⚠", "error": "✖"}
    print(f"\nTiêu đề: {title}\n")
    for l, msg in log:
        print(f" {icon[l]} {msg}")
    failed = any(l == "error" for l, _ in log)
    if outs:
        Path(outs[0]).with_suffix(".report.json").write_text(
            json.dumps({"title": title, "theme": theme_name, "checks": log, "files": outs}, ensure_ascii=False, indent=2),
            encoding="utf-8")
        print("\nẢnh đã tạo:")
        for o in outs:
            print("  ", o)
    sys.exit(2 if failed else 0)


if __name__ == "__main__":
    main()
