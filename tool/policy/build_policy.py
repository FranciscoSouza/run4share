"""Builds docs/privacy/index.html from docs/privacy-policy.md.

GitHub Pages serves docs/ at https://franciscosouza.github.io/run4share/,
so the policy is public at .../privacy/ (the URL for Google Play, Health
Connect, Strava and the app). Run after editing the Markdown:

    python3 tool/policy/build_policy.py

Handles the Markdown the policy uses: headings, paragraphs, bullet lists,
bold, links and bare URLs. The review note (the leading blockquote) is
for Francisco and is left out of the page.
"""
import html
import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'docs' / 'privacy-policy.md'
TARGET = ROOT / 'docs' / 'privacy' / 'index.html'


def inline(text):
    text = html.escape(text, quote=False)
    text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'_(.+?)_', r'<em>\1</em>', text)
    text = re.sub(r'\[(.+?)\]\((https?://[^)]+)\)', r'<a href="\2">\1</a>', text)
    text = re.sub(
        r'(?<![">])(https?://[^\s<]+[^\s<.,;:)])',
        r'<a href="\1">\1</a>',
        text,
    )
    return text


def convert(markdown):
    out, para, items = [], [], []

    def flush():
        if para:
            out.append(f'<p>{inline(" ".join(para))}</p>')
            para.clear()
        if items:
            out.append('<ul>' + ''.join(f'<li>{inline(i)}</li>' for i in items) + '</ul>')
            items.clear()

    for raw in markdown.splitlines():
        line = raw.rstrip()
        if line.startswith('>'):
            continue  # The review note, not for the public page.
        if not line.strip():
            flush()
        elif line.startswith('# '):
            flush()
            out.append(f'<h1>{inline(line[2:])}</h1>')
        elif line.startswith('## '):
            flush()
            out.append(f'<h2>{inline(line[3:])}</h2>')
        elif line.startswith('- '):
            if para:
                flush()
            items.append(line[2:].strip())
        elif items and raw.startswith('  '):
            items[-1] += ' ' + line.strip()
        else:
            para.append(line.strip())
    flush()
    return '\n'.join(out)


PAGE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>run4share privacy policy</title>
<style>
  :root {{ color-scheme: light; }}
  body {{
    margin: 0; background: #FEFAF6; color: #0D0C0A;
    font: 16px/1.55 -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
      "Helvetica Neue", Arial, sans-serif;
  }}
  main {{ max-width: 680px; margin: 0 auto; padding: 32px 20px 56px; }}
  h1 {{ font-size: 30px; line-height: 1.15; margin: 0 0 8px; }}
  h2 {{ font-size: 20px; margin: 32px 0 8px; }}
  p, li {{ color: #262421; }}
  ul {{ padding-left: 22px; }}
  li {{ margin: 6px 0; }}
  a {{ color: #0077BD; }}
  em {{ color: #6B6762; font-style: normal; }}
  .brand {{ font-weight: 800; font-style: italic; letter-spacing: -0.3px; }}
  .brand b {{ color: #0077BD; }}
</style>
</head>
<body>
<main>
<p class="brand">run<b>4</b>share</p>
{body}
</main>
</body>
</html>
"""


def main():
    TARGET.parent.mkdir(parents=True, exist_ok=True)
    TARGET.write_text(PAGE.format(body=convert(SOURCE.read_text())))
    print(f'Wrote {TARGET.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
