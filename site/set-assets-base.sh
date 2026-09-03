#!/usr/bin/env bash
# Готовит блоки для вставки в Tilda: подставляет во все пути к картинкам
# и видео ваш адрес хостинга.
#
#   bash set-assets-base.sh https://ваш-хостинг.ru/pushkin
#
# Результат кладётся в site/tilda-ready/ — оттуда и копируйте в Tilda.
set -e
cd "$(dirname "$0")"

BASE="$1"
if [ -z "$BASE" ]; then
  echo "Укажите адрес, где будут лежать файлы из assets/, например:"
  echo "  bash set-assets-base.sh https://ivanov.github.io/pushkin"
  exit 1
fi
BASE="${BASE%/}"

OUT="tilda-ready"
mkdir -p "$OUT"

# 1. BODY — переписываем пути
BASE="$BASE" perl -pe 's{"assets/}{"$ENV{BASE}/assets/}g' tilda/03-body.html > "$OUT/03-body.html"

# 2. HEAD, CSS и скрипты идут как есть
cp tilda/01-head.html "$OUT/01-head.html"
{ printf '<style>\n'; cat tilda/02-style.css; printf '\n</style>\n'; } > "$OUT/02-style.html"
cp tilda/04-footer.html "$OUT/04-footer.html"

N=$(grep -oF "$BASE/assets/" "$OUT/03-body.html" | wc -l)
echo "Готово: $OUT/"
echo "  01-head.html    → Настройки сайта → Ещё → HTML-код внутрь HEAD"
echo "  02-style.html   → туда же, следом (уже обёрнуто в <style>)"
echo "  03-body.html    → блок T123 «HTML-код» на странице"
echo "  04-footer.html  → Настройки сайта → Ещё → HTML-код внутрь BODY"
echo
echo "Путей переписано: $N. Файлы из assets/ выложите по адресу $BASE/assets/"
