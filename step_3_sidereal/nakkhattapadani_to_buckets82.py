#!/usr/bin/env python3
"""Extract stars from the Nakkhattapadani table (genaud.net/astro) and place
them in the 82 lunarpada buckets anchored at Antares.

Buckets: 82 equal cells of 360/82 = 4.3902 deg of J2000 ecliptic longitude,
bucket 1 starting exactly at Antares (249.77 deg). Because 41 cells = 180.0
deg and Aldebaran lies 179.99-180.01 deg from Antares, Aldebaran falls on the
boundary of bucket 42 by construction (see docs/SIDEREAL.md, gotcha G32).

Usage:  python3 nakkhattapadani_to_buckets82.py [saved_page.html]
Writes: buckets82.json and buckets82.md next to this script.
"""
import html
import json
import re
import sys
import urllib.request
from pathlib import Path

URL = "https://www.genaud.net/astro/"
ANCHOR = 249.77          # Antares J2000 ecliptic longitude, bucket 1 start
W = 360 / 82             # bucket width, 4.3902 deg
EDGE = 0.20              # deg from a boundary that counts as "on boundary"
HERE = Path(__file__).parent


def num(s):
    s = s.replace("−", "-").replace("°", "").strip()
    try:
        return float(s)
    except ValueError:
        return None


def load(argv):
    if len(argv) > 1:
        return Path(argv[1]).read_text()
    return urllib.request.urlopen(URL).read().decode()


def stars_from(page):
    stars, pada = [], None
    for row in re.findall(r"<tr[^>]*>(.*?)</tr>", page, re.DOTALL):
        cells = [
            re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", html.unescape(c))).strip()
            for c in re.findall(r"<t[dh][^>]*>(.*?)</t[dh]>", row, re.DOTALL)
        ]
        code = next((c.split()[0] for c in cells if re.match(r"^\d+[A-Za-z]+\d \d", c)), None)
        pada = code or pada
        for i in range(1, len(cells) - 1):
            lam, bet, name = num(cells[i]), num(cells[i + 1]), cells[i - 1]
            if lam is None or bet is None:
                continue
            if not (0 <= lam < 360 and -90 <= bet <= 90):
                continue
            if not re.search(r"[A-Za-z]{3}", name) or re.match(r"^\d+[A-Za-z]+\d", name):
                continue
            mag = re.search(r"\bm(?:ag)?\s*\+?(-?[\d.]+)", name)
            stars.append({
                "name": name.split("(")[0].strip() or name[:24],
                "full": name,
                "lam": lam,
                "bet": bet,
                "mag": float(mag.group(1)) if mag else None,
                "pada": pada,
            })
    return stars


def bucketed(stars):
    for s in stars:
        off = (s["lam"] - ANCHOR) % 360
        idx = int(off // W)
        s["bucket"] = idx + 1
        s["start"] = round((ANCHOR + idx * W) % 360, 2)
        s["into"] = round(off - idx * W, 2)
        s["on_boundary"] = s["into"] < EDGE or s["into"] > W - EDGE
    return sorted(stars, key=lambda s: (s["bucket"], s["into"]))


def main():
    stars = bucketed(stars_from(load(sys.argv)))
    (HERE / "buckets82.json").write_text(json.dumps(stars, indent=1))
    lines = [
        "# 82 lunarpada buckets, anchored at Antares 249.77 (J2000)",
        "",
        f"{len(stars)} stars; {len({s['bucket'] for s in stars})}/82 buckets occupied.",
        "",
        "| bkt | start | star | lam | bet | mag | into | pada | edge |",
        "|--:|--:|:--|--:|--:|--:|--:|:--|:--|",
    ]
    for s in stars:
        lines.append(
            f"| {s['bucket']} | {s['start']:.2f} | {s['name']} | {s['lam']:.2f} "
            f"| {s['bet']:.2f} | {s['mag'] if s['mag'] is not None else ''} "
            f"| {s['into']:.2f} | {s['pada']} | {'ON-BOUNDARY' if s['on_boundary'] else ''} |"
        )
    (HERE / "buckets82.md").write_text("\n".join(lines) + "\n")
    print(f"{len(stars)} stars -> buckets82.json, buckets82.md")


if __name__ == "__main__":
    main()
