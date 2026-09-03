#!/usr/bin/env bash
# Собирает index.html из четырёх блоков Tilda — для локального просмотра.
set -e
cd "$(dirname "$0")"
{
  printf '<!doctype html>\n<html lang="ru">\n<head>\n<meta charset="utf-8">\n'
  printf '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
  printf '<title>Пушкин. Живой — мультимедийная выставка в Екатеринбурге</title>\n'
  cat tilda/01-head.html
  printf '\n<style>\n'
  cat tilda/02-style.css
  printf '\n</style>\n</head>\n<body style="margin:0;background:#06080F">\n'
  cat tilda/03-body.html
  printf '\n'
  cat tilda/04-footer.html
  printf '\n</body>\n</html>\n'
} > index.html
echo "index.html собран: $(wc -c < index.html) байт"
