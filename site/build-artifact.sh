#!/usr/bin/env bash
# Собирает автономную страницу: картинки вшиты как data:URI.
set -e
cd "$(dirname "$0")"
OUT="$1"
[ -z "$OUT" ] && OUT="pushkin-preview.html"

BODY=$(cat tilda/03-body.html)

# заменяем src="assets/hall/N.webp" на data:URI
for f in assets/hall/*.webp; do
  b64=$(base64 -w0 "$f")
  BODY=${BODY//"src=\"$f\""/"src=\"data:image/webp;base64,$b64\""}
done

{
  printf '<title>Пушкин. Живой</title>\n'
  printf '<link rel="preconnect" href="https://fonts.googleapis.com">\n'
  printf '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>\n'
  printf '<link href="https://fonts.googleapis.com/css2?family=Prata&family=Golos+Text:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">\n'
  printf '<style>\nhtml,body{margin:0;background:#06080F}\n'
  cat tilda/02-style.css
  printf '\n</style>\n'
  printf '%s\n' "$BODY"
  cat tilda/04-footer.html
} > "$OUT"
echo "$OUT: $(du -h "$OUT" | cut -f1)"
