#!/usr/bin/env python3
"""Translation review sheet for native speakers.

    python3 tool/translations.py export   # writes docs/translations-review.csv
    python3 tool/translations.py import   # applies the CSV back to lib/l10n

The CSV has one row per string: key, where it appears, notes, then English
and each language. Reviewers edit only the language columns. Import updates
every string whose text changed, and refuses a row that drops or renames a
placeholder such as {count}, so the app keeps compiling.

Run from the project root, then `flutter gen-l10n`.
"""

import collections
import csv
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
L10N = ROOT / "lib" / "l10n"
SHEET = ROOT / "docs" / "translations-review.csv"
LANGS = ["en", "pt", "es", "fr", "de"]
HEADERS = ["key", "where", "notes"] + LANGS

# Where each group of strings appears, by key prefix (longest match wins).
WHERE = {
    "nav": "Bottom tab bar",
    "home": "Activities tab (Home)",
    "source": "Home: Bring in your workouts",
    "stat": "Activity cards and stickers: figure labels",
    "action": "Buttons used in several places",
    "connect": "Connect Strava screen",
    "strava": "Strava connection messages",
    "creations": "My Creations tab",
    "creation": "My Creations: image detail",
    "settings": "Settings",
    "unit": "Settings: units",
    "language": "Settings: language",
    "lab": "Settings: Laboratory (test builds only)",
    "form": "Add / edit activity form",
    "type": "Activity types (also on stickers, in capitals)",
    "activity": "Activity cards: menu and messages",
    "deleteActivity": "Delete activity dialog",
    "photo": "Choosing a photo",
    "photos": "Choosing a photo: grid",
    "crop": "Format and crop screen",
    "format": "Format and crop: format names",
    "editor": "Editor",
    "theme": "Editor: why a theme can't be used",
    "metric": "Template preview: what a template shows (lower case)",
    "template": "Popular templates flow",
    "colour": "Editor: text colours",
    "background": "Editor: sticker background",
    "share": "Share screen",
    "saved": "Saved to Photos screen",
    "rate": "Rating sheet",
    "invite": "Invite a friend screen",
    "comingSoon": "Message for features not built yet",
    "appName": "Brand name, do not translate",
}

def where(key):
    best = ""
    for prefix in WHERE:
        if key.startswith(prefix) and len(prefix) > len(best):
            best = prefix
    return WHERE.get(best, "")


def load():
    return {
        lang: json.loads(
            (L10N / f"app_{lang}.arb").read_text("utf-8"),
            object_pairs_hook=collections.OrderedDict,
        )
        for lang in LANGS
    }


def export():
    arbs = load()
    en = arbs["en"]
    with SHEET.open("w", encoding="utf-8-sig", newline="") as f:
        out = csv.writer(f)
        out.writerow(HEADERS)
        for key, value in en.items():
            if key.startswith("@"):
                continue
            meta = en.get(f"@{key}", {})
            notes = meta.get("description", "")
            names = list(meta.get("placeholders", {}))
            if names:
                kept = ", ".join("{" + n + "}" for n in names)
                notes = (notes + " " if notes else "") + f"Keep {kept} as is."
            out.writerow(
                [key, where(key), notes]
                + [arbs[lang].get(key, "") for lang in LANGS]
            )
    print(f"Wrote {SHEET.relative_to(ROOT)}")


def import_():
    arbs = load()
    changed, refused = 0, []
    with SHEET.open(encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            key = row["key"]
            # The declared placeholders, e.g. {count}; plural cases inside
            # a string ({count, plural, =1{1 image} ...}) are not names.
            wanted = sorted(arbs["en"].get(f"@{key}", {}).get("placeholders", {}))
            for lang in LANGS[1:]:
                text = (row.get(lang) or "").strip()
                if not text or text == arbs[lang].get(key):
                    continue
                if not all("{" + name in text for name in wanted):
                    kept = ", ".join("{" + n + "}" for n in wanted)
                    refused.append(f"{key} ({lang}): must keep {kept}")
                    continue
                arbs[lang][key] = text
                changed += 1
    for lang in LANGS[1:]:
        path = L10N / f"app_{lang}.arb"
        path.write_text(
            json.dumps(arbs[lang], ensure_ascii=False, indent=2) + "\n",
            "utf-8",
        )
    print(f"Updated {changed} strings.")
    for line in refused:
        print(f"Refused {line}")
    return 1 if refused else 0


if __name__ == "__main__":
    command = sys.argv[1] if len(sys.argv) > 1 else ""
    if command == "export":
        export()
    elif command == "import":
        sys.exit(import_())
    else:
        print(__doc__)
        sys.exit(2)
